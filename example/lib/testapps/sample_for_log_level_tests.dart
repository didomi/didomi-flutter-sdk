import 'package:didomi_sdk_example/widgets/set_log_level.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(SampleForLogLevelTestsApp());

class SampleForLogLevelTestsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Log Level Tests",
        home: HomePage(),
      );
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(
        child: ListView(
          key: Key("components_list"),
          children: [
            SetLogLevel(),
          ],
        ),
      );
}