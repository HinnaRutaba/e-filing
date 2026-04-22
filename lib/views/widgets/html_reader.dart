import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

const String fileFont = 'BookAntiqua';

class HtmlReader extends StatelessWidget {
  final String html;
  final TextStyle? textStyle;
  const HtmlReader({super.key, required this.html, this.textStyle});

  // Strip any explicit height values from inline styles.
  // MSO (Word) exports add height: 1px on every <tr>/<td>, which collapses
  // cells to a single pixel in Flutter's HTML renderer.
  static String _preprocessHtml(String raw) {
    return raw.replaceAll(
      RegExp(r'height\s*:\s*[^;"]+;?', caseSensitive: false),
      '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final processedHtml = _preprocessHtml(html);
    final effectiveTextStyle =
        textStyle ?? const TextStyle(fontSize: 14, fontFamily: fileFont);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return SingleChildScrollView(
          child: HtmlWidget(
            processedHtml,
            customWidgetBuilder: (element) {
              if (element.localName == 'table') {
                // Apply preprocessing again as belt-and-suspenders, since
                // element.outerHtml re-serializes the parsed DOM and may
                // behave differently from the pre-processed string.
                final tableHtml = _preprocessHtml(element.outerHtml);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // SizedBox gives the inner HtmlWidget a finite width so the
                  // table layout engine can compute column widths. Without this,
                  // the unbounded horizontal scroll view causes cells to collapse.
                  child: SizedBox(
                    width: availableWidth,
                    child: HtmlWidget(
                      tableHtml,
                      textStyle: effectiveTextStyle,
                      customStylesBuilder: (el) {
                        if (el.localName == 'td' || el.localName == 'th') {
                          return {
                            'padding': '8px',
                            'word-break': 'break-word',
                            'white-space': 'normal',
                          };
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }
              return null;
            },
            renderMode: RenderMode.column,
            textStyle: effectiveTextStyle,
          ),
        );
      },
    );
  }
}
