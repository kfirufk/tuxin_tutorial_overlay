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
        context: context,
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

      showOverlayEntry(tagName: 'example');
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
