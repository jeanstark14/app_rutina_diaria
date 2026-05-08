import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'routine_app.db');
      print('Inicializando base de datos en: $path');
      return await openDatabase(
        path,
        version: 5, // Incrementar a versión 5
        onCreate: (db, version) {
          return db.execute(
            '''CREATE TABLE tasks(
            id TEXT PRIMARY KEY, 
            title TEXT, 
            startTime TEXT, 
            duration INTEGER, 
            notes TEXT, 
            repeatDays TEXT, 
            completedDates TEXT,
            color INTEGER,
            priority INTEGER,
            notificationSound TEXT,
            reminderMinutes INTEGER DEFAULT 5,
            syncEnabled INTEGER DEFAULT 0
          )''',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db
                .execute("ALTER TABLE tasks ADD COLUMN completedDates TEXT");
          }
          if (oldVersion < 3) {
            await db.execute(
                "ALTER TABLE tasks ADD COLUMN color INTEGER DEFAULT 4281131757"); // 0xFF2D62ED
            await db.execute(
                "ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 1");
            await db
                .execute("ALTER TABLE tasks ADD COLUMN notificationSound TEXT");
          }
          if (oldVersion < 4) {
            await db.execute(
                "ALTER TABLE tasks ADD COLUMN reminderMinutes INTEGER DEFAULT 5");
          }
          if (oldVersion < 5) {
            await db.execute(
                "ALTER TABLE tasks ADD COLUMN syncEnabled INTEGER DEFAULT 0");
          }
        },
      );
    } catch (e) {
      print('Error en _initDatabase: $e');
      rethrow;
    }
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('tasks', orderBy: 'startTime ASC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'startTime ASC',
    );
    final allTasks = List.generate(maps.length, (i) => Task.fromMap(maps[i]));
    return allTasks.where((task) {
      if (task.repeatDays.isEmpty) {
        return task.startTime.day == date.day &&
            task.startTime.month == date.month &&
            task.startTime.year == date.year;
      }
      return task.repeatDays.contains(date.weekday);
    }).toList();
  }
}
