import '../data/databases/app_database.dart';
import 'api_service.dart';

class InitialDataSyncService {
  InitialDataSyncService({required this._database, required this._apiService});

  final AppDatabase _database;
  final ApiService _apiService;

  Future<int> sync() async {
    final meters = await _apiService.getInitialMeters();

    await _database.upsertInitialMeters(meters);

    return meters.length;
  }
}
