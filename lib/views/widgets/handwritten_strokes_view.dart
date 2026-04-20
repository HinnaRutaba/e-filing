import 'package:efiling_balochistan/models/summaries/summary_movement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HandwrittenStrokesView extends StatelessWidget {
  final HandwrittenStrokes strokes;
  final String? fallbackColor;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const HandwrittenStrokesView({
    super.key,
    required this.strokes,
    this.fallbackColor,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (strokes.strokes.isEmpty) return const SizedBox.shrink();
    return SvgPicture.string(
      strokes.toSvg(fallbackColor: fallbackColor),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
    );
  }
}
