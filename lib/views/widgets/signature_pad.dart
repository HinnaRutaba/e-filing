import 'dart:typed_data';

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePenPreset {
  final String label;
  final IconData icon;
  final double width;
  final String description;
  const SignaturePenPreset({
    required this.label,
    required this.icon,
    required this.width,
    required this.description,
  });
}

const List<SignaturePenPreset> kDefaultSignaturePens = [
  SignaturePenPreset(
    label: 'Natural flow',
    icon: Icons.edit_outlined,
    width: 3.0,
    description: 'Smooth and balanced stroke for regular signatures.',
  ),
  SignaturePenPreset(
    label: 'Ballpoint',
    icon: Icons.create_outlined,
    width: 2.0,
    description: 'Thin, precise strokes for compact signatures.',
  ),
  SignaturePenPreset(
    label: 'Fine tip',
    icon: Icons.edit_note_outlined,
    width: 1.5,
    description: 'Extra fine lines for detailed signatures.',
  ),
  SignaturePenPreset(
    label: 'Marker',
    icon: Icons.brush_outlined,
    width: 5.0,
    description: 'Bold, expressive strokes.',
  ),
  SignaturePenPreset(
    label: 'Brush',
    icon: Icons.format_paint_outlined,
    width: 7.0,
    description: 'Smooth brush-like strokes.',
  ),
];

const List<Color> kDefaultSignatureColors = [
  Color(0xFF0D2C6B),
  Color(0xFF111827),
  Color(0xFF1F6B3A),
  Color(0xFF7A1F1F),
];

class SignaturePadController {
  _SignaturePadState? _state;

  void _attach(_SignaturePadState state) => _state = state;
  void _detach(_SignaturePadState state) {
    if (_state == state) _state = null;
  }

  bool get isEmpty => _state?._signatureController.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  Color get penColor => _state?._penColor ?? kDefaultSignatureColors.first;
  int get penIndex => _state?._penIndex ?? 0;
  SignaturePenPreset get currentPen =>
      _state?._currentPen ?? kDefaultSignaturePens.first;

  Future<Uint8List?> toPngBytes() async {
    final s = _state;
    if (s == null || s._signatureController.isEmpty) return null;
    return s._signatureController.toPngBytes();
  }

  void clear() => _state?._clear();
  void undo() => _state?._undo();

  void setPenColor(Color color) => _state?._setPenColor(color);
  void setPenIndex(int index) => _state?._setPenIndex(index);
}

class SignaturePad extends StatefulWidget {
  final SignaturePadController? controller;
  final List<SignaturePenPreset> pens;
  final List<Color> colors;
  final Color initialPenColor;
  final int initialPenIndex;
  final double canvasHeight;
  final Color canvasColor;
  final VoidCallback? onChanged;
  final VoidCallback? onDrawStart;
  final VoidCallback? onDrawEnd;
  final bool showClearButton;
  final bool showUndoButton;
  final bool showDescription;

  const SignaturePad({
    super.key,
    this.controller,
    this.pens = kDefaultSignaturePens,
    this.colors = kDefaultSignatureColors,
    this.initialPenColor = const Color(0xFF0D2C6B),
    this.initialPenIndex = 0,
    this.canvasHeight = 180,
    this.canvasColor = AppColors.cardColorLight,
    this.onChanged,
    this.onDrawStart,
    this.onDrawEnd,
    this.showClearButton = true,
    this.showUndoButton = true,
    this.showDescription = true,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late int _penIndex;
  late Color _penColor;
  late SignatureController _signatureController;

  SignaturePenPreset get _currentPen => widget.pens[_penIndex];

  @override
  void initState() {
    super.initState();
    _penIndex = widget.initialPenIndex.clamp(0, widget.pens.length - 1);
    _penColor = widget.initialPenColor;
    _signatureController = _buildController();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _signatureController.dispose();
    super.dispose();
  }

  SignatureController _buildController({List<Point>? points}) {
    return SignatureController(
      penColor: _penColor,
      penStrokeWidth: _currentPen.width,
      exportBackgroundColor: Colors.transparent,
      points: points,
      onDrawStart: widget.onDrawStart,
      onDrawEnd: () {
        widget.onDrawEnd?.call();
        widget.onChanged?.call();
      },
    );
  }

  void _rebuildWithCurrentSettings() {
    final preserved = List.of(_signatureController.points);
    final old = _signatureController;
    _signatureController = _buildController(points: preserved);
    old.dispose();
  }

  void _setPenIndex(int index) {
    if (index < 0 || index >= widget.pens.length || index == _penIndex) return;
    setState(() {
      _penIndex = index;
      _rebuildWithCurrentSettings();
    });
  }

  void _setPenColor(Color color) {
    if (color.toARGB32() == _penColor.toARGB32()) return;
    setState(() {
      _penColor = color;
      _rebuildWithCurrentSettings();
    });
  }

  void _clear() {
    setState(_signatureController.clear);
    widget.onChanged?.call();
  }

  void _undo() {
    setState(_signatureController.undo);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final pen = _currentPen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [_penTypeSelector(), _penCurrentChip(pen), _penColorRow()],
        ),
        if (widget.showDescription) ...[
          const SizedBox(height: 8),
          Text(
            pen.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          height: widget.canvasHeight,
          decoration: BoxDecoration(
            color: widget.canvasColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.secondaryLight.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Signature(
            controller: _signatureController,
            backgroundColor: Colors.transparent,
          ),
        ),
        if (widget.showClearButton || widget.showUndoButton) ...[
          Row(
            children: [
              if (widget.showClearButton)
                Expanded(
                  child: _padButton(
                    label: 'Clear Signature',
                    icon: Icons.delete_outline_rounded,
                    onPressed: _clear,
                  ),
                ),
              if (widget.showClearButton && widget.showUndoButton)
                const SizedBox(width: 10),
              if (widget.showUndoButton)
                Expanded(
                  child: _padButton(
                    label: 'Undo Last Stroke',
                    icon: Icons.undo_rounded,
                    onPressed: _undo,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _padButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return AppTextLinkButton(
      onPressed: onPressed,
      icon: icon,
      text: label,
      color: AppColors.error,
    );
  }

  Widget _penTypeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.titleSmall('Pen', fontSize: 14),
        const SizedBox(width: 8),
        for (int i = 0; i < widget.pens.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _penIconButton(i),
        ],
      ],
    );
  }

  Widget _penIconButton(int index) {
    final pen = widget.pens[index];
    final selected = _penIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _setPenIndex(index),
      child: Container(
        width: 32,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.secondary
                : AppColors.secondaryLight.withValues(alpha: 0.45),
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Icon(
          pen.icon,
          size: 16,
          color: selected ? AppColors.secondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _penCurrentChip(SignaturePenPreset pen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
      ),
      child: AppText.labelSmall(pen.label, color: AppColors.secondaryDark),
    );
  }

  Widget _penColorRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText.titleSmall('Color', fontSize: 14),
        const SizedBox(width: 8),
        for (int i = 0; i < widget.colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _penColorDot(widget.colors[i]),
        ],
      ],
    );
  }

  Widget _penColorDot(Color color) {
    final selected = _penColor.toARGB32() == color.toARGB32();
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _setPenColor(color),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.secondaryDark : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
      ),
    );
  }
}
