import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  List<Task> _tasks = [];
  List<Task> _allTasks = [];
  DateTime _selectedDate = DateTime.now();
  int _currentStreak = 0;
  bool _showCelebration = false;
  bool _isLoading = false;

  TaskProvider() {
    // Usar Future.microtask para evitar bloquear el constructor
    Future.microtask(() async {
      await _loadTasksOnInit();
    });
  }

  Future<void> _loadTasksOnInit() async {
    debugPrint('=== INICIANDO CARGA DE TAREAS ===');
    try {
      await loadTasks(force: true);
      debugPrint('=== CARGA INICIAL COMPLETADA ===');
    } catch (e, stackTrace) {
      debugPrint('Error al cargar tareas inicial: $e');
      debugPrint('Stack trace: $stackTrace');
      // Inicializar con listas vacías para evitar crashes
      _allTasks = [];
      _tasks = [];
      notifyListeners();
    }
  }

  List<Task> get tasks => _tasks;
  List<Task> get allTasks => _allTasks;
  DateTime get selectedDate => _selectedDate;
  int get currentStreak => _currentStreak;
  bool get showCelebration => _showCelebration;

  List<Task> get missionsWithTimer {
    final now = DateTime.now();
    final todayTasks = _allTasks.where((t) {
      if (t.duration != null && t.duration!.inMinutes > 0) {
        if (t.repeatDays.isEmpty) {
          return t.startTime.day == now.day &&
              t.startTime.month == now.month &&
              t.startTime.year == now.year;
        }
        return t.repeatDays.contains(now.weekday);
      }
      return false;
    }).toList();
    todayTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    return todayTasks;
  }

  Task? get nextActiveMission {
    final now = DateTime.now();
    final todayTasks = _allTasks.where((t) {
      if (t.repeatDays.isEmpty) {
        return t.startTime.day == now.day &&
            t.startTime.month == now.month &&
            t.startTime.year == now.year;
      }
      return t.repeatDays.contains(now.weekday);
    }).toList();
    todayTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    for (var t in todayTasks) {
      if (!t.isCompletedForDate(now)) {
        return t;
      }
    }
    return null;
  }

  List<String> getAvailableSlots(DateTime date) {
    final dayTasks = _allTasks.where((t) {
      if (t.repeatDays.isEmpty) {
        return t.startTime.day == date.day &&
            t.startTime.month == date.month &&
            t.startTime.year == date.year;
      }
      return t.repeatDays.contains(date.weekday);
    }).toList();

    dayTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    List<String> freeSlots = [];
    int currentHour = 5;
    int endHour = 23;

    for (int h = currentHour; h <= endHour; h++) {
      bool isOccupied = false;
      for (var task in dayTasks) {
        final taskStart = task.startTime.hour;
        final taskEnd = (task.startTime.hour + (task.duration?.inHours ?? 0)) +
            (task.startTime.minute > 0 ? 1 : 0);
        if (h >= taskStart && h < taskEnd) {
          isOccupied = true;
          break;
        }
      }
      if (!isOccupied) {
        freeSlots.add("${h.toString().padLeft(2, '0')}:00");
      }
    }
    return freeSlots;
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadTasks();
  }

  Future<void> loadTasks({bool force = false}) async {
    if (_isLoading && !force) {
      debugPrint('YA ESTÁ CARGANDO - ESPERANDO...');
      return;
    }
    _isLoading = true;

    try {
      final allTasksFromDb = await _dbService.getTasks();
      debugPrint('=== CARGANDO TAREAS ===');
      debugPrint(
          'Fecha seleccionada: $_selectedDate (day: ${_selectedDate.day}, month: ${_selectedDate.month}, year: ${_selectedDate.year}, weekday: ${_selectedDate.weekday})');
      debugPrint('Tareas encontradas en BD: ${allTasksFromDb.length}');
      for (var t in allTasksFromDb) {
        debugPrint(
            '  - "${t.title}" | fecha: ${t.startTime.day}/${t.startTime.month}/${t.startTime.year} | weekday: ${t.startTime.weekday} | repetición: ${t.repeatDays}');
      }

      _allTasks = allTasksFromDb;
      _updateCurrentTasksList();

      _currentStreak = await _calculateStreak();
      debugPrint('Racha actual: $_currentStreak');
      debugPrint('Tareas a mostrar: ${_tasks.length}');

      notifyListeners();
    } catch (e) {
      debugPrint('Error en loadTasks: $e');
      _allTasks = [];
      _tasks = [];
    } finally {
      _isLoading = false;
      debugPrint('=== CARGA COMPLETADA ===');
    }
  }

  // --- MEJORA 1: LIMPIAR HISTORIAL ---
  Future<void> clearAllData() async {
    for (var task in _allTasks) {
      await _dbService.deleteTask(task.id);
    }
    await loadTasks();
  }

  // --- MEJORA 3: EXPORTAR/IMPORTAR DATOS ---
  String exportTasksToJson() {
    final taskMaps = _allTasks.map((t) => t.toMap()).toList();
    return jsonEncode(taskMaps);
  }

  Future<void> importTasksFromJson(String json) async {
    try {
      final List<dynamic> taskList = jsonDecode(json);
      for (var map in taskList) {
        final task = Task.fromMap(map as Map<String, dynamic>);
        await _dbService.insertTask(task);
      }
      await loadTasks();
    } catch (e) {
      debugPrint('Error al importar tareas: $e');
    }
  }

  Future<int> _calculateStreak() async {
    if (_allTasks.isEmpty) return 0;
    DateTime oldestTaskDate = _allTasks
        .map((t) => t.startTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final now = DateTime.now();
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    int maxDays = 30;
    int daysChecked = 0;

    while (daysChecked < maxDays &&
        checkDate.isAfter(oldestTaskDate.subtract(const Duration(days: 1)))) {
      final tasksForDate = _allTasks
          .where((t) => t.repeatDays.isEmpty
              ? (t.startTime.day == checkDate.day &&
                  t.startTime.month == checkDate.month &&
                  t.startTime.year == checkDate.year)
              : t.repeatDays.contains(checkDate.weekday))
          .toList();

      if (tasksForDate.isEmpty) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        daysChecked++;
        continue;
      }

      final allCompleted =
          tasksForDate.every((t) => t.isCompletedForDate(checkDate));
      if (allCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        final isToday = checkDate.day == now.day &&
            checkDate.month == now.month &&
            checkDate.year == now.year;
        if (isToday) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          daysChecked++;
          continue;
        }
        break;
      }
      daysChecked++;
    }
    return streak;
  }

  Future<void> addTask(Task task, {bool syncToClock = false}) async {
    final taskWithSync = task.copyWith(syncEnabled: syncToClock);

    debugPrint('=== GUARDANDO TAREA ===');
    debugPrint('ID: ${taskWithSync.id}');
    debugPrint('Título: ${taskWithSync.title}');
    debugPrint('Hora: ${taskWithSync.startTime}');
    debugPrint('Sync: $syncToClock');

    try {
      await _dbService.insertTask(taskWithSync);
      debugPrint('Tarea guardada en BD exitosamente');
    } catch (e) {
      debugPrint('Error al guardar en BD: $e');
    }

    _allTasks.add(taskWithSync);
    _updateCurrentTasksList();
    notifyListeners();

    try {
      await loadTasks(force: true);
      debugPrint('Tareas recargadas');
    } catch (e) {
      debugPrint('Error al recargar tareas: $e');
    }

    if (syncToClock) {
      final clockAlarm =
          await _notificationService.createSystemAlarm(taskWithSync);
      if (clockAlarm) {
        _lastStatusMessage = 'MISIÓN GUARDADA Y SINCRONIZADA CON RELOJ.';
      } else {
        _lastStatusMessage = 'MISIÓN GUARDADA';
      }
    } else {
      _lastStatusMessage = 'MISIÓN GUARDADA';
    }

    notifyListeners();
    debugPrint('=== TAREA AGREGADA EXITOSAMENTE ===');
  }

  void _updateCurrentTasksList() {
    final selectedDay = _selectedDate.day;
    final selectedMonth = _selectedDate.month;
    final selectedYear = _selectedDate.year;
    final selectedWeekday = _selectedDate.weekday;

    debugPrint('=== FILTRANDO TAREAS ===');
    debugPrint(
        'selectedDay: $selectedDay, selectedMonth: $selectedMonth, selectedYear: $selectedYear, selectedWeekday: $selectedWeekday');

    _tasks = _allTasks.where((t) {
      final taskDate = t.startTime;

      if (t.repeatDays.isEmpty) {
        final isSameDay = taskDate.day == selectedDay &&
            taskDate.month == selectedMonth &&
            taskDate.year == selectedYear;
        debugPrint(
            '  [SIN REPETICION] "${t.title}" - fecha tarea: ${taskDate.day}/${taskDate.month}/${taskDate.year} - COINCIDE: $isSameDay');
        return isSameDay;
      } else {
        final containsDay = t.repeatDays.contains(selectedWeekday);
        debugPrint(
            '  [CON REPETICION] "${t.title}" - repeatDays: ${t.repeatDays} - selectedWeekday: $selectedWeekday - COINCIDE: $containsDay');
        return containsDay;
      }
    }).toList();

    _tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    debugPrint('=== RESUMEN FILTRO ===');
    debugPrint('Total tareas en BD: ${_allTasks.length}');
    debugPrint('Tareas mostradas: ${_tasks.length}');
    for (var t in _tasks) {
      debugPrint('  => ${t.title}');
    }
  }

  String? _lastStatusMessage;
  String? get lastStatusMessage => _lastStatusMessage;
  void clearStatusMessage() => _lastStatusMessage = null;

  Future<void> updateTask(Task task) async {
    final index = _allTasks.indexWhere((t) => t.id == task.id);

    Task? oldTask;
    if (index >= 0) {
      oldTask = _allTasks[index];
    }

    if (oldTask != null && oldTask.syncEnabled) {
      await _notificationService.deleteSystemAlarm(task.id);
    }

    if (task.syncEnabled) {
      await _notificationService.createSystemAlarm(task);
    }

    if (index >= 0) {
      _allTasks[index] = task;
    }
    _updateCurrentTasksList();
    notifyListeners();

    await _dbService.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    debugPrint('Eliminando tarea con id: $id');

    Task? taskToDelete;
    for (var t in _allTasks) {
      if (t.id == id) {
        taskToDelete = t;
        break;
      }
    }

    if (taskToDelete != null && taskToDelete.syncEnabled) {
      debugPrint('Eliminando alarma sincronizada para: ${taskToDelete.title}');
      await _notificationService.deleteSystemAlarm(id);
    }

    _allTasks.removeWhere((t) => t.id == id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();

    await _dbService.deleteTask(id);
  }

  Future<int> toggleTaskStatus(Task task) async {
    final dateStr =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final newCompletedDates = List<String>.from(task.completedDates);
    bool wasAlreadyCompleted = task.isCompletedForDate(_selectedDate);
    int xpEarned = 0;

    if (wasAlreadyCompleted) {
      newCompletedDates.remove(dateStr);
      xpEarned = -(task.priority == TaskPriority.high
          ? 50
          : task.priority == TaskPriority.medium
              ? 30
              : 15);
    } else {
      if (!newCompletedDates.contains(dateStr)) {
        newCompletedDates.add(dateStr);
      }
      xpEarned = task.priority == TaskPriority.high
          ? 50
          : task.priority == TaskPriority.medium
              ? 30
              : 15;
    }

    final updatedTask = task.copyWith(completedDates: newCompletedDates);
    await _dbService.updateTask(updatedTask);

    final taskIndex = _allTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex >= 0) {
      _allTasks[taskIndex] = updatedTask;
    }

    _updateCurrentTasksList();

    // Verificar celebración DESPUÉS de actualizar
    final allTasksForDate = _allTasks
        .where((t) => t.repeatDays.isEmpty
            ? (t.startTime.day == _selectedDate.day &&
                t.startTime.month == _selectedDate.month &&
                t.startTime.year == _selectedDate.year)
            : t.repeatDays.contains(_selectedDate.weekday))
        .toList();

    debugPrint('=== TOGGLE TASK CHECK ===');
    debugPrint('wasAlreadyCompleted: $wasAlreadyCompleted');
    debugPrint('allTasksForDate count: ${allTasksForDate.length}');
    debugPrint('allTasksForDate.isNotEmpty: ${allTasksForDate.isNotEmpty}');

    if (!wasAlreadyCompleted && allTasksForDate.isNotEmpty) {
      final allCompleted =
          allTasksForDate.every((t) => t.isCompletedForDate(_selectedDate));
      debugPrint('allCompleted: $allCompleted');
      if (allCompleted) {
        _showCelebration = true;
        _lastStatusMessage =
            '🔥🔥🔥 ¡RACHA DEL DÍA COMPLETADA! 🔥🔥🔥\n¡Has completado todas las misiones de hoy!\n🎉 ¡Fuego intensities! 🏆';
        debugPrint('🎉 CELEBRATION ACTIVATED! _showCelebration = true');
      }
    }

    notifyListeners();
    await loadTasks();

    return xpEarned;
  }

  void resetCelebration() {
    _showCelebration = false;
    notifyListeners();
  }

  // --- NUEVA FUNCIÓN: ESTADÍSTICAS SEMANALES REALES ---
  List<double> getWeeklyCompletionStats() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    List<double> stats = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final tasksForDate = _allTasks
          .where((t) => t.repeatDays.isEmpty
              ? (t.startTime.day == date.day &&
                  t.startTime.month == date.month &&
                  t.startTime.year == date.year)
              : t.repeatDays.contains(date.weekday))
          .toList();

      if (tasksForDate.isEmpty) {
        stats.add(0.0);
      } else {
        final completedCount =
            tasksForDate.where((t) => t.isCompletedForDate(date)).length;
        stats.add(completedCount / tasksForDate.length);
      }
    }
    return stats;
  }
}
