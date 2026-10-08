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

class _HtmlEditorState extends State<HtmlEditor> with WidgetsBindingObserver {
  late final he.HtmlEditorController _controller;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? he.HtmlEditorController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The keyboard is often dismissed from the Flutter side (tap outside,
  // scroll-to-dismiss, back button) while the editable inside the webview
  // keeps its DOM/native focus. Tapping an already-focused editable doesn't
  // raise the keyboard again, so the editor looks dead until something else
  // takes focus. Drop the webview's focus whenever the keyboard goes away so
  // the next tap is a fresh focus.
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final visible = View.of(context).viewInsets.bottom > 0;
    final wasVisible = _keyboardVisible;
    _keyboardVisible = visible;
    if (wasVisible && !visible) _releaseEditorFocus();
  }

  void _releaseEditorFocus() {
    final webview = _controller.editorController;
    if (webview == null) return;
    webview.evaluateJavascript(
      source:
          "document.activeElement && document.activeElement.blur();"
          "document.querySelector('.note-editable')?.blur();",
    );
    webview.clearFocus();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? MediaQuery.sizeOf(context).height * 0.5;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? Colors.white70 : Colors.black87;
    final buttonFillColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final dropdownDecoration = BoxDecoration(
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.12),
      ),
    );
    return he.HtmlEditor(
      controller: _controller,
      htmlEditorOptions: he.HtmlEditorOptions(
        hint: widget.hint,
        initialText: widget.initialHtml,
        shouldEnsureVisible: false,
        darkMode: isDark,
        spellCheck: true,
        autoAdjustHeight: true,
        adjustHeightForKeyboard: false,
      ),

      htmlToolbarOptions: he.HtmlToolbarOptions(
        toolbarPosition: he.ToolbarPosition.aboveEditor,
        toolbarType: he.ToolbarType.nativeGrid,
        gridViewVerticalSpacing: -12,
        buttonColor: buttonColor,
        buttonFillColor: buttonFillColor,
        dropdownBoxDecoration: dropdownDecoration,
        defaultToolbarButtons: const [
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
        onInit: () {
          _controller.editorController?.evaluateJavascript(
            source:
                "document.querySelector('.note-editable')?.setAttribute('spellcheck','true');",
          );
        },
        onChangeContent: (content) {
          if (content != null) widget.onChanged?.call(content);
        },
      ),
    );
  }
}
