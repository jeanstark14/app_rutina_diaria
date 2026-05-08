import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class BackgroundTimerService {
  static final BackgroundTimerService _instance = BackgroundTimerService._internal();
  factory BackgroundTimerService() => _instance;
  BackgroundTimerService._internal();

  Future<void> init() async {
    debugPrint('=== BackgroundTimerService inicializado ===');
  }

  Future<void> startFocusTimer({
    required int durationMinutes,
    required String missionTitle,
    Function()? onComplete,
  }) async {
    debugPrint('Temporizador Focus iniciado (solo visual): $missionTitle - $durationMinutes minutos');
  }

  Future<void> stopFocusTimer() async {
    debugPrint('Temporizador Focus detenido');
  }
}