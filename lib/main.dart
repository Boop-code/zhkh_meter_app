import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ZhkhMeterApp());
}

class ZhkhMeterApp extends StatelessWidget {
  const ZhkhMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF176B5B);

    return MaterialApp(
      title: 'Мои счётчики',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          surface: const Color(0xFFF7F9F8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          foregroundColor: Color(0xFF18332E),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
