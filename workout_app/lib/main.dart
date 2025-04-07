import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'WorkoutApp.dart';

void main() {
  // error catching
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // more performace stuff
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      // orientation
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // performace optimizations
      runApp(const WorkoutApp());
    },
    (error, stackTrace) {
      print('Unhandled error: $error');
      print('Stack trace: $stackTrace');
    },
  );
}
