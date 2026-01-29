import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

const String fileFont = 'BookAntiqua';

class HtmlReader extends StatelessWidget {
  final String html;
  final TextStyle? textStyle;
  const HtmlReader({super.key, required this.html, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: HtmlWidget(
        html,
        customWidgetBuilder: (element) {
          // Wrap table elements in a horizontal scroll view
          if (element.localName == 'table') {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HtmlWidget(
                element.outerHtml,
                textStyle: textStyle ??
                    const TextStyle(
                      fontSize: 14,
                      fontFamily: fileFont,
                    ),
                customStylesBuilder: (element) {
                  if (element.localName == 'td' || element.localName == 'th') {
                    return {
                      'padding': '8px',
                      'word-break': 'break-word',
                      'white-space': 'normal',
                    };
                  }
                  if (element.localName == 'table') {
                    return {
                      'border-collapse': 'collapse',
                    };
                  }
                  return null;
                },
              ),
            );
          }
          return null;
        },
        renderMode: RenderMode.column,
        textStyle: textStyle ??
            const TextStyle(
              fontSize: 14,
              fontFamily: fileFont,
            ),
      ),
    );
  }
}
