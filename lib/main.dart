import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryColor = Color(0xFF0A181D);
  static const Color secondaryColor = Color(0xFFA1CB8E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Es Cine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          onPrimary: secondaryColor,
          secondary: secondaryColor,
          onSecondary: primaryColor,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: secondaryColor),
          bodyLarge: TextStyle(color: secondaryColor, fontSize: 18),
          titleLarge: TextStyle(
            color: secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
