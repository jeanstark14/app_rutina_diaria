import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition_model.dart';
import 'database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class NutritionProvider with ChangeNotifier {
  NutritionProfile? _profile;
  List<MealLog> _dailyLogs = [];
  bool _isLoading = false;

  NutritionProfile? get profile => _profile;
  List<MealLog> get dailyLogs => _dailyLogs;
  bool get isLoading => _isLoading;

  // Totales del día
  int get totalCalories => _dailyLogs.fold(0, (sum, log) => sum + log.calories);
  double get totalProtein => _dailyLogs.fold(0.0, (sum, log) => sum + log.protein);
  double get totalCarbs => _dailyLogs.fold(0.0, (sum, log) => sum + log.carbs);
  double get totalFat => _dailyLogs.fold(0.0, (sum, log) => sum + log.fat);

  // Objetivos según perfil
  double get targetCalories => _profile?.tdee ?? 2000.0;
  
  Map<String, double> get targetMacros {
    if (_profile == null) return {'carbs': 250, 'protein': 150, 'fat': 65};
    
    final ratios = _profile!.macroRatios;
    final totalCals = targetCalories;
    
    // 1g Carb = 4 cal, 1g Prot = 4 cal, 1g Fat = 9 cal
    return {
      'carbs': (totalCals * ratios['carbs']!) / 4,
      'protein': (totalCals * ratios['protein']!) / 4,
      'fat': (totalCals * ratios['fat']!) / 9,
    };
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    await loadProfile();
    await loadDailyLogs(DateTime.now());
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('nutrition_profile');
    if (profileJson != null) {
      _profile = NutritionProfile.fromJson(json.decode(profileJson));
    }
    notifyListeners();
  }

  Future<void> saveProfile(NutritionProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nutrition_profile', json.encode(profile.toJson()));
    notifyListeners();
  }

  Future<void> loadDailyLogs(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final db = await DatabaseService().database;
    
    // Verificar si la tabla existe (por si acaso no se ha ejecutado el upgrade aún)
    final tables = await db.query('sqlite_master', where: 'name = ?', whereArgs: ['nutrition_logs']);
    if (tables.isEmpty) return;

    final List<Map<String, dynamic>> maps = await db.query(
      'nutrition_logs',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'timestamp ASC',
    );

    _dailyLogs = List.generate(maps.length, (i) => MealLog.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> addMealLog(MealLog log, dynamic userProvider) async {
    final db = await DatabaseService().database;
    await db.insert('nutrition_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    await loadDailyLogs(DateTime.now());
    
    // Premiar con XP (50 XP por registro)
    if (userProvider != null) {
      userProvider.addXp(50);
    }
  }

  Future<void> deleteMealLog(String id) async {
    final db = await DatabaseService().database;
    await db.delete('nutrition_logs', where: 'id = ?', whereArgs: [id]);
    await loadDailyLogs(DateTime.now());
  }
}
