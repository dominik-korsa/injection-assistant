import 'package:flutter/material.dart';

class SettingsRoute extends StatefulWidget {
  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
        centerTitle: true,
      ),
    );
  }
}
