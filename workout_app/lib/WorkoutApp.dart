import 'package:flutter/material.dart';
import 'pages/Homescreen.dart';
import 'helpers/settings_helper.dart';

class WorkoutApp extends StatefulWidget {
  const WorkoutApp({super.key});

  @override
  State<WorkoutApp> createState() => _WorkoutAppState();
}

class _WorkoutAppState extends State<WorkoutApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final isDarkMode = await SettingsHelper.getDarkMode();
      if (mounted) {
        setState(() {
          _isDarkMode = isDarkMode;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading theme: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> toggleTheme() async {
    try {
      await SettingsHelper.setDarkMode(!_isDarkMode);
      if (mounted) {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      }
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Workout App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}
