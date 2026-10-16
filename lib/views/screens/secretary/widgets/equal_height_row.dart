import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Lays [children] side by side in equal-width columns and makes them all as
/// tall as the tallest one, so cards of different heights end flush.
///
/// Unlike `IntrinsicHeight`, it measures with a real layout pass, so children
/// containing a `LayoutBuilder` (e.g. the donut chart) are fine.
class EqualHeightRow extends MultiChildRenderObjectWidget {
  const EqualHeightRow({super.key, this.spacing = 16, required super.children});

  final double spacing;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderEqualHeightRow(spacing);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderEqualHeightRow).spacing = spacing;
  }
}

class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  _RenderEqualHeightRow(this._spacing);

  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightParentData) {
      child.parentData = _EqualHeightParentData();
    }
  }

  @override
  void performLayout() {
    final count = childCount;
    if (count == 0) {
      size = constraints.smallest;
      return;
    }
    final colWidth = (constraints.maxWidth - _spacing * (count - 1)) / count;

    // Pass 1: natural heights.
    var height = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        BoxConstraints.tightFor(width: colWidth),
        parentUsesSize: true,
      );
      height = math.max(height, child.size.height);
    }

    // Pass 2: everyone at the tallest height.
    var x = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(
        BoxConstraints.tightFor(width: colWidth, height: height),
        parentUsesSize: true,
      );
      (child.parentData! as _EqualHeightParentData).offset = Offset(x, 0);
      x += colWidth + _spacing;
    }
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
