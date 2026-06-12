import 'dart:typed_data';

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
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

  // The active panel state registers its own local GlobalKeys here on mount
  // and clears them on dispose. Keeping keys in the state (not the controller)
  // prevents duplicate-GlobalKey crashes when multiple panel instances share
  // the same controller (e.g. during a PageView page-transition animation).
  GlobalKey? _activeSignPadKey;
  GlobalKey? _activeRemarksPadKey;

  // External callers (e.g. scroll-to-signature/remarks) read through these.
  GlobalKey? get signPadKey => _activeSignPadKey;
  GlobalKey? get remarksPadKey => _activeRemarksPadKey;

  void _attachKeys(GlobalKey sign, GlobalKey written, GlobalKey remarks) {
    _activeSignPadKey = sign;
    _activeRemarksPadKey = remarks;
  }

  // Only clears if the detaching state's key is still the active one,
  // so a late-disposing old page doesn't wipe the key set by the new page.
  void _detachKeys(GlobalKey sign) {
    if (_activeSignPadKey == sign) {
      _activeSignPadKey = null;
      _activeRemarksPadKey = null;
    }
  }

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

  /// When true, the signature pad starts collapsed ("Tap to sign").
  /// Tapping expands it; after signing and pressing Done it collapses
  /// back to a small preview with an edit overlay — same UX as the
  /// inline sign pad in SummaryDocumentCard.
  final bool compactSignature;

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
    this.compactSignature = false,
  });

  @override
  State<RemarksSignPanel> createState() => _RemarksSignPanelState();
}

class _RemarksSignPanelState extends State<RemarksSignPanel> {
  RemarksSignPanelController get _ctrl => widget.controller;

  bool get _expanded => _ctrl.isExpanded;

  // Compact signature state (used only when widget.compactSignature == true)
  bool _signPadExpanded = false;
  Uint8List? _signaturePreview;

  // Local keys — unique per state instance, never shared across pages.
  final GlobalKey _signPadKey = GlobalKey();
  final GlobalKey _writtenPadKey = GlobalKey();
  final GlobalKey _remarksPadKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Set directly to avoid notifyListeners() during mount, which would call
    // setState on any sibling page's state that already has a listener on this
    // shared controller — causing setState-during-build errors in the pager.
    _ctrl._mode = widget.initialMode;
    // Don't reset _expanded when locked — toggleLock() already set it to true.
    if (!_ctrl.isLocked) _ctrl._expanded = widget.initiallyExpanded;
    _ctrl._attachKeys(_signPadKey, _writtenPadKey, _remarksPadKey);
    _ctrl.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _ctrl._detachKeys(_signPadKey);
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

    // Sticky (locked) layout: header is always visible, body scrolls internally.
    // The scroll view height is capped to show just the remarks-input section;
    // signature + forwarding fields are revealed by scrolling.
    if (_ctrl.isLocked && _expanded) {
      // Type editor = 220 px, write canvas = 280 px.
      // Add mode-toggle (~44), info row (~35), spacing (~26), padding (~14).
      final scrollMaxHeight = _ctrl.mode == RemarksPanelMode.write
          ? 400.0
          : 340.0;
      return Container(
        decoration: decoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: scrollMaxHeight),
              child: Scrollbar(
                controller: widget.scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 12,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: _body(),
                ),
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
            child: _expanded ? _body() : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    if (!widget.showHeading) {
      if (widget.onLockToggle != null) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: _LockChip(
              isLocked: _ctrl.isLocked,
              onTap: widget.onLockToggle!,
            ),
          ),
        );
      }
      return const SizedBox(height: 24);
    }
    final isLocked = _ctrl.isLocked;
    return InkWell(
      onTap: isLocked
          ? null
          : () => _expanded ? _ctrl.collapse() : _ctrl.expand(),
      borderRadius: _expanded
          ? const BorderRadius.vertical(top: Radius.circular(4))
          : BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            Expanded(child: AppText.titleLarge('Add your remarks')),
            if (_expanded && widget.onLockToggle != null) ...[
              const SizedBox(width: 8),
              _LockChip(isLocked: isLocked, onTap: widget.onLockToggle!),
              const SizedBox(width: 4),
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
          // CM: one white bordered container that holds BOTH the remarks input
          // (top) and the sign pad (bottom). The sign button sits at the
          // bottom-right corner of the remarks area. Tapping it slides the
          // sign pad in below — all within the same box.
          // Secretary: plain remarks input + separate "Sign here" section.
          if (widget.compactSignature) ...[
            Container(
              key: _remarksPadKey,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondaryLight.withValues(alpha: 0.4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Remarks area with sign button/preview at bottom-right.
                  // Type mode: Column so the button sits below HtmlEditor,
                  // avoiding the platform-view gesture conflict from a Stack.
                  // Write mode: bottomTrailingWidget places it outside the canvas.
                  // In both cases the button is hidden once the pad is expanded.
                  _ctrl.mode == RemarksPanelMode.type
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _typedField(showBorder: false),
                            if (!_signPadExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _compactSignCollapsed(),
                                ),
                              ),
                          ],
                        )
                      : _writtenCanvas(
                          compact: true,
                          bottomTrailing: _signPadExpanded
                              ? null
                              : _compactSignCollapsed(),
                        ),
                  // Sign pad slides in/out while staying in the tree so the
                  // SignaturePad's stroke state is never lost on collapse.
                  ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      heightFactor: _signPadExpanded ? 1.0 : 0.0,
                      child: _inlineSignPad(),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              key: _remarksPadKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _ctrl.mode == RemarksPanelMode.type
                    ? _typedField()
                    : _writtenCanvas(),
              ),
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
                  key: _signPadKey,
                  controller: _ctrl._signCtrl,
                  initialPenColor: widget.initialPenColor,
                  showPenSelector: false,
                ),
              ),
            ),
          ],
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

  Widget _typedField({bool showBorder = true}) {
    final content = Container(
      key: const ValueKey('remarks_typed'),
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: showBorder ? BorderRadius.circular(8) : null,
        border: showBorder
            ? Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.4),
              )
            : null,
      ),
      child: HtmlEditor(
        controller: _ctrl._typedCtrl,
        hint: 'Type your remarks here…',
        height: 240,
      ),
    );
    if (!showBorder) return content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }

  Widget _writtenCanvas({Widget? bottomTrailing, bool compact = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Subtract padding so canvas width measurement stays accurate.
        final padH = compact ? 10.0 : 0.0;
        final effectiveWidth = constraints.maxWidth - padH * 2;
        if (_ctrl._canvasWidth != effectiveWidth) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _ctrl._updateCanvasWidth(effectiveWidth));
            }
          });
        }
        final pad = SignaturePad(
          key: _writtenPadKey,
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
          showCanvasBorder: !compact,
          bottomTrailingWidget: bottomTrailing,
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
        if (!compact) return pad;
        return Padding(
          padding: EdgeInsets.fromLTRB(padH, padH, padH, 0),
          child: pad,
        );
      },
    );
  }

  // ── Compact signature (CM mode) ───────────────────────────────────────────

  void _openSignPad() {
    setState(() => _signPadExpanded = true);
    final sc = widget.scrollController;
    if (sc == null) return;
    // Wait for AnimatedAlign (280 ms) to finish expanding before scrolling,
    // otherwise maxScrollExtent hasn't grown yet and the scroll is a no-op.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted || !sc.hasClients) return;
      sc.animateTo(
        sc.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// The collapsed state: either an empty "Tap to sign" button or a
  /// thumbnail preview of the captured signature with an edit overlay.
  Widget _compactSignCollapsed() {
    return _signaturePreview != null ? _compactSignPreview() : _compactSignButton();
  }

  Widget _compactSignButton() {
    return InkWell(
      onTap: _openSignPad,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 160,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.secondaryLight.withValues(alpha: 0.45),
          ),
          color: AppColors.secondaryLight.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_outlined, size: 16, color: AppColors.secondaryDark),
            const SizedBox(width: 6),
            AppText.labelLarge('Tap to sign', color: AppColors.secondaryDark, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }

  Widget _compactSignPreview() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _openSignPad,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 160,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.45),
              ),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Image.memory(_signaturePreview!, fit: BoxFit.contain),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.secondaryLight.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.edit_outlined, size: 13, color: AppColors.secondaryDark),
            ),
          ),
        ],
      ),
    );
  }

  // Borderless sign pad that lives inside the shared outer container.
  Widget _inlineSignPad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: widget.signPadWidth ?? double.infinity,
                  child: SignaturePad(
                    key: _signPadKey,
                    controller: _ctrl._signCtrl,
                    canvasHeight: 180,
                    canvasColor: Colors.white,
                    initialPenColor: widget.initialPenColor,
                    showPenSelector: false,
                    showDescription: false,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  AppText.labelSmall(
                    'Sign above',
                    color: AppColors.textSecondary,
                  ),
                  const Spacer(),
                  AppOutlineButton(
                    onPressed: () async {
                      if (_ctrl._signCtrl.isNotEmpty) {
                        final bytes = await _ctrl._signCtrl.toPngBytes();
                        if (!mounted) return;
                        setState(() {
                          _signaturePreview = bytes;
                          _signPadExpanded = false;
                        });
                      } else {
                        setState(() {
                          _signaturePreview = null;
                          _signPadExpanded = false;
                        });
                      }
                    },
                    icon: Icons.check,
                    text: 'Done',
                    color: AppColors.secondaryDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped chip with an animated lock icon that snaps closed on lock.
class _LockChip extends StatefulWidget {
  final bool isLocked;
  final VoidCallback onTap;

  const _LockChip({required this.isLocked, required this.onTap});

  @override
  State<_LockChip> createState() => _LockChipState();
}

class _LockChipState extends State<_LockChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _slideY;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    // Scale: 0.4 → 1.0 with elastic bounce (shackle snapping shut)
    _scale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    // SlideY: icon enters from slightly above (simulates shackle moving down)
    _slideY = Tween<double>(
      begin: -6.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    // Start at final position if already locked on mount.
    if (widget.isLocked) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_LockChip old) {
    super.didUpdateWidget(old);
    if (widget.isLocked == old.isLocked) return;
    if (widget.isLocked) {
      _ctrl.forward(from: 0.0);
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.isLocked;
    final chipColor = isLocked
        ? AppColors.primary.withValues(alpha: 0.10)
        : AppColors.secondaryLight.withValues(alpha: 0.10);
    final borderColor = isLocked
        ? AppColors.primary.withValues(alpha: 0.55)
        : AppColors.secondaryLight.withValues(alpha: 0.45);
    final contentColor = isLocked ? AppColors.primary : AppColors.textSecondary;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  // Locked icon animates in (scale + slide); open icon is static.
                  if (isLocked || _ctrl.value > 0.01) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Open lock fades out as locking begins
                        FadeTransition(
                          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                            CurvedAnimation(
                              parent: _ctrl,
                              curve: const Interval(
                                0.0,
                                0.3,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_open_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        // Closed lock snaps in from above
                        FadeTransition(
                          opacity: _fadeIn,
                          child: Transform.translate(
                            offset: Offset(0, _slideY.value),
                            child: Transform.scale(
                              scale: _scale.value,
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const Icon(
                    Icons.lock_open_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
              child: const Text('Always display remarks'),
            ),
          ],
        ),
      ),
    );
  }
}
