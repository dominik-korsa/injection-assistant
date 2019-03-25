import 'package:flutter/material.dart';
import 'package:injection_assistant/dataManager.dart';
import 'package:vibrate/vibrate.dart';

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
    Vibrate.vibrateWithPauses([Duration(milliseconds: 250)]);
  }

  void _timerSave() {
    Navigator.pop(context);
  }

  void _timerRestart() {
    setState(() {
      _finished = false;
      controller.reset();
    });
  }

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    int duration = DataManager.getTimerDuration();
    controller = AnimationController(duration: Duration(seconds: duration), vsync: this);
    animation = Tween<double>(begin: duration.toDouble(), end: 0).animate(controller)
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
        padding: _finished ? EdgeInsets.zero : EdgeInsets.only(bottom: 48.0),
        child: _finished ?
        new Column(
          children: [
            new Expanded(
              child: new Center(
                child: new Icon(Icons.timer, size: 256, color: Colors.black87)
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 16,
                left: 24,
                right: 24,
              ),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton.icon(
                    color: Theme.of(context).primaryColor,
                    highlightColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    onPressed: _timerRestart,
                    icon: new Icon(Icons.replay),
                    label: new Text('Restart'),
                  ),
                  RaisedButton.icon(
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                    onPressed: _timerSave,
                    icon: new Icon(Icons.save),
                    label: new Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ) :
        new Center(
          child: new Text(
            '${animation.value.floor()}',
            style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 192,
            ),
          ),
        ),
      ),
      floatingActionButton: _finished ? null : _running() ?
        new FloatingActionButton.extended(
          onPressed: _stopTimer,
          label: new Text('Stop timer'),
          icon: new Icon(Icons.stop),
        ):
        new FloatingActionButton.extended(
          onPressed: _startTimer,
          label: new Text('Start timer'),
          icon: new Icon(Icons.play_arrow),
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
