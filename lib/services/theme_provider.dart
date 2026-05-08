import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HeroSkin {
  default_geek,
  iron_man,
  spider_man,
  batman,
  captain_america,
  spider_gwen,
  sentry,
  superman,
  luna_snow
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  HeroSkin _currentSkin = HeroSkin.default_geek;

  ThemeProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  HeroSkin get currentSkin => _currentSkin;

  // Definición de colores por Skin
  Color get primaryColor {
    switch (_currentSkin) {
      case HeroSkin.iron_man: return const Color(0xFFB71C1C);
      case HeroSkin.spider_man: return const Color(0xFFE53935);
      case HeroSkin.batman: return const Color(0xFF212121);
      case HeroSkin.captain_america: return const Color(0xFF0D47A1);
      case HeroSkin.spider_gwen: return const Color(0xFFF06292);
      case HeroSkin.sentry: return const Color(0xFFFFD600); // Dorado
      case HeroSkin.superman: return const Color(0xFF1565C0); // Azul
      case HeroSkin.luna_snow: return const Color(0xFF81D4FA); // Azul Claro
      default: return const Color(0xFF2D62ED);
    }
  }

  Color get accentColor {
    switch (_currentSkin) {
      case HeroSkin.iron_man: return const Color(0xFFFFD700);
      case HeroSkin.spider_man: return const Color(0xFF0D47A1);
      case HeroSkin.batman: return const Color(0xFF757575);
      case HeroSkin.captain_america: return const Color(0xFFF5F5F5);
      case HeroSkin.spider_gwen: return const Color(0xFFFFFFFF);
      case HeroSkin.sentry: return const Color(0xFF1A237E); // Azul Oscuro
      case HeroSkin.superman: return const Color(0xFFFFEB3B); // Amarillo
      case HeroSkin.luna_snow: return const Color(0xFF212121); // Negro/Blanco
      default: return const Color(0xFF2D62ED);
    }
  }

  String get heroName {
    switch (_currentSkin) {
      case HeroSkin.iron_man: return "IRON MAN";
      case HeroSkin.spider_man: return "SPIDER-MAN";
      case HeroSkin.batman: return "BATMAN";
      case HeroSkin.captain_america: return "CAPTAIN AMERICA";
      case HeroSkin.spider_gwen: return "SPIDER-GWEN";
      case HeroSkin.sentry: return "SENTRY";
      case HeroSkin.superman: return "SUPERMAN";
      case HeroSkin.luna_snow: return "LUNA SNOW";
      default: return "GEEK MODE";
    }
  }

  String? get heroImageAsset {
    switch (_currentSkin) {
      case HeroSkin.iron_man: return "assets/skins/iron_man.png";
      case HeroSkin.spider_man: return "assets/skins/spider_man.png";
      case HeroSkin.batman: return "assets/skins/batman.png";
      case HeroSkin.captain_america: return "assets/skins/captain_america.png";
      case HeroSkin.spider_gwen: return "assets/skins/spider_gwen.png";
      case HeroSkin.sentry: return "assets/skins/sentry.jpg";
      case HeroSkin.superman: return "assets/skins/superman.jpg";
      case HeroSkin.luna_snow: return "assets/skins/luna_snow.png";
      default: return null; // Clásico no tiene imagen
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    
    final skinIndex = prefs.getInt('heroSkin');
    if (skinIndex != null && skinIndex < HeroSkin.values.length) {
      _currentSkin = HeroSkin.values[skinIndex];
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    notifyListeners();
  }

  void setSkin(HeroSkin skin) async {
    _currentSkin = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('heroSkin', skin.index);
    notifyListeners();
  }
}
