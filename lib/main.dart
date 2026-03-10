import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final appState = AppState();
  await appState.init();
  runApp(TaskFlowApp(appState: appState));
}
