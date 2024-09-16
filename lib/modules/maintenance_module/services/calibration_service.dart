// lib/services/calibration_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calibration_procedure.dart';
import '../models/calibration_record.dart';
import 'dart:convert';

class CalibrationService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'calibration_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE calibration_records(
            id TEXT PRIMARY KEY,
            componentId TEXT,
            calibrationDate TEXT,
            performedBy TEXT,
            calibrationData TEXT,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<List<CalibrationProcedure>> loadCalibrationProcedures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('calibration_procedures');
    return List.generate(maps.length, (i) {
      return CalibrationProcedure.fromJson(maps[i]);
    });
  }

  Future<Map<String, String>> getComponentNames() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('components', columns: ['id', 'name']);
    return Map.fromIterable(maps, key: (e) => e['id'], value: (e) => e['name']);
  }

  Future<List<CalibrationRecord>> loadCalibrationRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('calibration_records');
    return List.generate(maps.length, (i) {
      return CalibrationRecord(
        id: maps[i]['id'],
        componentId: maps[i]['componentId'],
        calibrationDate: DateTime.parse(maps[i]['calibrationDate']),
        performedBy: maps[i]['performedBy'],
        calibrationData: json.decode(maps[i]['calibrationData']),
        notes: maps[i]['notes'],
      );
    });
  }

  Future<void> saveCalibrationRecord(CalibrationRecord record) async {
    final db = await database;
    await db.insert(
      'calibration_records',
      {
        'id': record.id,
        'componentId': record.componentId,
        'calibrationDate': record.calibrationDate.toIso8601String(),
        'performedBy': record.performedBy,
        'calibrationData': json.encode(record.calibrationData),
        'notes': record.notes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCalibrationRecord(CalibrationRecord record) async {
    final db = await database;
    await db.update(
      'calibration_records',
      {
        'componentId': record.componentId,
        'calibrationDate': record.calibrationDate.toIso8601String(),
        'performedBy': record.performedBy,
        'calibrationData': json.encode(record.calibrationData),
        'notes': record.notes,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteCalibrationRecord(String id) async {
    final db = await database;
    await db.delete(
      'calibration_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}