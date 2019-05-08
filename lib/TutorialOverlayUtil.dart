import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:synchronized/synchronized.dart';

import 'InvertedClipper.dart';
import 'OverlayPainter.dart';
import 'WidgetData.dart';

OverlayData visibleOverlayPage;

Map<String, OverlayData> _overlays = {};
Map<GlobalKey, Rect> _rectMap = {};
BuildContext _context;
Lock _showOverlayLock = Lock();

bool _debugInfo = false;

bool _doneIt = false;

class OverlayData {
  OverlayEntry entry;
  int enabledVisibleWidgetsCount;
  int disabledVisibleWidgetsCount;
  bool detectWidgetPositionNSizeChanges;
  String tagName;
  List<GlobalKey> widgetsGlobalKeys;

  OverlayData(
      {@required this.entry,
      @required this.tagName,
      this.widgetsGlobalKeys,
      this.enabledVisibleWidgetsCount = 0,
      this.disabledVisibleWidgetsCount = 0,
      this.detectWidgetPositionNSizeChanges = true});
}

void _detectWidgetPositionNSizeChange() {
  var bindings = WidgetsFlutterBinding.ensureInitialized();
  bindings.addPersistentFrameCallback((d) {
    if (visibleOverlayPage != null &&
        (visibleOverlayPage.disabledVisibleWidgetsCount +
                visibleOverlayPage.enabledVisibleWidgetsCount >
            0)) {
      for (final widgetGlobalKey in visibleOverlayPage.widgetsGlobalKeys) {
        if (_sizeVisitor(widgetGlobalKey)) {
          redrawCurrentOverlay();
          break;
        }
      }
    }
  });
}

bool _sizeVisitor(GlobalKey elementKey) {
  if (elementKey.currentContext != null) {
    final RenderBox renderBox = elementKey.currentContext.findRenderObject();
    bool isChanged = false;
    Rect newRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    _rectMap.update(elementKey, (oldRect) {
      if (newRect != oldRect) {
        isChanged = true;
      }
      return newRect;
    }, ifAbsent: () => newRect);
    return isChanged;
  } else {
    return false;
  }
}

_printIfDebug(String funcName, String str) {
  if (_debugInfo) {
    print("$funcName: $str");
  }
}

void redrawCurrentOverlay() {
  if (visibleOverlayPage != null) {
    _printIfDebug('redrawCurrentOverlay',"tag ${visibleOverlayPage.tagName}");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      visibleOverlayPage.entry.remove();
      Overlay.of(_context).insert(visibleOverlayPage.entry);
    });
  } else {
    _printIfDebug('redrawCurrentOverlay','called with empty tag');
  }
}

void _showOverlayEntry(BuildContext context, String tagName)  {
  _printIfDebug('_showOverlayEntry',"for tag $tagName");
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!_doneIt) {
      _doneIt = true;
      _detectWidgetPositionNSizeChange();
    }
  });

  if (visibleOverlayPage == null || visibleOverlayPage.tagName != tagName) {
    _printIfDebug('_showOverlayEntry',"tagname null or differs from current");
    _context = context;
    // ignore if tag name already displayed
    if (!_overlays.containsKey(tagName)) {
      throw new Exception("tag name '$tagName' for overlay does not exists!");
    }

    if (visibleOverlayPage == null ||
        visibleOverlayPage.tagName != tagName) {
      hideOverlayEntryIfExists();
      Overlay.of(context).insert(_overlays[tagName].entry);
      visibleOverlayPage = _overlays[tagName];
    }
  }
  _printIfDebug('_showOverlayEntry', 'function completed');
}

void showOverlayEntry(BuildContext context, String tagName) async {
  SchedulerBinding.instance.addPostFrameCallback((d)=>
  _showOverlayLock.synchronized(()=>
      _showOverlayEntry(context,tagName)
  )
  );
}

void hideOverlayEntryIfExists() {
  if (visibleOverlayPage != null) {
    _printIfDebug('hideOverlayEntryIfExists', "found tag ${visibleOverlayPage.tagName}");
    _overlays[visibleOverlayPage.tagName].entry.remove();
    visibleOverlayPage = null;
  }
}

Future waitForFrameToEnd() async {
  Completer completer = new Completer();
  SchedulerBinding.instance.addPostFrameCallback((_) => completer.complete());
  return completer.future;
}

void createTutorialOverlayIfNotExists(
    {@required String tagName,
    List<WidgetData> widgetsData = const [],
    Function onTap,
    Color bgColor,
    Widget description}) {
  if (!_overlays.containsKey(tagName)) {
    createTutorialOverlay(
        tagName: tagName,
        widgetsData: widgetsData,
        onTap: onTap,
        bgColor: bgColor,
        description: description);
  }
}

void createTutorialOverlay(
    {@required String tagName,
    List<WidgetData> widgetsData = const [],
    Function onTap,
    Color bgColor,
    Widget description}) {
  _printIfDebug('createTutorialOverlay', "starteed for tag $tagName");
  if (visibleOverlayPage != null && visibleOverlayPage.tagName == tagName) {
    // removes shown overlay if it's beiong rewritten
    hideOverlayEntryIfExists();
  }
  int enabledVisibleWidgetsCount = 0;
  int disabledVisibleWidgetsCount = 0;
  List<GlobalKey> widgetsGlobalKeys = [];
  widgetsData.forEach((WidgetData data) {
    widgetsGlobalKeys.add(data.key);
    if (data.isEnabled) {
      enabledVisibleWidgetsCount++;
    } else {
      disabledVisibleWidgetsCount++;
    }
  });
  _overlays[tagName] = OverlayData(
      widgetsGlobalKeys: widgetsGlobalKeys,
      enabledVisibleWidgetsCount: enabledVisibleWidgetsCount,
      disabledVisibleWidgetsCount: disabledVisibleWidgetsCount,
      tagName: tagName,
      entry: OverlayEntry(builder: (BuildContext context) =>
      FutureBuilder(
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
                  ))))
      ));
}

