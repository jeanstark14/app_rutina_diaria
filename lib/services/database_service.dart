import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';

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
        version: 7, // Incrementar a versión 7 (nutrition)
        onCreate: (db, version) async {
          // Crear tabla tasks
          await db.execute(
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
          // Crear tabla subtasks
          await db.execute(
            '''CREATE TABLE subtasks(
            id TEXT PRIMARY KEY,
            taskId TEXT,
            title TEXT,
            isCompleted INTEGER DEFAULT 0,
            orderIndex INTEGER DEFAULT 0,
            completedAt TEXT,
            FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE
          )''',
          );
          // Crear tabla nutrition_logs
          await db.execute(
            '''CREATE TABLE nutrition_logs(
            id TEXT PRIMARY KEY,
            date TEXT,
            mealType TEXT,
            foodName TEXT,
            calories INTEGER,
            protein REAL,
            carbs REAL,
            fat REAL,
            timestamp TEXT
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
          if (oldVersion < 6) {
            // Crear tabla subtasks para usuarios existentes
            await db.execute(
              '''CREATE TABLE subtasks(
              id TEXT PRIMARY KEY,
              taskId TEXT,
              title TEXT,
              isCompleted INTEGER DEFAULT 0,
              orderIndex INTEGER DEFAULT 0,
              completedAt TEXT,
              FOREIGN KEY(taskId) REFERENCES tasks(id) ON DELETE CASCADE
            )''',
            );
          }
          if (oldVersion < 7) {
            await db.execute(
              '''CREATE TABLE nutrition_logs(
              id TEXT PRIMARY KEY,
              date TEXT,
              mealType TEXT,
              foodName TEXT,
              calories INTEGER,
              protein REAL,
              carbs REAL,
              fat REAL,
              timestamp TEXT
            )''',
            );
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

  // --- MÉTODOS PARA SUBTASKS ---

  Future<void> insertSubtask(Subtask subtask) async {
    final db = await database;
    await db.insert('subtasks', subtask.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSubtask(Subtask subtask) async {
    final db = await database;
    await db.update('subtasks', subtask.toMap(),
        where: 'id = ?', whereArgs: [subtask.id]);
  }

  Future<void> deleteSubtask(String id) async {
    final db = await database;
    await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSubtasksByTask(String taskId) async {
    final db = await database;
    await db.delete('subtasks', where: 'taskId = ?', whereArgs: [taskId]);
  }

  Future<List<Subtask>> getSubtasksByTask(String taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'orderIndex ASC',
    );
    return List.generate(maps.length, (i) => Subtask.fromMap(maps[i]));
  }

  Future<List<Subtask>> getAllSubtasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('subtasks', orderBy: 'taskId ASC, orderIndex ASC');
    return List.generate(maps.length, (i) => Subtask.fromMap(maps[i]));
  }

  /// Obtiene todas las tareas con sus subtareas incluidas
  Future<List<Task>> getTasksWithSubtasks() async {
    final tasks = await getTasks();

    for (var i = 0; i < tasks.length; i++) {
      final subtasks = await getSubtasksByTask(tasks[i].id);
      // Reemplazar la lista vacía con las subtareas cargadas
      tasks[i] = tasks[i].copyWith(subtasks: subtasks);
    }

    return tasks;
  }
}
