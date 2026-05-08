import 'dart:io';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final Map<String, int> _createdAlarms = {};

  int? getAlarmId(String taskId) => _createdAlarms[taskId];

  Future<bool> createSystemAlarm(Task task) async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final now = DateTime.now();
      final taskTime = DateTime(now.year, now.month, now.day,
          task.startTime.hour, task.startTime.minute);

      DateTime alarmTime;
      if (taskTime.isAfter(now)) {
        alarmTime = taskTime;
      } else {
        alarmTime = taskTime.add(const Duration(days: 1));
      }

      final hour = alarmTime.hour;
      final minute = alarmTime.minute;
      final title = '🎯 ${task.title}';
      final alarmId = task.id.hashCode.abs() % 100000;

      FlutterAlarmClock.createAlarm(
        hour: hour,
        minutes: minute,
        title: title,
        skipUi: true,
      );

      _createdAlarms[task.id] = alarmId;
      return true;
    } catch (e) {
      debugPrint('Error al crear alarma: $e');
      return false;
    }
  }

  Future<bool> deleteSystemAlarm(String taskId) async {
    if (!Platform.isAndroid) return false;

    final alarmId = _createdAlarms[taskId];
    if (alarmId == null) {
      return false;
    }

    try {
      // NOTA: flutter_alarm_clock no proporciona API para eliminar alarmas existentes.
      // Solo removemos del registro local. El usuario debe eliminar manualmente en la app de reloj.
      _createdAlarms.remove(taskId);
      debugPrint(
          'Alarma removida del registro local (ID: $alarmId). Nota: No se puede eliminar automáticamente del reloj del sistema.');
      return true;
    } catch (e) {
      debugPrint('Error al eliminar alarma: $e');
      return false;
    }
  }

  Future<bool> createSystemTimer({
    required int durationSeconds,
    required String title,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('flutter_alarm_clock solo disponible en Android');
      return false;
    }

    try {
      FlutterAlarmClock.createTimer(
        length: durationSeconds,
        title: '⏱️ $title',
        skipUi: true,
      );
      debugPrint(
          'Temporizador creado en reloj nativo: $title - $durationSeconds segundos');
      return true;
    } catch (e) {
      debugPrint('Error al crear temporizador en reloj nativo: $e');
      return false;
    }
  }

  Future<void> showSystemTimers() async {
    if (!Platform.isAndroid) return;
    try {
      FlutterAlarmClock.showTimers();
    } catch (e) {
      debugPrint('Error al mostrar temporizadores del sistema: $e');
    }
  }

  Future<void> showSystemAlarms() async {
    if (!Platform.isAndroid) return;
    try {
      FlutterAlarmClock.showAlarms();
    } catch (e) {
      debugPrint('Error al mostrar alarmas del sistema: $e');
    }
  }
}
