import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  int _xp = 0;
  int _level = 1;
  String _name = 'Agente';
  File? _profileImage;

  UserProvider() {
    _loadUserData();
  }

  int get xp => _xp;
  int get level => _level;
  String get name => _name;
  File? get profileImage => _profileImage;

  int get nextLevelXp => _level * 1000;
  double get levelProgress => _xp / nextLevelXp;

  String get rank {
    if (_level < 5) return 'Recluta';
    if (_level < 15) return 'Agente de Campo';
    if (_level < 30) return 'Especialista';
    if (_level < 50) return 'Vengador';
    return 'Héroe Prime';
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('user_xp') ?? 0;
    _level = prefs.getInt('user_level') ?? 1;
    _name = prefs.getString('user_name') ?? 'Agente';
    final imagePath = prefs.getString('user_image');
    if (imagePath != null) _profileImage = File(imagePath);
    notifyListeners();
  }

  Future<void> addXp(int amount) async {
    _xp += amount;
    if (_xp >= nextLevelXp) {
      _xp -= nextLevelXp;
      _level++;
    } else if (_xp < 0) {
      if (_level > 1) {
        _level--;
        _xp = nextLevelXp + _xp;
      } else {
        _xp = 0;
      }
    }
    await _saveData();
  }

  // --- MEJORA 1: REINICIO DE PROGRESO ---
  Future<void> resetProgress() async {
    _xp = 0;
    _level = 1;
    await _saveData();
  }

  Future<void> updateName(String newName) async {
    _name = newName;
    await _saveData();
  }

  Future<void> updateProfileImage(String path) async {
    _profileImage = File(path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', path);
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_xp', _xp);
    await prefs.setInt('user_level', _level);
    await prefs.setString('user_name', _name);
    notifyListeners();
  }
}
