import 'dart:async';

import 'dart:math';

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

  static setDay(DateTime date, int state) {
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

  static int getTimerDuration() {
    return _DatabaseConnector.getTimerDuration();
  }

  static void setTimerDuration(int duration) {
    _DatabaseConnector.setTimerDuration(duration);
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

  static int getTimerDuration() {
    return 5;
  }

  static void setTimerDuration(int duration) {
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
