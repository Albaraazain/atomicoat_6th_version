// lib/services/spare_parts_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/spare_part.dart';

class SparePartsService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'spare_parts_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE spare_parts(
            id TEXT PRIMARY KEY,
            name TEXT,
            partNumber TEXT,
            quantity INTEGER,
            minimumStockLevel INTEGER,
            supplier TEXT,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<List<SparePart>> loadSpareParts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('spare_parts');
    return List.generate(maps.length, (i) {
      return SparePart.fromJson(maps[i]);
    });
  }

  Future<void> saveSparePart(SparePart part) async {
    final db = await database;
    await db.insert(
      'spare_parts',
      part.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSparePart(SparePart part) async {
    final db = await database;
    await db.update(
      'spare_parts',
      part.toJson(),
      where: 'id = ?',
      whereArgs: [part.id],
    );
  }

  Future<void> deleteSparePart(String id) async {
    final db = await database;
    await db.delete(
      'spare_parts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}