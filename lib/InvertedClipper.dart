import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'HoleArea.dart';
import 'WidgetData.dart';

class InvertedClipper extends CustomClipper<Path> {

  final Animation<double> _animation;
  final List<WidgetData> widgetsData;
  Function deepEq = const DeepCollectionEquality().equals;
  List<HoleArea> areas = [];

  InvertedClipper(this._animation, Listenable reclip,
      {this.widgetsData}) : super(reclip: reclip) {
    if (widgetsData.isNotEmpty) {
      widgetsData.forEach((WidgetData widgetData) {
        if (widgetData.isEnabled) {
          final GlobalKey key = widgetData.key;
          if (key == null) {
        //    throw new Exception("GlobalKey is null!");
          } else if (key.currentWidget == null) {
//            throw new Exception("GlobalKey is not assigned to a Widget!");
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
          path.addOval(Rect.fromLTWH(area.x - ((area.padding + _animation.value*15) / 2), area.y - (area.padding + _animation.value*15) / 2,
              area.width + (area.padding + _animation.value*15), area.height + (area.padding + _animation.value*15)));
        }
        break;
        case WidgetShape.Rect: {
          path.addRect(Rect.fromLTWH(area.x - ((area.padding + _animation.value*15) / 2), area.y - (area.padding + _animation.value*15) / 2,
              area.width + (area.padding + _animation.value*15), area.height + (area.padding + _animation.value*15)));
        }
        break;
        case WidgetShape.RRect: {
          path.addRRect(RRect.fromRectAndCorners(Rect.fromLTWH(area.x - ((area.padding + _animation.value*15) / 2), area.y - (area.padding + _animation.value*15) / 2,
              area.width + (area.padding + _animation.value*15), area.height + (area.padding + _animation.value*15)),
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
