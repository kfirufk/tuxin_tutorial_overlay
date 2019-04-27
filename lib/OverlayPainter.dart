import 'dart:ui';
import 'package:flutter/material.dart';
import 'HoleArea.dart';

Color colorBlack = Colors.black.withOpacity(0.4);

class OverlayPainter extends CustomPainter{
  BuildContext context;
  List<HoleArea> areas;
  List<GlobalKey> keys;
  double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    Path path = Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight));
    areas.forEach((area){
      path = Path.combine(PathOperation.difference,
          path,
          Path()
            ..addOval(Rect.fromLTWH(area.x-(padding/2),area.y-padding/2,area.width+padding,area.height+padding)));
    });

    canvas.drawPath(path,
        Paint()..color = colorBlack);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  OverlayPainter({this.context,this.keys,this.padding=4}){
    areas = [];
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
}