import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'HoleArea.dart';

class InvertedClipper extends CustomClipper<Path> {
  final List<GlobalKey> keys;
  double padding;
  Function deepEq = const DeepCollectionEquality().equals;
  List<HoleArea> areas = [];

  InvertedClipper({this.keys, this.padding = 4}) {
    if (keys.isNotEmpty) {
      keys.forEach((key) {
        if (key == null) {
          throw new Exception("GlobalKey is null!");
        } else if (key.currentWidget == null) {
          throw new Exception("GlobalKey is not assigned to a Widget!");
        } else {
          areas.add(getHoleArea(key));
        }
      });
    }
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    areas.forEach((HoleArea area) {
      path.addOval(Rect.fromLTWH(area.x - (padding / 2), area.y - padding / 2,
          area.width + padding, area.height + padding));
    });
    return path
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(InvertedClipper oldClipper) {
    return oldClipper.padding != padding || (!deepEq(oldClipper.areas, areas));
  }
}
