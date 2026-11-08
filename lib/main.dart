import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/databases/app_database.dart';
import 'repositories/meter_repository.dart';
import 'repositories/tariff_repository.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/initial_data_sync_service.dart';
import 'viewmodels/home_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tariffRepository = TariffRepository();

  // Добавляем начальные тарифы, если их ещё нет.
  tariffRepository.seedDefaultTariffs();

  // Синхронизируем начальные данные с REST API.
  // Если сервер недоступен, приложение продолжит работу
  // с данными, уже сохранёнными в SQLite.
  final apiService = ApiService();

  try {
    final syncService = InitialDataSyncService(
      database: AppDatabase.instance,
      apiService: apiService,
    );

    final count = await syncService.sync();

    debugPrint('Синхронизация с REST API завершена. Получено записей: $count');
  } catch (error) {
    debugPrint('Не удалось выполнить синхронизацию с REST API: $error');
  } finally {
    apiService.dispose();
  }

  final meterRepository = MeterRepository(tariffRepository: tariffRepository);

  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeViewModel(repository: meterRepository),
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
