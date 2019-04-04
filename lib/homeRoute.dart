import 'dart:math';

import 'package:flutter/material.dart';
import 'package:injection_assistant/localizations.dart';
import 'package:injection_assistant/settingsRoute.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'dataManager.dart';
import 'timerRoute.dart';

class HomeRoute extends StatefulWidget {
  HomeRoute({Key key}) : super(key: key);
  final String title = 'Injection assistant';

  @override
  _HomeRouteState createState() => new _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  void _launchTimer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimerRoute()),
    );
  }

  void _launchSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsRoute()),
    );
  }

  void _changeAmpouleUsesLeft() async {
    int usesLeft = await DataManager.getAmpouleLeftUses();
    int usesMax = await DataManager.getAmpouleMaxUses();
    int usesSet = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 1,
          maxValue: usesMax,
          title: new Text(AppLocalizations.of(context).ampouleUses),
          initialIntegerValue: min(usesLeft, usesMax),
        );
      }
    );

    if (usesSet == null) { return; }

    DataManager.setAmpouleLeftUses(usesSet);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: AppLocalizations.of(context).settings,
            onPressed: _launchSettings,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new WeekView(),
              new Container(
                height: 48,
              ),
              Container(
                height: 108,
                child: Column(
                  children: <Widget>[
                    new FlatButton(
                      onPressed: _changeAmpouleUsesLeft,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            AppLocalizations.of(context).ampouleUsesLeft,
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          new Container(
                            height: 12,
                            width: 0,
                          ),
                          new StreamBuilder<int>(
                            stream: DataManager.ampouleLeftUses,
                            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                              if (snapshot.data == null) {
                                return new Text(
                                  AppLocalizations.of(context).loading,
                                  style: Theme.of(context).textTheme.display1,
                                );
                              } else if (snapshot.data > 1) {
                                return new Text(
                                  '${snapshot.data}',
                                  style: Theme.of(context).textTheme.display3,
                                );
                              } else {
                                return new Text(
                                  AppLocalizations.of(context).lastUse,
                                  style: Theme.of(context).textTheme.display1.apply(
                                    color: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    new Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton.extended(
        onPressed: _launchTimer,
        label: new Text(AppLocalizations.of(context).launchTimer),
        icon: new Icon(Icons.timer),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Day>>(
        stream: DataManager.days,
        builder: (BuildContext context, AsyncSnapshot<List<Day>> snapshot) {
          List<Day> data;
          if (snapshot.data == null) {
            return new Text(AppLocalizations.of(context).loading);
          } else {
            data = snapshot.data;
            List<Day> week = new List();
            DateTime now = new DateTime.now();
            DateTime today = new DateTime(now.year, now.month, now.day);
            for(int i = 6; i >= 0; i--) {
              DateTime date = today.subtract(new Duration(days: i));
              Day day = data.firstWhere(
                (day) => day.date.isAtSameMomentAs(date),
                orElse: () => null,
              );
              if (day == null) {
                week.add(new Day(date: date, id: null, state: Day.stateNotSet));
              } else {
                week.add(day);
              }
            }
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: week.map((day) =>
                new WeekViewDay(day),
              ).toList()
            );
          }
        },
      ),
    );
  }
}

class WeekViewDay extends StatelessWidget {
  WeekViewDay(this._day);

  final Day _day;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.0,
      height: 38.0,
      margin: EdgeInsets.all(4),
      child: RaisedButton(
        color: {
          Day.stateDone: Colors.green,
          Day.stateNotDone: Colors.red,
          Day.stateNotSet: Colors.grey,
        }[_day.state],
        onPressed: () {
          DataManager.setDay(_day.date, (_day.state + 1) % 3);
        },
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(19.0))
        ),
        child: Center(
          child: Text(
            DateFormat('EEE', Localizations.localeOf(context).languageCode).format(_day.date),
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
