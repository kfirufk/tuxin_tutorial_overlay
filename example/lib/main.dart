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
