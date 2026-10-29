import '../data/databases/app_database.dart';
import '../models/meter_reading.dart';

class ReadingRepository {
  ReadingRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<MeterReading>> getForMeter(String meterId) async {
    final db = await _database.database;

    final rows = await db.query(
      AppDatabase.readingsTable,
      where: 'meter_id = ?',
      whereArgs: [meterId],
      orderBy: 'reading_date DESC',
    );

    return rows.map((row) {
      return MeterReading(
        id: row['id'] as String,
        meterId: row['meter_id'] as String,
        date: DateTime.parse(row['reading_date'] as String),
        value: (row['reading_value'] as num).toDouble(),
      );
    }).toList();
  }

  Future<void> add({
    required String id,
    required String meterId,
    required DateTime date,
    required double value,
  }) async {
    final db = await _database.database;

    await db.insert(AppDatabase.readingsTable, {
      'id': id,
      'meter_id': meterId,
      'reading_value': value,
      'reading_date': date.toIso8601String(),
    });
  }

  Future<void> delete(String id) async {
    final db = await _database.database;

    await db.delete(
      AppDatabase.readingsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
