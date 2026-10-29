import '../data/databases/app_database.dart';
import '../models/meter.dart';

class MeterRepository {
  MeterRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Meter>> getAll() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.metersTable,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    final meters = <Meter>[];

    for (final row in rows) {
      final id = row['id'] as String;
      final readingRows = await db.query(
        AppDatabase.readingsTable,
        where: 'meter_id = ?',
        whereArgs: [id],
        orderBy: 'reading_date DESC',
      );

      final values = readingRows
          .map((item) => (item['reading_value'] as num).toDouble())
          .toList();

      final latestDate = readingRows.isNotEmpty
          ? DateTime.parse(readingRows.first['reading_date'] as String)
          : DateTime.parse(row['created_at'] as String);

      final current = values.isNotEmpty ? values[0] : 0.0;
      final previous = values.length > 1 ? values[1] : current;

      final chronologicalValues = values.reversed.toList();
      final consumptions = <double>[];

      for (var i = 1; i < chronologicalValues.length; i++) {
        consumptions.add(chronologicalValues[i] - chronologicalValues[i - 1]);
      }

      final lastSix = consumptions.length > 6
          ? consumptions.sublist(consumptions.length - 6)
          : consumptions;

      meters.add(
        Meter(
          id: id,
          name: row['name'] as String,
          type: ResourceType.values.firstWhere(
            (type) => type.name == row['type'],
            orElse: () => ResourceType.water,
          ),
          number: row['number'] as String,
          lastReading: current,
          previousReading: previous,
          lastSubmission: latestDate,
          tariff: (row['tariff'] as num).toDouble(),
          monthlyConsumption: [
            ...List<double>.filled(6 - lastSix.length, 0),
            ...lastSix,
          ],
        ),
      );
    }

    return meters;
  }

  Future<void> add({
    required String id,
    required String name,
    required ResourceType type,
    required String number,
    required double tariff,
  }) async {
    final db = await _database.database;

    await db.insert(AppDatabase.metersTable, {
      'id': id,
      'name': name,
      'type': type.name,
      'number': number,
      'tariff': tariff,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> delete(String id) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      await txn.delete(
        AppDatabase.readingsTable,
        where: 'meter_id = ?',
        whereArgs: [id],
      );

      await txn.delete(
        AppDatabase.metersTable,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
