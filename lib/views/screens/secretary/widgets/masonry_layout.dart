import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Lays [children] out in [columns] equal-width columns, putting each child in
/// whichever column is currently shortest (measured, not estimated), so cards
/// of different heights don't leave gaps. Order is kept within a column.
/// Height wraps the tallest column, so it works inside a scroll view.
class MasonryLayout extends MultiChildRenderObjectWidget {
  const MasonryLayout({
    super.key,
    required this.columns,
    this.spacing = 16,
    required super.children,
  });

  final int columns;
  final double spacing;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMasonry(columns: columns, spacing: spacing);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderMasonry)
      ..columns = columns
      ..spacing = spacing;
  }
}

class _MasonryParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderMasonry extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MasonryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _MasonryParentData> {
  _RenderMasonry({required int columns, required double spacing})
    : _columns = columns,
      _spacing = spacing;

  int _columns;
  int get columns => _columns;
  set columns(int value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
  }

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MasonryParentData) {
      child.parentData = _MasonryParentData();
    }
  }

  double _columnWidth(double maxWidth) {
    final n = math.max(1, _columns);
    return (maxWidth - _spacing * (n - 1)) / n;
  }

  /// Places every child, returning the total height. [layoutChild] sizes a
  /// child for the given column width; [place] records its offset.
  double _arrange(
    double maxWidth,
    Size Function(RenderBox child, BoxConstraints c) layoutChild,
    void Function(RenderBox child, Offset offset) place,
  ) {
    final n = math.max(1, _columns);
    final colWidth = _columnWidth(maxWidth);
    final heights = List<double>.filled(n, 0);
    final counts = List<int>.filled(n, 0);
    final constraints = BoxConstraints(minWidth: colWidth, maxWidth: colWidth);

    for (var child = firstChild; child != null; child = childAfter(child)) {
      var target = 0;
      for (var c = 1; c < n; c++) {
        if (heights[c] < heights[target]) target = c;
      }
      final size = layoutChild(child, constraints);
      final dy = counts[target] == 0
          ? heights[target]
          : heights[target] + _spacing;
      place(child, Offset(target * (colWidth + _spacing), dy));
      heights[target] = dy + size.height;
      counts[target]++;
    }
    return heights.fold<double>(0, math.max);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final height = _arrange(
      constraints.maxWidth,
      (child, c) => child.getDryLayout(c),
      (_, __) {},
    );
    return constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void performLayout() {
    final height = _arrange(
      constraints.maxWidth,
      (child, c) {
        child.layout(c, parentUsesSize: true);
        return child.size;
      },
      (child, offset) =>
          (child.parentData! as _MasonryParentData).offset = offset,
    );
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
