import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static List<Day> _daysList = _DatabaseConnector._getDays();
  static StreamController<List<Day>> _daysStreamController;

  static Stream<List<Day>> get days {
    if(_daysStreamController == null) {
      _daysStreamController = StreamController<List<Day>>(
        onListen: () async {
          _daysStreamController.add(_daysList);
        },
        onCancel: () {
          _daysStreamController.close();
        }
      );
    }

    return _daysStreamController.stream;
  }

  static void setDay(DateTime date, int state) {
    Day day = _daysList.firstWhere((Day day) => day.date.isAtSameMomentAs(date), orElse: () => null);
    if(day == null) {
      int id = _DatabaseConnector.addDay(date, state);
      _daysList.add(new Day(date: date, state: state, id: id));
    } else {
      _DatabaseConnector.updateDayStatus(day.id, state);
      day.state = state;
    }

    if(_daysStreamController != null) {
     _daysStreamController.add(_daysList);
    }
  }

  static Future<int> getTimerDuration() {
    return _KeystoreConnector.getTimerDuration();
  }

  static void setTimerDuration(int duration) {
    _KeystoreConnector.setTimerDuration(duration);
  }

  static Future<TimeOfDay> getNotificationTime() {
    return _KeystoreConnector.getNotificationTime();
  }

  static void setNotificationTime(TimeOfDay time) {
    _KeystoreConnector.setNotificationTime(time);
  }

  static Future<int> getAmpouleMaxUses() {
    return _KeystoreConnector.getAmpouleMaxUses();
  }

  static void setAmpouleMaxUses(int uses) {
    _KeystoreConnector.setAmpouleMaxUses(uses);
  }
}

class _DatabaseConnector {
  static List<Day> _getDays() {
    DateTime _now = new DateTime.now();
    DateTime _today = new DateTime(_now.year, _now.month, _now.day);
    List<Day> _days = [];
    for (var i = 0; i < 14; i++) {
      if(i % 6 != 5) {
        _days.add(new Day(
          id: i,
          date: _today.subtract(new Duration(days: 13 - i)),
          state: [Day.stateDone, Day.stateNotDone, Day.stateNotSet][i % 3],
        ));
      }
    }
    return _days;
  }

  static void updateDayStatus(int id, int state) {
    return;
  }

  static int addDay(DateTime date, int state) {
    return new Random().nextInt(1000000000);
  }
}

class _KeystoreConnector {
  static Future<int> getTimerDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int duration = prefs.getInt('timer-duration') ?? 45;
    return duration;
  }

  static void setTimerDuration(int duration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('timer-duration', duration);
    return;
  }

  static Future<TimeOfDay> getNotificationTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int timeInMinutes = prefs.getInt('notification-time');
    if (timeInMinutes == null) {
      return new TimeOfDay(hour: 20, minute: 30);
    }

    int hour = (timeInMinutes / 60).floor();
    int minute = timeInMinutes % 60;
    TimeOfDay time = new TimeOfDay(hour: hour, minute: minute);
    return time;
  }

  static void setNotificationTime(TimeOfDay time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int timeInMinutes = time.hour * 60 + time.minute;
    prefs.setInt('notification-time', timeInMinutes);
    return;
  }

  static Future<int> getAmpouleMaxUses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int uses = prefs.getInt('ampoule-max-uses') ?? 10;
    return uses;
  }

  static void setAmpouleMaxUses(int uses) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ampoule-max-uses', uses);
    return;
  }
}

class Day {
  final int id;
  final DateTime date;
  int state;

  Day({
    this.id,
    this.date,
    this.state,
  });

  static const int stateDone = 2;
  static const int stateNotDone = 1;
  static const int stateNotSet = 0;
}
