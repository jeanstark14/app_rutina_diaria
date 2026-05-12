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

  // Colores personalizados
  Color? _customPrimaryColor;
  Color? _customAccentColor;
  bool _useCustomColors = false;

  ThemeProvider() {
    _loadSettings();
  }

  bool get useCustomColors => _useCustomColors;
  bool get isCustomColorActive => _useCustomColors;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  HeroSkin get currentSkin => _currentSkin;

  // Definición de colores por Skin
  Color get primaryColor {
    if (_useCustomColors && _customPrimaryColor != null) {
      return _customPrimaryColor!;
    }
    switch (_currentSkin) {
      case HeroSkin.iron_man:
        return const Color(0xFFD32F2F); // Rojo Iron Man
      case HeroSkin.spider_man:
        return const Color(0xFF1976D2); // Azul Spider-Man
      case HeroSkin.batman:
        return const Color(0xFF424242); // Gris Oscuro Batman
      case HeroSkin.captain_america:
        return const Color(0xFF1565C0); // Azul Capitán América
      case HeroSkin.spider_gwen:
        return const Color(0xFFE91E63); // Rosa Spider-Gwen
      case HeroSkin.sentry:
        return const Color.fromARGB(255, 255, 191, 0); // Ámbar Sentry
      case HeroSkin.superman:
        return const Color(0xFF1976D2); // Azul Superman
      case HeroSkin.luna_snow:
        return const Color(0xFF00BCD4); // Cyan Luna Snow
      default:
        return const Color(0xFF2D62ED); // Azul Geek
    }
  }

  Color get accentColor {
    if (_useCustomColors && _customAccentColor != null) {
      return _customAccentColor!;
    }
    switch (_currentSkin) {
      case HeroSkin.iron_man:
        return const Color(0xFFFBC02D); // Amarillo Iron Man
      case HeroSkin.spider_man:
        return const Color(0xFFD32F2F); // Rojo Spider-Man
      case HeroSkin.batman:
        return const Color(0xFF616161); // Gris Batman
      case HeroSkin.captain_america:
        return const Color(0xFFD32F2F); // Rojo Capitán
      case HeroSkin.spider_gwen:
        return const Color(0xFF1976D2); // Azul Spider-Gwen
      case HeroSkin.sentry:
        return const Color(0xFF455A64); // Gris Azulado Sentry
      case HeroSkin.superman:
        return const Color(0xFFD32F2F); // Rojo Superman
      case HeroSkin.luna_snow:
        return const Color(0xFFEC407A); // Rosa Luna Snow
      default:
        return const Color(0xFF2D62ED); // Azul Geek
    }
  }

  String get heroName {
    switch (_currentSkin) {
      case HeroSkin.iron_man:
        return "IRON MAN";
      case HeroSkin.spider_man:
        return "SPIDER-MAN";
      case HeroSkin.batman:
        return "BATMAN";
      case HeroSkin.captain_america:
        return "CAPTAIN AMERICA";
      case HeroSkin.spider_gwen:
        return "SPIDER-GWEN";
      case HeroSkin.sentry:
        return "SENTRY";
      case HeroSkin.superman:
        return "SUPERMAN";
      case HeroSkin.luna_snow:
        return "LUNA SNOW";
      default:
        return "GEEK MODE";
    }
  }

  String? get heroImageAsset {
    switch (_currentSkin) {
      case HeroSkin.iron_man:
        return "assets/skins/iron_man.png";
      case HeroSkin.spider_man:
        return "assets/skins/spider_man.png";
      case HeroSkin.batman:
        return "assets/skins/batman.png";
      case HeroSkin.captain_america:
        return "assets/skins/captain_america.png";
      case HeroSkin.spider_gwen:
        return "assets/skins/spider_gwen.png";
      case HeroSkin.sentry:
        return "assets/skins/sentry.jpg";
      case HeroSkin.superman:
        return "assets/skins/superman.jpg";
      case HeroSkin.luna_snow:
        return "assets/skins/luna_snow.png";
      default:
        return null; // Clásico no tiene imagen
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

    // Cargar colores personalizados
    _useCustomColors = prefs.getBool('useCustomColors') ?? false;
    final primaryColorValue = prefs.getInt('customPrimaryColor');
    final accentColorValue = prefs.getInt('customAccentColor');
    if (primaryColorValue != null) {
      _customPrimaryColor = Color(primaryColorValue);
    }
    if (accentColorValue != null) {
      _customAccentColor = Color(accentColorValue);
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
    _useCustomColors =
        false; // Desactivar colores personalizados al cambiar skin
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('heroSkin', skin.index);
    await prefs.setBool('useCustomColors', false);
    notifyListeners();
  }

  void setCustomColors(Color primary, Color accent) async {
    _customPrimaryColor = primary;
    _customAccentColor = accent;
    _useCustomColors = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('customPrimaryColor', primary.value);
    await prefs.setInt('customAccentColor', accent.value);
    await prefs.setBool('useCustomColors', true);
    notifyListeners();
  }

  void clearCustomColors() async {
    _useCustomColors = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCustomColors', false);
    notifyListeners();
  }
}
