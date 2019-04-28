import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'InvertedClipper.dart';
import 'OverlayPainter.dart';
import 'WidgetData.dart';

void showOverlayEntry(BuildContext context, OverlayEntry entry) {
  Overlay.of(context).insert(entry);
}

void removeOverlayEntry(OverlayEntry entry) {
  entry.remove();
}

Future waitForFrameToEnd() async {
  Completer completer = new Completer();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    completer.complete();
  });
  return completer.future;
}

OverlayEntry createTutorialOverlay(
    {List<WidgetData> widgetsData = const [],
    Function onTap,
    Color bgColor,
    Widget description}) {
  return OverlayEntry(
      builder: (BuildContext context) => FutureBuilder(
          future: waitForFrameToEnd(),
          builder: (BuildContext context, AsyncSnapshot snapshot) =>
              GestureDetector(
                  onTap: onTap,
                  child: ClipPath(
                      clipper: InvertedClipper(widgetsData: widgetsData),
                      child: CustomPaint(
                        child: Container(
                          child: description,
                        ),
                        painter: OverlayPainter(
                            bgColor: bgColor,
                            context: context,
                            widgetsData: widgetsData),
                      )))));
}
