import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'pages/Login.dart';
import 'pages/homescreen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized ai generated
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI mode ai generated
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Run app in error zone AI generated
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthService, ThemeProvider>(
        builder: (context, authService, themeProvider, _) {
          return MaterialApp(
            title: authService.isAuthenticated && authService.username != null
                ? 'Hello ${authService.username}'
                : 'Hello User', // default state got it from stackoverflow
            theme: ThemeData(
              primarySwatch: Colors.blue,
              // material 3 is the latest version of the Material Design specification
              useMaterial3: true,
              brightness:
                  themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            // AI generated
            // Define routes for consistent navigation
            initialRoute: authService.isAuthenticated ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => HomeScreen(
                    toggleTheme: themeProvider.toggleTheme,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
            },
          );
        },
      ),
    );
  }
}
