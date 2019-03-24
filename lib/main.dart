import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homeRoute.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new MaterialApp(
      title: 'Injection assistant',
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new HomeRoute(),
    );
  }
}
