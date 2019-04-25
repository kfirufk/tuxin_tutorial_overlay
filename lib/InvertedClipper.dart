import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'HoleArea.dart';

class InvertedClipper extends CustomClipper<Path> {
  final List<HoleArea> areas;
  double padding;
  Function deepEq = const DeepCollectionEquality().equals;


  InvertedClipper({this.areas,this.padding=4});

  @override
  Path getClip(Size size) {
    Path path = Path();
    areas.forEach((HoleArea area) {
      path.addOval(Rect.fromLTWH(area.x-(padding/2),area.y-padding/2,area.width+padding,area.height+padding));
    });
    return path
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(InvertedClipper oldClipper) {
    return oldClipper.padding != padding || (!deepEq(oldClipper.areas,areas));
  }
}
