import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerRoute extends StatefulWidget {
  TimerRoute({Key key}) : super(key: key);

  @override
  _TimerRouteState createState() => new _TimerRouteState();
}

class _TimerRouteState extends State<TimerRoute> with SingleTickerProviderStateMixin {
  bool _running() {
    return controller.isAnimating || false;
  }

  bool _finished = false;

  void _startTimer() {
    setState(() {
      _finished = false;
      controller.reset();
      controller.forward();
    });
  }

  void _stopTimer() {
    setState(() {
      controller.reset();
    });
  }

  void _timerFinish() {
    setState(() {
      _finished = true;
      controller.reset();
    });
    SystemSound.play(SystemSoundType.click);
  }

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: 45, end: 0).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          _timerFinish();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: new Center(
          child: _finished ?
          new Icon(Icons.timer, size: 256, color: Colors.black87) :
          new Text(
            '${animation.value.floor()}',
            style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 192,
            ),
          ),
        ),
      ),
      floatingActionButton: _running() ?
        new FloatingActionButton(
          onPressed: _stopTimer,
          child: new Icon(Icons.stop),
          tooltip: 'Pause',
        ):
        new FloatingActionButton(
          onPressed: _startTimer,
          child: new Icon(Icons.play_arrow),
          tooltip: 'Start',
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
