import 'dart:ui';

import 'package:flutter/material.dart';

import 'HoleArea.dart';
import 'WidgetData.dart';

Color colorBlack = Colors.black.withOpacity(0.4);

class OverlayPainter extends CustomPainter {
  final Animation<double> animation;

  BuildContext context;
  List<HoleArea> areas;
  List<WidgetData> widgetsData;
  Color bgColor;
  double padding;

  @override
  void paint(Canvas canvas, Size size) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    Path path = Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight));
    double animationValue = animation != null ? animation.value : 0;

    areas.forEach((area) {
      switch (area.shape) {
        case WidgetShape.Oval:
          {
            path = Path.combine(
                PathOperation.difference,
                path,
                Path()
                  ..addOval(Rect.fromLTWH(
                      area.x -
                          (((area.padding + padding) + animationValue * 15) /
                              2),
                      area.y -
                          ((area.padding + padding) + animationValue * 15) / 2,
                      area.width +
                          ((area.padding + padding) + animationValue * 15),
                      area.height +
                          ((area.padding + padding) + animationValue * 15))));
          }
          break;
        case WidgetShape.Rect:
          {
            path = Path.combine(
                PathOperation.difference,
                path,
                Path()
                  ..addRect(Rect.fromLTWH(
                      area.x -
                          (((area.padding + padding) + animationValue * 15) /
                              2),
                      area.y -
                          ((area.padding + padding) + animationValue * 15) / 2,
                      area.width +
                          ((area.padding + padding) + animationValue * 15),
                      area.height +
                          ((area.padding + padding) + animationValue * 15))));
          }
          break;
        case WidgetShape.RRect:
          {
            path = Path.combine(
                PathOperation.difference,
                path,
                Path()
                  ..addRRect(RRect.fromRectAndCorners(
                      Rect.fromLTWH(
                          area.x -
                              (((area.padding + padding) +
                                      animationValue * 15) /
                                  2),
                          area.y -
                              ((area.padding + padding) + animationValue * 15) /
                                  2,
                          area.width +
                              ((area.padding + padding) + animationValue * 15),
                          area.height +
                              ((area.padding + padding) + animationValue * 15)),
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0))));
          }
          break;
      }
    });

    canvas.drawPath(path, Paint()..color = bgColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  OverlayPainter(
      {@required this.padding,
      this.animation,
      this.context,
      this.widgetsData,
      this.bgColor})
      : super(repaint: animation) {
    areas = [];
    if (this.bgColor == null) {
      this.bgColor = colorBlack;
    }
    if (widgetsData.isNotEmpty) {
      widgetsData.forEach((widgetData) {
        if (!widgetData.isEnabled) {
          final GlobalKey key = widgetData.key;
          if (key == null) {
            //throw new Exception("GlobalKey is null!");
          } else if (key.currentWidget == null) {
            //throw new Exception("GlobalKey is not assigned to a Widget!");
          } else {
            areas.add(getHoleArea(
                key: key,
                padding: widgetData.padding,
                shape: widgetData.shape));
          }
        }
      });
    }
  }
}
