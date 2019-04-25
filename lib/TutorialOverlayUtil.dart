import 'package:flutter/material.dart';
import 'OverlayPainter.dart';
import 'InvertedClipper.dart';
import 'HoleArea.dart';


void showOverlayEntry(BuildContext context, OverlayEntry entry) {
  Overlay.of(context).insert(entry);
}

void removeOverlayEntry(OverlayEntry entry) {
  entry.remove();
}

OverlayEntry createTutorialOverlay({@required BuildContext context, 
    List<GlobalKey> enabledKeys = const[],
    List<GlobalKey> disabledKeys = const[],
Widget description}) {
  List<HoleArea> enabledAreas = [];
  List<HoleArea> disabledAreas = [];
  if (enabledKeys.isNotEmpty) {
    enabledKeys.forEach((key) {
      if (key == null) {
        throw new Exception("GlobalKey is null!");
      } else if (key.currentWidget == null) {
        throw new Exception("GlobalKey is not assigned to a Widget!");
      } else {
        enabledAreas.add(getHoleArea(key));
      }
    });
  }
  if (disabledKeys.isNotEmpty) {
    disabledKeys.forEach((key) {
      if (key == null) {
        throw new Exception("GlobalKey is null!");
      } else if (key.currentWidget == null) {
        throw new Exception("GlobalKey is not assigned to a Widget!");
      }
      else {
        disabledAreas.add(getHoleArea(key));
      }
    });
  }

  return OverlayEntry(
    builder: (BuildContext context) =>
        ClipPath(
            clipper: InvertedClipper(areas: enabledAreas),
            child: CustomPaint(
              child: Container(
                child: description,
              ),
              painter: OverlayPainter(context: context, areas: disabledAreas),
            )
        ),
  );
}

