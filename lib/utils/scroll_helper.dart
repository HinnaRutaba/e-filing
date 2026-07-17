import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Scrolls the enclosing scrollable by the smallest amount that brings the
/// widget at [context] fully into view — and no further. A widget that is
/// already visible doesn't move at all.
///
/// [bottomInset] is the height of anything covering the bottom of the viewport
/// that the viewport itself doesn't account for: pass the keyboard height on
/// screens with `resizeToAvoidBottomInset: false`, where the viewport still
/// extends behind the keyboard. Leave it at 0 where the Scaffold already
/// resizes, otherwise the keyboard height gets counted twice.
void ensureFieldVisible(
  BuildContext context, {
  double bottomInset = 0,
  double margin = 8,
  Duration duration = const Duration(milliseconds: 200),
  Curve curve = Curves.easeOut,
}) {
  final renderObject = context.findRenderObject();
  if (renderObject == null || !renderObject.attached) return;

  final position = Scrollable.maybeOf(context)?.position;
  if (position == null ||
      !position.hasPixels ||
      !position.hasContentDimensions) {
    return;
  }

  final viewport = RenderAbstractViewport.maybeOf(renderObject);
  if (viewport == null) return;

  // The two ends of the range of scroll offsets in which the widget is fully
  // visible: at [revealBottom] its bottom edge rests on the viewport's bottom
  // edge, at [revealTop] its top edge rests on the viewport's top edge.
  final revealBottom =
      viewport.getOffsetToReveal(renderObject, 1.0).offset +
      bottomInset +
      margin;
  final revealTop =
      viewport.getOffsetToReveal(renderObject, 0.0).offset - margin;

  var target = position.pixels;
  if (target < revealBottom) target = revealBottom;
  // Applied second so that a widget too tall for the remaining space keeps its
  // top edge on screen rather than being pushed off it.
  if (target > revealTop) target = revealTop;
  target = target.clamp(position.minScrollExtent, position.maxScrollExtent);

  if ((target - position.pixels).abs() < 1) return;
  position.animateTo(target, duration: duration, curve: curve);
}
