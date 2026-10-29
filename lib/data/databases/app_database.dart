import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'zhkh_meter.db';
  static const int _databaseVersion = 1;

  static const String metersTable = 'meters';
  static const String readingsTable = 'meter_readings';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final fullPath = path.join(databasePath, _databaseName);

    _database = await openDatabase(
      fullPath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
    );

    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $metersTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        number TEXT NOT NULL,
        tariff REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $readingsTable (
        id TEXT PRIMARY KEY,
        meter_id TEXT NOT NULL,
        reading_value REAL NOT NULL CHECK (reading_value >= 0),
        reading_date TEXT NOT NULL,
        FOREIGN KEY (meter_id)
          REFERENCES $metersTable (id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_readings_meter_date
      ON $readingsTable (meter_id, reading_date)
    ''');
  }

  Future<int> insertMeter(Map<String, Object?> values) async {
    final db = await database;

    return db.insert(
      metersTable,
      values,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Map<String, Object?>>> getMeters() async {
    final db = await database;

    return db.query(metersTable, orderBy: 'name COLLATE NOCASE ASC');
  }

  Future<int> updateMeter(String id, Map<String, Object?> values) async {
    final db = await database;

    return db.update(metersTable, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMeter(String id) async {
    final db = await database;

    return db.delete(metersTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertReading(Map<String, Object?> values) async {
    final db = await database;

    return db.insert(
      readingsTable,
      values,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Map<String, Object?>>> getReadingsForMeter(String meterId) async {
    final db = await database;

    return db.query(
      readingsTable,
      where: 'meter_id = ?',
      whereArgs: [meterId],
      orderBy: 'reading_date DESC',
    );
  }

  Future<int> deleteReading(String id) async {
    final db = await database;

    return db.delete(readingsTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
