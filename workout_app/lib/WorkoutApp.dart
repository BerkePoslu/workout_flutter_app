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
    // AI generated
    // Load theme asynchronously without blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTheme();
    });
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> toggleTheme() async {
    // AI generated
    // Set state immediately for responsive UI
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    // AI generated
    // Then save the setting in the background
    try {
      await SettingsHelper.setDarkMode(_isDarkMode);
    } catch (e) {
      // Revert if saving fails
      if (mounted) {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      }
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
      initialRoute: '/',
      routes: {
        '/': (context) =>
            HomeScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
        '/home': (context) =>
            HomeScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
      },
    );
  }
}
