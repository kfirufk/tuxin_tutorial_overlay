import 'package:flutter/material.dart';

class HoleArea {
  double x, y, width, height;
  HoleArea({this.x, this.y, this.width, this.height});
}

HoleArea getHoleArea(GlobalKey key) {
  final RenderBox renderBoxRed = key.currentContext.findRenderObject();
  final Offset position = renderBoxRed.localToGlobal(Offset.zero);
  final Size size = renderBoxRed.size;
  return HoleArea(
      height: size.height, width: size.width, x: position.dx, y: position.dy);
}
