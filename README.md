# tuxin_tutorial_overlay

an overlay flutter package that can be used for tutorials and walk-through

I was looking for an easier way to add tutorial 
walk-through to an existing app with cascading more 
elements into my app, so I made this! enjoy :)

btw.. I'm new to flutter programming so I apologize for any mistakes and would
appreciate any comments. thanks!
 

## API

`TutorialOverlayUtil.dart` contains the following function:

```dart
OverlayEntry createTutorialOverlay({@required BuildContext context, 
    List<GlobalKey> enabledKeys = const[],
    List<GlobalKey> disabledKeys = const[],
Widget description})
```

you need to provide a context of your page, and an optional
list of keys for the widgets that you have to be visible and/or usable.

`enabledKeys` - is a List used for global keys of Widgets that you want to be visible and usable (user can interact with while the overlay is displayed)

`disabledKeys` - is a List used for global keys of Widgets that you want to be visible but not usable (user cannot interact with while the overlay is displayed)

`description` - a Widget to display on top of the overlay, usually contains instructions on current frame

it also contains two functions that pretty much have only one line of code,
it's just for users that are not familiar with overlay concepts so it will be easier for them to implement this package.

```dart
void showOverlayEntry(BuildContext context, OverlayEntry entry);
void removeOverlayEntry(OverlayEntry entry);
```

`showOverlayEntry()` is used to show the overlay that you created earlier with `createTutorialOverlay()`.

`removeOverlayEntry()` is used to hide the overlay

* please note that you need to use the `createTutorialOverlay()` function only after the elements have been drawn in order to get their proper location and size. 
in my example I created the overlay at the `initState()` function of my `StatefulWidget`, so in order for the elements
to be drawn first I needed to execute the function inside a post callback:
```dart

import 'package:flutter/scheduler.dart';

...

@override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      OverlayEntry tut1 = createTutorialOverlay(
          ...
          )
      );
      showOverlayEntry(context, tut1);
    });

``` 

## Simple Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tuxin_tutorial_overlay/TutorialOverlayUtil.dart';

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

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      OverlayEntry tut1 = createTutorialOverlay(
          context: context,
          enabledKeys: [buttonKey],
          disabledKeys: [counterKey],
          description: Text('hello',textAlign: TextAlign.center,style: TextStyle(decoration: TextDecoration.none),)
      );
      showOverlayEntry(context, tut1);
    });

    super.initState();
  }

  void _incrementCounter() {
    setState(() {
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
            Text(
              '$_counter',
              key: counterKey,
              style: Theme.of(context).textTheme.display1,
            ),
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

