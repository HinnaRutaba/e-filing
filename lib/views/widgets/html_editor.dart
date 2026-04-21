import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as he;
import 'package:html_editor_enhanced/utils/toolbar.dart';

export 'package:html_editor_enhanced/html_editor.dart'
    show HtmlEditorController;

class HtmlEditor extends StatefulWidget {
  final String? initialHtml;
  final String? hint;
  final double? height;
  final he.HtmlEditorController? controller;
  final ValueChanged<String>? onChanged;

  const HtmlEditor({
    super.key,
    this.initialHtml,
    this.hint,
    this.height,
    this.controller,
    this.onChanged,
  });

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  late final he.HtmlEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? he.HtmlEditorController();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? MediaQuery.sizeOf(context).height * 0.5;
    return he.HtmlEditor(
      controller: _controller,
      htmlEditorOptions: he.HtmlEditorOptions(
        hint: widget.hint,
        initialText: widget.initialHtml,
        shouldEnsureVisible: false,
      ),

      htmlToolbarOptions: const he.HtmlToolbarOptions(
        toolbarPosition: he.ToolbarPosition.aboveEditor,
        toolbarType: he.ToolbarType.nativeGrid,
        gridViewVerticalSpacing: -12,
        defaultToolbarButtons: [
          FontSettingButtons(fontName: false, fontSizeUnit: false),
          FontButtons(clearAll: false),
          ListButtons(listStyles: false),
          ParagraphButtons(caseConverter: false, lineHeight: false),
        ],
      ),

      otherOptions: he.OtherOptions(
        height: height,
        decoration: const BoxDecoration(),
      ),
      callbacks: he.Callbacks(
        onChangeContent: (content) {
          if (content != null) widget.onChanged?.call(content);
        },
      ),
    );
  }
}
