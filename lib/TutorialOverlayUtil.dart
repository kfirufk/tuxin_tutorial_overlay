import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'OverlayPainter.dart';
import 'InvertedClipper.dart';

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
    {@required BuildContext context,
    List<GlobalKey> enabledKeys = const [],
    List<GlobalKey> disabledKeys = const [],
    Widget description}) {
  return OverlayEntry(
      builder: (BuildContext context1) => FutureBuilder(
          future: waitForFrameToEnd(),
          builder: (BuildContext context, AsyncSnapshot snapshot) => ClipPath(
              clipper: InvertedClipper(keys: enabledKeys),
              child: CustomPaint(
                child: Container(
                  child: description,
                ),
                painter: OverlayPainter(context: context, keys: disabledKeys),
              ))));
}
