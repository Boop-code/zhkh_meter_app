
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'viewmodels/home_view_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const ZhkhMeterApp(),
    ),
  );
}

class ZhkhMeterApp extends StatelessWidget {
  const ZhkhMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мои счётчики',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2878E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FB),
          foregroundColor: Color(0xFF172033),
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
      ),
      home: const HomeScreen(),
    );
  }
}
