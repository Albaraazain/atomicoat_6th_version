// lib/services/documentation_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/documentation.dart';

class DocumentationService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'documentation_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE documents(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            category TEXT,
            lastUpdated TEXT
          )
        ''');
      },
    );
  }

  Future<List<Documentation>> loadDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('documents');
    return List.generate(maps.length, (i) {
      return Documentation.fromJson(maps[i]);
    });
  }

  Future<void> saveDocument(Documentation document) async {
    final db = await database;
    await db.insert(
      'documents',
      document.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDocument(Documentation document) async {
    final db = await database;
    await db.update(
      'documents',
      document.toJson(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  Future<void> deleteDocument(String id) async {
    final db = await database;
    await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Documentation>> searchDocuments(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Documentation.fromJson(maps[i]);
    });
  }
}