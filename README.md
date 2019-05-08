# tuxin_tutorial_overlay

an overlay flutter package that can be used for tutorials and walk-through

I was looking for an easier way to add tutorial 
walk-through to an existing app without cascading more 
elements into my app.

I wanted a walk-through that I can use as an overlay, that can have 
several widget behind it being shown, some widgets to allow interaction and some not,
and also to be able to have specific shapes of holes (rect, oval and so on)
so I made this :)

btw.. I'm new to flutter programming so I apologize for any mistakes and would
appreciate any comments. thanks!
 

## API

`WidgetData.dart` contains the following definitions:

`enum WidgetShape { Oval, Rect, RRect }` - to define the shape of the hole that will grant the requested widget visibility (default is Oval).

the Widget Data class:

```dart
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
```
 
you use it to define each widget's relevant properties, like padding, enabled/disabled (allow user interaction) and the shape of the hole in the Overlay

`TutorialOverlayUtil.dart` contains the following function:

```dart
void createTutorialOverlay(
    {@required String tagName,
    List<WidgetData> widgetsData = const [],
    Function onTap,
    Color bgColor,
    Widget description})
```
`tagName` - the name of the overlay screen, to be used later when you want to show it

`widgetsData` - is a List of each widget that you want to be fully visible and the relevant properties (padding, enable/disable interaction and hole shape)

`onTap` - a callback that will be called when the user taps on the overlay itself

`bgColor` - a custom background color. default is Black with opacity of 0.4.

`description` - a Widget to display on top of the overlay, usually contains instructions on current frame

I also created two functions to show and hide an overlay.  

```dart
void showOverlayEntry(BuildContext context, String tagName) async;
void hideOverlayEntryIfExists();
```

`showOverlayEntry()` is used to show the overlay that you created earlier with `createTutorialOverlay()`.

`hideOverlayEntryIfExists()` is used to hide the overlay

* please note that you need to use the `createTutorialOverlay()` function only after the elements have been drawn in order to get their proper location and size. 
in my example I created the overlay at the `initState()` function of my `StatefulWidget`, so in order for the elements
to be drawn first I needed to execute the function inside a post frame callback:
```dart

import 'package:flutter/scheduler.dart';

...

@override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      createTutorialOverlay(
      tagName: 'example',
          ...
          )
      );
      showOverlayEntry(context, 'example');
    });

``` 

## Simple Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tuxin_tutorial_overlay/TutorialOverlayUtil.dart';
import 'package:tuxin_tutorial_overlay/WidgetData.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tux-In Tutorial Overlay Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Tutorial Overlay Example Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final GlobalKey buttonKey = GlobalKey();
  final GlobalKey counterKey = GlobalKey();
  double _leftPosition = 0;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      createTutorialOverlay(
          tagName: 'example',
          bgColor: Colors.green.withOpacity(
              0.4), // Optional. uses black color with 0.4 opacity by default
          onTap: () => print("TAP"),
          widgetsData: <WidgetData>[
            WidgetData(key: buttonKey, isEnabled: true, padding: 4),
            WidgetData(
                key: counterKey, isEnabled: false, shape: WidgetShape.Rect)
          ],
          description: Text(
            'hello',
            textAlign: TextAlign.center,
            style: TextStyle(decoration: TextDecoration.none),
          ));

      showOverlayEntry(context, 'example');
    });

    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _leftPosition += 10;
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(_leftPosition, 0, 0, 0),
                child: Text(
                  '$_counter',
                  key: counterKey,
                  style: Theme.of(context).textTheme.display1,
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        key: buttonKey,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

to execute this code see the example app :)

## Showcase from example app

![capture](https://github.com/kfirufk/tuxin_tutorial_overlay/raw/master/example/tuxin_tutorial_overlay_example.png)

#### usage of this package in production

* Folocard -  [http://folocard.com](http://folocard.com)