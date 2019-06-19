import 'package:flutter/material.dart';
import 'WidgetData.dart';

class HoleArea {
  double x, y, width, height, padding;
  WidgetShape shape;
  HoleArea(
      {this.x,
      this.y,
      this.width,
      this.height,
      this.shape = WidgetShape.Oval,
      this.padding});
}

HoleArea getHoleArea({GlobalKey key, WidgetShape shape, double padding}) {
  final RenderBox renderBoxRed = key.currentContext.findRenderObject();
  final Offset position = renderBoxRed.localToGlobal(Offset.zero);
  final Size size = renderBoxRed.size;
  return HoleArea(
      height: size.height,
      width: size.width,
      x: position.dx,
      y: position.dy,
      shape: shape,
      padding: padding);
}
