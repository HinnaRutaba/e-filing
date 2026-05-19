import 'dart:typed_data';

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/html_editor.dart';
import 'package:efiling_balochistan/views/widgets/signature_pad.dart';
import 'package:flutter/material.dart';

enum RemarksPanelMode { type, write }

/// Holds internal controllers and exposes methods to read panel data.
/// Create one instance in the parent, pass it to [RemarksSignPanel],
/// and call its methods from the parent's submit handler.
class RemarksSignPanelController extends ChangeNotifier {
  final HtmlEditorController _typedCtrl = HtmlEditorController();
  final SignaturePadController _signCtrl = SignaturePadController();
  final SignaturePadController _writtenCtrl = SignaturePadController();

  RemarksPanelMode _mode = RemarksPanelMode.type;
  double _canvasWidth = 0;

  RemarksPanelMode get mode => _mode;
  set mode(RemarksPanelMode v) {
    _mode = v;
    notifyListeners();
  }

  bool get isWrittenEmpty => _writtenCtrl.isEmpty;
  bool get isSignatureEmpty => _signCtrl.isEmpty;

  /// Returns the typed HTML remarks (only meaningful when mode == type).
  Future<String> getTypedRemarks() => _typedCtrl.getText();

  /// Returns the drawn signature as PNG bytes.
  Future<Uint8List?> getSignatureBytes() => _signCtrl.toPngBytes();

  /// Returns the handwritten strokes as a JSON string for persistence.
  String? getStrokesJson() => _writtenCtrl.toStrokesJson(
    canvasWidth: _canvasWidth > 0 ? _canvasWidth : 600,
  );

  /// Returns the handwritten canvas rendered as PNG bytes.
  Future<Uint8List?> getWrittenPngBytes() => _writtenCtrl.toPngBytes();

  String? get penColorHex => _writtenCtrl.penColorHex;
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _writtenCtrl.canvasHeight;

  bool _expanded = false;
  bool get isExpanded => _expanded;

  void expand() {
    _expanded = true;
    notifyListeners();
  }

  void collapse() {
    _expanded = false;
    notifyListeners();
  }

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  void toggleLock() {
    _isLocked = !_isLocked;
    if (_isLocked) _expanded = true;
    notifyListeners();
  }

  void reset() {
    _signCtrl.clearSilently();
    _writtenCtrl.clearSilently();
    notifyListeners();
  }

  // Called by the widget to track canvas width for stroke encoding.
  void _updateCanvasWidth(double w) => _canvasWidth = w;
}

/// A collapsible panel that lets a user type or handwrite remarks,
/// draw a signature, and optionally show extra content below (e.g.
/// forwarding fields and a submit button).
///
/// All data is accessed through [RemarksSignPanelController]:
/// ```dart
/// final _ctrl = RemarksSignPanelController();
///
/// // In submit handler:
/// final mode  = _ctrl.mode;
/// final sig   = await _ctrl.getSignatureBytes();
/// final typed = await _ctrl.getTypedRemarks();   // if mode == type
/// final strokes = _ctrl.getStrokesJson();         // if mode == write
/// ```
class RemarksSignPanel extends StatefulWidget {
  final RemarksSignPanelController controller;

  /// Sets which remarks input mode is selected when the panel is first shown.
  final RemarksPanelMode initialMode;

  /// Rendered below the signature pad — typically forwarding fields
  /// and a submit button wired to the parent's submit callback.
  final Widget? bottomContent;

  /// If provided, auto-scrolls down when the handwriting canvas expands.
  final ScrollController? scrollController;

  final bool initiallyExpanded;

  /// Pre-selects a pen colour in the handwriting canvas.
  final SignatureColor initialPenColor;

  final bool showHeading;

  /// Constrains the signature pad to this width and right-aligns it.
  /// When null (default) the pad stretches to full width.
  final double? signPadWidth;

  /// Called when the user taps the lock/unlock button in the panel header.
  final VoidCallback? onLockToggle;

  const RemarksSignPanel({
    super.key,
    required this.controller,
    this.bottomContent,
    this.scrollController,
    this.initiallyExpanded = false,
    this.initialMode = RemarksPanelMode.type,
    this.initialPenColor = SignatureColor.darkBlue,
    this.showHeading = true,
    this.signPadWidth = 400,
    this.onLockToggle,
  });

  @override
  State<RemarksSignPanel> createState() => _RemarksSignPanelState();
}

class _RemarksSignPanelState extends State<RemarksSignPanel> {
  RemarksSignPanelController get _ctrl => widget.controller;

  bool get _expanded => _ctrl.isExpanded;

  @override
  void initState() {
    super.initState();
    // Set directly to avoid notifyListeners() during mount, which would call
    // setState on any sibling page's state that already has a listener on this
    // shared controller — causing setState-during-build errors in the pager.
    _ctrl._mode = widget.initialMode;
    // Don't reset _expanded when locked — toggleLock() already set it to true.
    if (!_ctrl.isLocked) _ctrl._expanded = widget.initiallyExpanded;
    _ctrl.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: AppColors.secondaryLight.withValues(alpha: 0.35),
      ),
    );

    // Sticky (locked) layout: header is pinned, body scrolls internally.
    // The parent container supplies a maxHeight constraint.
    if (_ctrl.isLocked && _expanded) {
      return Container(
        decoration: decoration,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: _body(),
              ),
            ),
          ],
        ),
      );
    }

    // Normal layout: collapses/expands with animation, sizes to content.
    return Container(
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _body()
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    if (!widget.showHeading) return const SizedBox(height: 24);
    final isLocked = _ctrl.isLocked;
    return InkWell(
      onTap: isLocked ? null : () => _expanded ? _ctrl.collapse() : _ctrl.expand(),
      borderRadius: _expanded
          ? const BorderRadius.vertical(top: Radius.circular(4))
          : BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Expanded(child: AppText.titleLarge('Add your remarks')),
            if (_expanded && widget.onLockToggle != null) ...[
              Tooltip(
                message: isLocked ? 'Unlock panel (scroll together)' : 'Lock panel (scroll document independently)',
                child: InkWell(
                  onTap: widget.onLockToggle,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                        key: ValueKey(isLocked),
                        size: 18,
                        color: isLocked ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
            ],
            if (!isLocked)
              AnimatedRotation(
                turns: _expanded ? 0 : -0.5,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeToggle(),
          const SizedBox(height: 4),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: AppColors.secondary,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Type your remark or switch to Write and use your tablet pen. '
                  'Your handwriting will appear on the printed summary as proof of authorship.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _ctrl.mode == RemarksPanelMode.type
                ? _typedField()
                : _writtenCanvas(),
          ),
          const Divider(height: 24),
          AppText.titleLarge('Sign here'),
          const SizedBox(height: 16),
          Align(
            alignment: widget.signPadWidth != null
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: SizedBox(
              width: widget.signPadWidth,
              child: SignaturePad(
                controller: _ctrl._signCtrl,
                initialPenColor: widget.initialPenColor,
                showPenSelector: false,
              ),
            ),
          ),
          if (widget.bottomContent != null) ...[
            const SizedBox(height: 16),
            widget.bottomContent!,
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _modeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _modeOption(
            'Type',
            RemarksPanelMode.type,
            Icons.keyboard_alt_outlined,
          ),
          _modeOption('Write', RemarksPanelMode.write, Icons.draw_outlined),
        ],
      ),
    );
  }

  Widget _modeOption(String label, RemarksPanelMode mode, IconData icon) {
    final isSelected = _ctrl.mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _ctrl.mode = mode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              AppText.labelMedium(
                label,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typedField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        key: const ValueKey('remarks_typed'),
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.secondaryLight.withValues(alpha: 0.4),
          ),
        ),
        child: HtmlEditor(
          controller: _ctrl._typedCtrl,
          hint: 'Type your remarks here…',
          height: 240,
        ),
      ),
    );
  }

  Widget _writtenCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_ctrl._canvasWidth != constraints.maxWidth) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) =>
                setState(() => _ctrl._updateCanvasWidth(constraints.maxWidth)),
          );
        }
        return SignaturePad(
          key: const ValueKey('remarks_written'),
          controller: _ctrl._writtenCtrl,
          showRuledLines: true,
          initialPenColor: widget.initialPenColor,
          autoExpand: true,
          autoExpandStep: 120,
          showStrokeInfo: true,
          showCustomColorPicker: true,
          canvasHeight: 280,
          showDescription: false,
          canvasColor: Colors.grey.shade50,
          onExpand: () {
            final sc = widget.scrollController;
            if (sc == null || !sc.hasClients) return;
            final pos = sc.position;
            final target = (pos.pixels + 120).clamp(0.0, pos.maxScrollExtent);
            sc.animateTo(
              target,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        );
      },
    );
  }
}
