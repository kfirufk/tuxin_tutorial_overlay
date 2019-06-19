import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:synchronized/synchronized.dart';

import 'InvertedClipper.dart';
import 'OverlayPainter.dart';
import 'WidgetData.dart';

import 'package:uuid/uuid.dart';

typedef TutorialOverlayHook = void Function(String);

TutorialOverlayHook showOverlayHook;
TutorialOverlayHook hideOverlayHook;

OverlayData visibleOverlayPage;

Map<String, OverlayData> _overlays = {};
Map<GlobalKey, Rect> _rectMap = {};
Lock _showOverlayLock = Lock();

final uuid = new Uuid();

bool _debugInfo = false;
bool _doneIt = false;

class OverlayData {
  OverlayEntry entry;
  int enabledVisibleWidgetsCount;
  int disabledVisibleWidgetsCount;
  bool detectWidgetPositionNSizeChanges;
  String tagName;
  BuildContext context;
  AnimationController animationController;
  List<GlobalKey> widgetsGlobalKeys;
  Function hideOverlay;
  Function showOverlay;
  String uuid;
  bool isOverlayBgTransparent;

  OverlayData(
      {@required this.entry,
      @required this.tagName,
      @required this.context,
      @required this.hideOverlay,
      @required this.showOverlay,
      @required this.uuid,
      this.widgetsGlobalKeys,
      this.animationController,
      this.enabledVisibleWidgetsCount = 0,
      this.disabledVisibleWidgetsCount = 0,
      this.detectWidgetPositionNSizeChanges = true,
      this.isOverlayBgTransparent = false});
}

void setTutorialShowOverlayHook(TutorialOverlayHook func) {
  showOverlayHook = func;
}

void setTutorialHideOverlayHook(TutorialOverlayHook func) {
  hideOverlayHook = func;
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
    _printIfDebug('redrawCurrentOverlay', "tag ${visibleOverlayPage.tagName}");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showOverlayEntry(
          tagName: visibleOverlayPage.tagName,
          redisplayOverlayIfSameTAgName: true);
    });
  } else {
    _printIfDebug('redrawCurrentOverlay', 'called with empty tag');
  }
}

void _showOverlayEntry(
    {String tagName, bool redisplayOverlayIfSameTAgName = false}) {
  _printIfDebug('_showOverlayEntry', "for tag $tagName");
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (!_doneIt) {
      _doneIt = true;
      _detectWidgetPositionNSizeChange();
    }
  });

  final bool isNotSamePage =
      visibleOverlayPage == null || visibleOverlayPage.tagName != tagName;

  if (redisplayOverlayIfSameTAgName || isNotSamePage) {
    _printIfDebug('_showOverlayEntry', "tagname null or differs from current");
    // ignore if tag name already displayed
    if (!_overlays.containsKey(tagName)) {
      throw new Exception("tag name '$tagName' for overlay does not exists!");
    }
    hideOverlayEntryIfExists(toRunHook: isNotSamePage);
    if (isNotSamePage && showOverlayHook != null) {
      showOverlayHook(tagName);
    }
    final OverlayData data = _overlays[tagName];
    Overlay.of(data.context).insert(data.entry);
    visibleOverlayPage = data;
    visibleOverlayPage.showOverlay();
  }
  _printIfDebug('_showOverlayEntry', 'function completed');
}

void showOverlayEntry(
    {String tagName, bool redisplayOverlayIfSameTAgName = true}) async {
  SchedulerBinding.instance.addPostFrameCallback((d) =>
      _showOverlayLock.synchronized(() => _showOverlayEntry(
          tagName: tagName,
          redisplayOverlayIfSameTAgName: redisplayOverlayIfSameTAgName)));
}

void hideOverlayEntryIfExists({bool toRunHook = true}) {
  if (visibleOverlayPage != null) {
    _printIfDebug(
        'hideOverlayEntryIfExists', "found tag ${visibleOverlayPage.tagName}");
    if (toRunHook && hideOverlayHook != null) {
      hideOverlayHook(visibleOverlayPage.tagName);
    }
    visibleOverlayPage.hideOverlay();
    visibleOverlayPage.entry.remove();
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
    @required BuildContext context,
    bool enableHolesAnimation = true,
    bool enableAnimationRepeat = true,
    double defaultPadding = 4,
    List<WidgetData> widgetsData = const [],
    Function onTap,
    Color bgColor,
    Widget description,
    int highlightCount = 3,
    int animationMilliseconds = 150,
    int animationRepeatDelayMilliseconds = 3000,
    bool isOverlayBgTransparent = false}) {
  if (!_overlays.containsKey(tagName)) {
    createTutorialOverlay(
        context: context,
        tagName: tagName,
        enableHolesAnimation: enableHolesAnimation,
        enableAnimationRepeat: enableAnimationRepeat,
        defaultPadding: defaultPadding,
        widgetsData: widgetsData,
        onTap: onTap,
        bgColor: bgColor,
        description: description,
        highlightCount: highlightCount,
        animationMilliseconds: animationMilliseconds,
        animationRepeatDelayMilliseconds: animationRepeatDelayMilliseconds,
        isOverlayBgTransparent: isOverlayBgTransparent);
  }
}

void createTutorialOverlay(
    {@required String tagName,
    @required BuildContext context,
    bool enableHolesAnimation = true,
    bool enableAnimationRepeat = true,
    double defaultPadding = 4,
    List<WidgetData> widgetsData = const [],
    Function onTap,
    Color bgColor,
    Widget description,
    int highlightCount = 3,
    int animationMilliseconds = 150,
    int animationRepeatDelayMilliseconds = 3000,
    bool isOverlayBgTransparent = false}) {
  final String generatedUUID = uuid.v4();
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
  AnimationController animationController;
  CurvedAnimation animation;
  if (!isOverlayBgTransparent && enableHolesAnimation) {
    animationController = AnimationController(
        vsync: Overlay.of(context),
        duration: Duration(milliseconds: animationMilliseconds));
    animation = CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeInOut);
    int animCount = 0;
    bool inTheMiddleOfFuture = false;
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (animCount < highlightCount) {
          animationController.reverse();
          animCount++;
        }
      } else if (status == AnimationStatus.dismissed) {
        if (animCount < highlightCount) {
          animationController.forward();
        } else {
          animCount = 0;
          if (visibleOverlayPage?.uuid == generatedUUID &&
              enableAnimationRepeat) {
            if (!inTheMiddleOfFuture) {
              inTheMiddleOfFuture = true;
              Future.delayed(
                      Duration(milliseconds: animationRepeatDelayMilliseconds))
                  .then((d) {
                if (visibleOverlayPage?.uuid == generatedUUID) {
                  animationController.forward();
                  inTheMiddleOfFuture = false;
                }
              });
            }
          }
        }
      }
    });
  }
  _overlays[tagName] = OverlayData(
      isOverlayBgTransparent: isOverlayBgTransparent,
      uuid: generatedUUID,
      context: context,
      animationController: animationController,
      widgetsGlobalKeys: widgetsGlobalKeys,
      enabledVisibleWidgetsCount: enabledVisibleWidgetsCount,
      disabledVisibleWidgetsCount: disabledVisibleWidgetsCount,
      tagName: tagName,
      showOverlay: () {
        animationController?.reset();
        animationController?.forward();
      },
      hideOverlay: () {
        animationController?.reset();
      },
      entry: OverlayEntry(
          builder: (BuildContext context) => FutureBuilder(
              future: waitForFrameToEnd(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (isOverlayBgTransparent) {
                  return description;
                } else {
                  return GestureDetector(
                      onTap: onTap,
                      child: ClipPath(
                          clipper: InvertedClipper(
                              padding: defaultPadding,
                              animation: animation,
                              reclip: animationController,
                              widgetsData: widgetsData),
                          child: CustomPaint(
                            child: Container(
                              child: description,
                            ),
                            painter: OverlayPainter(
                                padding: defaultPadding,
                                animation: animation,
                                bgColor: bgColor,
                                context: context,
                                widgetsData: widgetsData),
                          )));
                }
              })));
}
