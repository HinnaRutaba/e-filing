import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

const String fileFont = 'BookAntiqua';

class HtmlReader extends StatelessWidget {
  final String html;
  final TextStyle? textStyle;
  const HtmlReader({super.key, required this.html, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      '''
         $html
      ''',

      // customStylesBuilder: (element) {
      //   if (element.classes.contains('foo')) {
      //     return {'color': 'red'};
      //   }
      //
      //   return null;
      // },

      // customWidgetBuilder: (element) {
      //   if (element.attributes['foo'] == 'bar') {
      //     // render a custom block widget that takes the full width
      //     return FooBarWidget();
      //   }
      //
      //   if (element.attributes['fizz'] == 'buzz') {
      //     // render a custom widget inline with surrounding text
      //     return InlineCustomWidget(
      //       child: FizzBuzzWidget(),
      //     )
      //   }
      //
      //   return null;
      // },

      // this callback will be triggered when user taps a link
      onTapUrl: (url) {
        print('tapped $url');
        return true;
      },

      // select the render mode for HTML body
      // by default, a simple `Column` is rendered
      // consider using `ListView` or `SliverList` for better performance
      renderMode: RenderMode.column,

      // set the default styling for text
      textStyle: const TextStyle(
        fontSize: 14,
        fontFamily: fileFont,
      ),
    );
  }
}
