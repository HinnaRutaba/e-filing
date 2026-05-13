import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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

enum SignatureColor {
  darkBlue,
  black,
  darkGreen,
  darkRed;

  Color get color => kDefaultSignatureColors[index];
}

// Internal stroke representation — one object per pen-down→pen-up gesture.
class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
  _Stroke({required this.points, required this.color, required this.width});
}

class SignaturePadController {
  _SignaturePadState? _state;

  void _attach(_SignaturePadState state) => _state = state;
  void _detach(_SignaturePadState state) {
    if (_state == state) _state = null;
  }

  bool get isEmpty => (_state?._strokes.isEmpty ?? true) &&
      (_state?._currentStroke == null);
  bool get isNotEmpty => !isEmpty;

  Color get penColor => _state?._penColor ?? kDefaultSignatureColors.first;
  int get penIndex => _state?._penIndex ?? 0;
  SignaturePenPreset get currentPen =>
      _state?._currentPen ?? kDefaultSignaturePens.first;

  double get canvasHeight => _state?._canvasHeight ?? 280.0;

  String get penColorHex =>
      _hexFromColor(_state?._penColor ?? kDefaultSignatureColors.first);

  Future<Uint8List?> toPngBytes() async {
    final s = _state;
    if (s == null || (s._strokes.isEmpty && s._currentStroke == null)) {
      return null;
    }
    return s._renderToPng();
  }

  String? toStrokesJson({required double canvasWidth}) {
    final s = _state;
    if (s == null || s._strokes.isEmpty) return null;

    final strokes = s._strokes.map((stroke) {
      return {
        'color': _hexFromColor(stroke.color),
        'widthRange': [stroke.width],
        'points': stroke.points.map((p) => {
          'x': p.dx,
          'y': p.dy,
          'p': 0.5,
          't': null,
        }).toList(),
      };
    }).toList();

    return jsonEncode({
      'w': canvasWidth,
      'h': s._canvasHeight,
      'strokes': strokes,
    });
  }

  static String _hexFromColor(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
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
  final SignatureColor initialPenColor;
  final int initialPenIndex;
  final double? canvasHeight;
  final Color canvasColor;
  final VoidCallback? onChanged;
  final VoidCallback? onDrawStart;
  final VoidCallback? onDrawEnd;
  final bool showClearButton;
  final bool showUndoButton;
  final bool showDescription;
  final bool showPenSelector;
  final bool showRuledLines;
  final bool autoExpand;
  final double autoExpandStep;
  final bool showStrokeInfo;
  final bool showCustomColorPicker;
  final VoidCallback? onExpand;

  const SignaturePad({
    super.key,
    this.controller,
    this.pens = kDefaultSignaturePens,
    this.colors = kDefaultSignatureColors,
    this.initialPenColor = SignatureColor.darkBlue,
    this.initialPenIndex = 2,
    this.canvasHeight,
    this.canvasColor = AppColors.cardColorLight,
    this.onChanged,
    this.onDrawStart,
    this.onDrawEnd,
    this.showClearButton = true,
    this.showUndoButton = true,
    this.showDescription = true,
    this.showPenSelector = true,
    this.showRuledLines = false,
    this.autoExpand = false,
    this.autoExpandStep = 120,
    this.showStrokeInfo = false,
    this.showCustomColorPicker = false,
    this.onExpand,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late int _penIndex;
  late Color _penColor;
  late double _canvasHeight;
  int _strokeCount = 0;

  // Completed strokes + the stroke currently being drawn.
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;

  SignaturePenPreset get _currentPen => widget.pens[_penIndex];

  @override
  void initState() {
    super.initState();
    _penIndex = widget.initialPenIndex.clamp(0, widget.pens.length - 1);
    _penColor = widget.initialPenColor.color;
    _canvasHeight = widget.canvasHeight ?? 280;
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
    super.dispose();
  }

  // ── pointer handlers ──────────────────────────────────────────────────────

  void _onPointerDown(PointerDownEvent e) {
    setState(() {
      _currentStroke = _Stroke(
        points: [e.localPosition],
        color: _penColor,
        width: _currentPen.width,
      );
    });
    widget.onDrawStart?.call();
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_currentStroke == null) return;
    // Mutate in place and trigger a repaint — avoids allocating a new list
    // on every pointer event.
    _currentStroke!.points.add(e.localPosition);
    setState(() {});
  }

  void _onPointerUp(PointerUpEvent e) {
    _finishStroke();
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _finishStroke();
  }

  void _finishStroke() {
    final stroke = _currentStroke;
    if (stroke == null) return;
    setState(() {
      _currentStroke = null;
      if (stroke.points.isNotEmpty) {
        _strokes.add(stroke);
        if (widget.showStrokeInfo) _strokeCount++;
      }
    });
    widget.onDrawEnd?.call();
    widget.onChanged?.call();
    if (widget.autoExpand) {
      final allPoints = _strokes.expand((s) => s.points);
      if (allPoints.isNotEmpty) {
        final maxY = allPoints.map((p) => p.dy).reduce(math.max);
        if (maxY > _canvasHeight - 60) {
          setState(() => _canvasHeight += widget.autoExpandStep);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onExpand?.call();
          });
        }
      }
    }
  }

  // ── controller API ────────────────────────────────────────────────────────

  Future<Uint8List?> _renderToPng() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, _canvasWidth, _canvasHeight),
    );
    _SignaturePainter(
      strokes: _strokes,
      currentStroke: _currentStroke,
    ).paint(canvas, Size(_canvasWidth, _canvasHeight));
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      _canvasWidth.round(),
      _canvasHeight.round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  double _canvasWidth = 0;

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Signature'),
        content: const Text('Are you sure you want to clear all strokes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _strokeCount = 0;
      if (widget.autoExpand) _canvasHeight = widget.canvasHeight ?? 280;
    });
    widget.onChanged?.call();
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      if (widget.showStrokeInfo && _strokeCount > 0) _strokeCount--;
    });
    widget.onChanged?.call();
  }

  void _setPenIndex(int index) {
    if (index < 0 || index >= widget.pens.length || index == _penIndex) return;
    setState(() => _penIndex = index);
  }

  void _setPenColor(Color color) {
    if (color.toARGB32() == _penColor.toARGB32()) return;
    setState(() => _penColor = color);
  }

  // ── build ─────────────────────────────────────────────────────────────────

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
          children: [
            if (widget.showPenSelector) _penTypeSelector(),
            if (widget.showPenSelector) _penCurrentChip(pen),
            _penColorRow(),
          ],
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
        LayoutBuilder(
          builder: (context, constraints) {
            _canvasWidth = constraints.maxWidth;
            return Container(
              height: widget.autoExpand
                  ? _canvasHeight
                  : (widget.canvasHeight ??
                        MediaQuery.sizeOf(context).height * 0.2),
              decoration: BoxDecoration(
                color: widget.canvasColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.secondaryLight.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              // ImmediateMultiDragGestureRecognizer wins the arena instantly,
              // preventing the parent ScrollView from stealing the gesture.
              // Listener handles actual drawing with zero latency.
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  ImmediateMultiDragGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          ImmediateMultiDragGestureRecognizer>(
                    () => ImmediateMultiDragGestureRecognizer(),
                    (instance) {
                      instance.onStart = (_) => _DrawDrag();
                    },
                  ),
                },
                child: Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: _onPointerUp,
                  onPointerCancel: _onPointerCancel,
                  behavior: HitTestBehavior.opaque,
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                      showRuledLines: widget.showRuledLines,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showClearButton || widget.showUndoButton) ...[
          Row(
            children: [
              if (widget.showClearButton)
                Expanded(
                  child: _padButton(
                    label: 'Clear All',
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: AppText.titleSmall('Pen', fontSize: 14),
        ),
        for (int i = 0; i < widget.pens.length; i++) _penIconButton(i),
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: AppText.titleSmall('Color', fontSize: 14),
        ),
        for (int i = 0; i < widget.colors.length; i++)
          _penColorDot(widget.colors[i]),
        if (widget.showCustomColorPicker)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _showColorPickerDialog,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondaryLight.withValues(alpha: 0.6),
                ),
                gradient: const SweepGradient(
                  colors: [
                    Colors.red,
                    Colors.yellow,
                    Colors.green,
                    Colors.cyan,
                    Colors.blue,
                    Colors.purple,
                    Colors.red,
                  ],
                ),
              ),
              child: const Icon(Icons.add, size: 12, color: Colors.white),
            ),
          ),
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

  Future<void> _showColorPickerDialog() async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => _FullColorPickerDialog(initialColor: _penColor),
    );
    if (picked != null) _setPenColor(picked);
  }
}

// Minimal Drag implementation — its only job is to win the gesture arena so the
// parent ScrollView cannot scroll while the user draws on the canvas.
class _DrawDrag extends Drag {
  @override
  void update(DragUpdateDetails details) {}
  @override
  void end(DragEndDetails details) {}
  @override
  void cancel() {}
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _SignaturePainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? currentStroke;
  final bool showRuledLines;

  const _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    this.showRuledLines = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showRuledLines) _paintRuledLines(canvas, size);
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    if (currentStroke != null) _paintStroke(canvas, currentStroke!);
  }

  void _paintStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      // Single tap — draw a dot.
      canvas.drawCircle(
        stroke.points.first,
        stroke.width / 2,
        Paint()..color = stroke.color,
      );
      return;
    }

    // Smooth with quadratic bezier between midpoints for natural pen feel.
    final path = Path()..moveTo(stroke.points[0].dx, stroke.points[0].dy);
    for (int i = 1; i < stroke.points.length - 1; i++) {
      final mid = Offset(
        (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
        (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(
        stroke.points[i].dx,
        stroke.points[i].dy,
        mid.dx,
        mid.dy,
      );
    }
    final last = stroke.points.last;
    path.lineTo(last.dx, last.dy);
    canvas.drawPath(path, paint);
  }

  static const double _lineSpacing = 54;
  static const Color _lineColor = Color(0xFFDDE3F0);

  void _paintRuledLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _lineColor
      ..strokeWidth = 0.8;
    for (double y = _lineSpacing; y < size.height; y += _lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      !identical(old.strokes, strokes) || old.currentStroke != currentStroke;
}

// ── Full colour picker dialog ─────────────────────────────────────────────────

class _FullColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const _FullColorPickerDialog({required this.initialColor});

  @override
  State<_FullColorPickerDialog> createState() => _FullColorPickerDialogState();
}

class _FullColorPickerDialogState extends State<_FullColorPickerDialog> {
  late Color _selected;

  static const List<List<Color>> _palette = [
    [
      Color(0xFF7F1D1D),
      Color(0xFFB91C1C),
      Color(0xFFEF4444),
      Color(0xFFFCA5A5),
    ],
    [
      Color(0xFF7C2D12),
      Color(0xFFEA580C),
      Color(0xFFFB923C),
      Color(0xFFFED7AA),
    ],
    [
      Color(0xFF713F12),
      Color(0xFFCA8A04),
      Color(0xFFFACC15),
      Color(0xFFFEF08A),
    ],
    [
      Color(0xFF14532D),
      Color(0xFF15803D),
      Color(0xFF4ADE80),
      Color(0xFFBBF7D0),
    ],
    [
      Color(0xFF164E63),
      Color(0xFF0E7490),
      Color(0xFF22D3EE),
      Color(0xFFA5F3FC),
    ],
    [
      Color(0xFF1E3A5F),
      Color(0xFF1D4ED8),
      Color(0xFF60A5FA),
      Color(0xFFBFDBFE),
    ],
    [
      Color(0xFF4C1D95),
      Color(0xFF7C3AED),
      Color(0xFFA78BFA),
      Color(0xFFEDE9FE),
    ],
    [
      Color(0xFF831843),
      Color(0xFFBE185D),
      Color(0xFFF472B6),
      Color(0xFFFCE7F3),
    ],
    [
      Color(0xFF111827),
      Color(0xFF374151),
      Color(0xFF9CA3AF),
      Color(0xFFE5E7EB),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Pick a Color',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in _palette)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    for (final color in row)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = color),
                          child: Container(
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _selected.toARGB32() == color.toARGB32()
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow:
                                  _selected.toARGB32() == color.toARGB32()
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: _selected.toARGB32() == color.toARGB32()
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selected,
            foregroundColor: Colors.white,
          ),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
