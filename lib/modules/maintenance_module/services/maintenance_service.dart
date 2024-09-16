// lib/services/maintenance_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/maintenance_procedure.dart';
import '../models/maintenance_task.dart';
import '../models/component.dart';
import 'dart:convert';

class MaintenanceService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'maintenance_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE components(
            id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT,
            status TEXT,
            lastMaintenanceDate TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE maintenance_tasks(
            id TEXT PRIMARY KEY,
            componentId TEXT,
            description TEXT,
            dueDate TEXT,
            isCompleted INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE maintenance_procedures(
            id TEXT PRIMARY KEY,
            componentId TEXT,
            componentName TEXT,
            procedureType TEXT,
            steps TEXT
          )
        ''');
      },
    );
  }

  Future<List<MaintenanceProcedure>> loadMaintenanceProcedures() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('maintenance_procedures');
    return List.generate(maps.length, (i) {
      return MaintenanceProcedure(
        componentId: maps[i]['componentId'],
        componentName: maps[i]['componentName'],
        procedureType: maps[i]['procedureType'],
        steps: (jsonDecode(maps[i]['steps']) as List)
            .map((step) => MaintenanceStep.fromJson(step))
            .toList(),
      );
    });
  }

  Future<MaintenanceProcedure?> getMaintenanceProcedure(String componentId, String procedureType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance_procedures',
      where: 'componentId = ? AND procedureType = ?',
      whereArgs: [componentId, procedureType],
    );

    if (maps.isNotEmpty) {
      return MaintenanceProcedure(
        componentId: maps[0]['componentId'],
        componentName: maps[0]['componentName'],
        procedureType: maps[0]['procedureType'],
        steps: (jsonDecode(maps[0]['steps']) as List)
            .map((step) => MaintenanceStep.fromJson(step))
            .toList(),
      );
    }
    return null;
  }

  Future<void> saveMaintenanceProcedure(MaintenanceProcedure procedure) async {
    final db = await database;
    await db.insert(
      'maintenance_procedures',
      {
        'id': procedure.componentId + '_' + procedure.procedureType, // Creating a unique ID
        'componentId': procedure.componentId,
        'componentName': procedure.componentName,
        'procedureType': procedure.procedureType,
        'steps': jsonEncode(procedure.steps.map((step) => step.toJson()).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<MaintenanceTask>> loadTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('maintenance_tasks');
    return List.generate(maps.length, (i) {
      return MaintenanceTask(
        id: maps[i]['id'],
        componentId: maps[i]['componentId'],
        description: maps[i]['description'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
        isCompleted: maps[i]['isCompleted'] == 1,
      );
    });
  }

  Future<List<Component>> loadComponents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('components');
    return List.generate(maps.length, (i) {
      return Component(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        status: maps[i]['status'],
        lastMaintenanceDate: DateTime.parse(maps[i]['lastMaintenanceDate']),
      );
    });
  }

  Future<void> saveTask(MaintenanceTask task) async {
    final db = await database;
    await db.insert(
      'maintenance_tasks',
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveComponent(Component component) async {
    final db = await database;
    await db.insert(
      'components',
      component.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(MaintenanceTask task) async {
    final db = await database;
    await db.update(
      'maintenance_tasks',
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateComponent(Component component) async {
    final db = await database;
    await db.update(
      'components',
      component.toJson(),
      where: 'id = ?',
      whereArgs: [component.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete(
      'maintenance_tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteComponent(String id) async {
    final db = await database;
    await db.delete(
      'components',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}