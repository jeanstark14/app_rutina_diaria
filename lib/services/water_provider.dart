import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterProvider with ChangeNotifier {
  // Meta diaria de vasos (configurable por usuario)
  int _dailyGoal = 8;
  // Vasos tomados hoy
  int _todayIntake = 0;
  // Racha de días cumpliendo la meta
  int _currentStreak = 0;
  // Fecha del último día donde se completó la meta (yyyy-MM-dd)
  String? _lastCompletedDate;
  // Fecha del último registro para detectar nuevo día
  String _lastRecordDate;

  WaterProvider() : _lastRecordDate = _getTodayString() {
    _loadWaterData();
  }

  // Getters
  int get dailyGoal => _dailyGoal;
  int get todayIntake => _todayIntake;
  int get currentStreak => _currentStreak;
  int get remainingGlasses => _dailyGoal - _todayIntake;
  double get progressPercent => (_todayIntake / _dailyGoal).clamp(0.0, 1.0);
  bool get isGoalCompleted => _todayIntake >= _dailyGoal;

  static String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _dailyGoal = prefs.getInt('water_daily_goal') ?? 8;
    _currentStreak = prefs.getInt('water_streak') ?? 0;
    _lastRecordDate = prefs.getString('water_last_record') ?? _getTodayString();
    _lastCompletedDate = prefs.getString('water_last_completed');

    // Verificar si es un nuevo día
    final today = _getTodayString();
    if (_lastRecordDate != today) {
      // Es un nuevo día
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
      
      // Si ayer no se completó, resetear racha
      if (_lastCompletedDate != yesterdayStr && _lastCompletedDate != today) {
        _currentStreak = 0;
      }
      
      // Resetear contador diario
      _todayIntake = 0;
      _lastRecordDate = today;
      await _saveData();
    } else {
      // Mismo día, cargar progreso actual
      _todayIntake = prefs.getInt('water_today_intake') ?? 0;
    }
    
    notifyListeners();
  }

  // Agregar un vaso de agua
  Future<void> addGlass() async {
    if (_todayIntake < _dailyGoal) {
      _todayIntake++;
      
      // Verificar si se completó la meta por primera vez hoy
      if (_todayIntake == _dailyGoal) {
        final today = _getTodayString();
        _lastCompletedDate = today;
        _currentStreak++;
      }
      
      await _saveData();
      notifyListeners();
    }
  }

  // Quitar un vaso (corrección)
  Future<void> removeGlass() async {
    if (_todayIntake > 0) {
      final wasCompleted = isGoalCompleted;
      _todayIntake--;
      
      // Si ya no está completado, ajustar racha si es necesario
      if (wasCompleted && !isGoalCompleted) {
        final today = _getTodayString();
        if (_lastCompletedDate == today) {
          _lastCompletedDate = null;
          _currentStreak = (_currentStreak > 0) ? _currentStreak - 1 : 0;
        }
      }
      
      await _saveData();
      notifyListeners();
    }
  }

  // Establecer meta diaria (4-16 vasos)
  Future<void> setDailyGoal(int goal) async {
    if (goal >= 4 && goal <= 16) {
      final wasCompleted = isGoalCompleted;
      _dailyGoal = goal;
      
      // Verificar si con la nueva meta ya está completado
      if (!wasCompleted && isGoalCompleted) {
        final today = _getTodayString();
        _lastCompletedDate = today;
        _currentStreak++;
      } else if (wasCompleted && !isGoalCompleted) {
        final today = _getTodayString();
        if (_lastCompletedDate == today) {
          _lastCompletedDate = null;
          _currentStreak = (_currentStreak > 0) ? _currentStreak - 1 : 0;
        }
      }
      
      await _saveData();
      notifyListeners();
    }
  }

  // Resetear progreso de agua
  Future<void> resetWaterProgress() async {
    _todayIntake = 0;
    _currentStreak = 0;
    _lastCompletedDate = null;
    await _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_daily_goal', _dailyGoal);
    await prefs.setInt('water_today_intake', _todayIntake);
    await prefs.setInt('water_streak', _currentStreak);
    await prefs.setString('water_last_record', _lastRecordDate);
    if (_lastCompletedDate != null) {
      await prefs.setString('water_last_completed', _lastCompletedDate!);
    } else {
      await prefs.remove('water_last_completed');
    }
  }
}
