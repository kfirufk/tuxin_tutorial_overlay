import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'HoleArea.dart';
import 'WidgetData.dart';

class InvertedClipper extends CustomClipper<Path> {
  final List<WidgetData> widgetsData;
  Function deepEq = const DeepCollectionEquality().equals;
  List<HoleArea> areas = [];

  InvertedClipper({this.widgetsData}) {
    if (widgetsData.isNotEmpty) {
      widgetsData.forEach((WidgetData widgetData) {
        if (widgetData.isEnabled) {
          final GlobalKey key = widgetData.key;
          if (key == null) {
            throw new Exception("GlobalKey is null!");
          } else if (key.currentWidget == null) {
            throw new Exception("GlobalKey is not assigned to a Widget!");
          } else {
            areas.add(getHoleArea(key: key,shape: widgetData.shape,padding: widgetData.padding));
          }
        }
      });
    }
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    areas.forEach((HoleArea area) {
      switch (area.shape) {
        case WidgetShape.Oval: {
          path.addOval(Rect.fromLTWH(area.x - (area.padding / 2), area.y - area.padding / 2,
              area.width + area.padding, area.height + area.padding));
        }
        break;
        case WidgetShape.Rect: {
          path.addRect(Rect.fromLTWH(area.x - (area.padding / 2), area.y - area.padding / 2,
              area.width + area.padding, area.height + area.padding));
        }
        break;
        case WidgetShape.RRect: {
          path.addRRect(RRect.fromRectAndCorners(Rect.fromLTWH(area.x - (area.padding / 2), area.y - area.padding / 2,
              area.width + area.padding, area.height + area.padding),
              topLeft: Radius.circular(5.0),
              topRight: Radius.circular(5.0),
              bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0)));
        }
        break;
      }
    });
    return path
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(InvertedClipper oldClipper) {
    return !deepEq(oldClipper.areas, areas);
  }
}
