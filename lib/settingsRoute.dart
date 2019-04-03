import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:injection_assistant/dataManager.dart';

class SettingsRoute extends StatefulWidget {
  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  int _timerDuration;
  int _ampouleMaxUses;
  TimeOfDay _notificationTime;

  @override
  void initState() {
    super.initState();
    setState(() {});
    DataManager.getNotificationTime().then((TimeOfDay notificationTimeTmp) async {
      int timerDurationTmp = await DataManager.getTimerDuration();
      int ampouleMaxUsesTmp = await DataManager.getAmpouleMaxUses();
      setState(() {
        _notificationTime = notificationTimeTmp;
        _ampouleMaxUses = ampouleMaxUsesTmp;
        _timerDuration = timerDurationTmp;
      });
    });
  }

  void _selectTimerDuration() async {
    int duration = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: 120,
          title: new Text('Select timer time'),
          initialIntegerValue: _timerDuration ?? 45,
        );
      }
    );

    if (duration == null) { return; }

    setState(() {
      DataManager.setTimerDuration(duration);
      _timerDuration = duration;
    });
  }

  void _selectAmpouleMaxUses() async {
    int uses = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 2,
          maxValue: 50,
          title: new Text('Ampoule uses'),
          initialIntegerValue: _ampouleMaxUses ?? 10,
        );
      }
    );

    if (uses == null) { return; }

    setState(() {
      DataManager.setAmpouleMaxUses(uses);
      _ampouleMaxUses = uses;
    });
  }

  void _selectNotificationTime() async {
    TimeOfDay pickedTime = await showTimePicker(
      initialTime: _notificationTime ?? TimeOfDay.now(),
      context: context,
    );

    if (pickedTime == null) { return; }

    setState(() {
      DataManager.setNotificationTime(pickedTime);
      _notificationTime = pickedTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
        centerTitle: true,
      ),
      body: new Container(
        child: new ListView(
          children: <Widget>[
            new ListTile(
              title: new Text('Timer duration'),
              subtitle: _timerDuration != null ? new Text('$_timerDuration seconds') : null,
              onTap: _selectTimerDuration,
            ),
            new ListTile(
              title: new Text('Ampoule uses'),
              subtitle: _ampouleMaxUses != null ? new Text('$_ampouleMaxUses uses') : null,
              onTap: _selectAmpouleMaxUses,
            ),
            new ListTile(
              title: new Text('Reminder notification time (Not implemented)'),
              enabled: false,
              subtitle: _notificationTime != null ? new Text(_notificationTime.format(context)) : null,
              onTap: _selectNotificationTime,
            ),
          ],
        ),
      ),
    );
  }
}
