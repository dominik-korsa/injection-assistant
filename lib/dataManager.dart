import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DataManager {
  static List<Day> _daysList;
  static StreamController<List<Day>> _daysStreamController;

  static Stream<List<Day>> get days {
    if(_daysStreamController == null) {
      _daysStreamController = StreamController<List<Day>>(
        onListen: () async {
          if (_daysList == null) {
            _daysList = await _DatabaseConnector._getDays();
          }
          _daysStreamController.add(_daysList);
        },
        onCancel: () {
          _daysStreamController.close();
        }
      );
    }

    return _daysStreamController.stream;
  }

  static void setDay(DateTime date, int state) async {
    if (_daysList == null) {
      _daysList = await _DatabaseConnector._getDays();
    }
    Day day = _daysList.firstWhere((Day day) => day.date.isAtSameMomentAs(date), orElse: () => null);
    if(day == null) {
      int id = await _DatabaseConnector.addDay(date, state);
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

  static int _ampouleLeftUses;
  static StreamController<int> _ampouleLeftUsesController;

  static Stream<int> get ampouleLeftUses {
    if(_ampouleLeftUsesController == null) {
      _ampouleLeftUsesController = StreamController<int>(
        onListen: () async {
          _ampouleLeftUses = await _KeystoreConnector.getAmpouleLeftUses();
          _ampouleLeftUsesController.add(_ampouleLeftUses);
        },
        onCancel: () {
          _ampouleLeftUsesController.close();
        }
      );
    }

    return _ampouleLeftUsesController.stream;
  }

  static Future<int> getAmpouleLeftUses() {
    return _KeystoreConnector.getAmpouleLeftUses();
  }

  static void setAmpouleLeftUses(int uses) {
    _KeystoreConnector.setAmpouleLeftUses(uses);

    _ampouleLeftUses = uses;

    if(_ampouleLeftUsesController != null) {
     _ampouleLeftUsesController.add(_ampouleLeftUses);
    }
  }
}

class _DatabaseConnector {
  static Database _database;
  static Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database;
    }
    return await openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Days (id INTEGER PRIMARY KEY AUTOINCREMENT, date REAL, state INTEGER);',
        );
      },
      version: 1,
    );
  }

  static Future<List<Day>> _getDays() async {
    Database database = await _getDatabase();
    List<Map<String, dynamic>> daysQuery = await database.query('Days');
    if (daysQuery.isEmpty) {
      return new List<Day>();
    } else {
      print(daysQuery);
      List<Day> days = daysQuery.toList().map((Map<String, dynamic> row) {
        return new Day.fromJson(row);
      }).toList();
      return days;
    }
  }

  static void updateDayStatus(int id, int state) async {
    Database database = await _getDatabase();
    await database.update('Days', { "state": state }, where: 'id=?', whereArgs: [ id ]);
  }

  static Future<int> addDay(DateTime date, int state) async {
    final db = await _getDatabase();
    var res = await db.insert('Days', {
      'date': date.millisecondsSinceEpoch / 86400000,
      'state': state,
    });
    return res;
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

  static Future<int> getAmpouleLeftUses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int uses = prefs.getInt('ampoule-left-uses') ?? await getAmpouleMaxUses();
    return uses;
  }

  static void setAmpouleLeftUses(int uses) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ampoule-left-uses', uses);
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

  factory Day.fromJson(Map<String, dynamic> json) => new Day(
    id: json['id'],
    date: new DateTime.fromMillisecondsSinceEpoch((json['date'] * 86400000).floor()), // Days since epoch
    state: json['state'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.millisecondsSinceEpoch / 86400000, // Days since epoch
    'state': state,
  };

  static const int stateDone = 2;
  static const int stateNotDone = 1;
  static const int stateNotSet = 0;
}
