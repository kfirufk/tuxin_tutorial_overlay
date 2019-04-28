import 'package:flutter/material.dart';

enum WidgetShape { Oval, Rect, RRect }

class WidgetData {
  GlobalKey key;
  WidgetShape shape;
  bool isEnabled;
  double padding;

  WidgetData(
      {@required this.key,
      this.shape = WidgetShape.Oval,
      this.isEnabled = true,
      this.padding = 0});
}
