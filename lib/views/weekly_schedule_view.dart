import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_provider.dart';
import '../services/theme_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class WeeklyScheduleView extends StatelessWidget {
  const WeeklyScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('CENTRO DE DESPLIEGUE SEMANAL',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header de días
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 660, // Ancho fijo para asegurar espacio para los 7 días
              child: _buildWeekHeader(weekDays, primaryColor, isDark),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 660, // Coincidir con el header
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHourColumn(isDark),
                      ...weekDays.map((date) => _buildDayColumn(
                          date, taskProvider, primaryColor, isDark)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(
      List<DateTime> days, Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 60, bottom: 16, top: 8),
      child: Row(
        children: days.map((date) {
          final now = DateTime.now();
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;
          final dayName = DateFormat('E', 'es_ES').format(date).toUpperCase();

          return Expanded(
            child: Column(
              children: [
                Text(dayName,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isToday ? primaryColor : AppTheme.textGrey)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: isToday ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle),
                  child: Text('${date.day}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? Colors.white
                              : (isDark ? Colors.white : AppTheme.textBlack))),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHourColumn(bool isDark) {
    return SizedBox(
      width: 60,
      child: Column(
        children: List.generate(
            24,
            (i) => Container(
                  height: 60,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${i.toString().padLeft(2, '0')}:00',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.bold)),
                )),
      ),
    );
  }

  Widget _buildDayColumn(
      DateTime date, TaskProvider provider, Color primaryColor, bool isDark) {
    final dayTasks = provider.allTasks.where((t) {
      if (t.repeatDays.isEmpty) {
        return t.startTime.day == date.day &&
            t.startTime.month == date.month &&
            t.startTime.year == date.year;
      }
      return t.repeatDays.contains(date.weekday);
    }).toList();

    return Expanded(
      child: Stack(
        children: [
          // Líneas de fondo
          Column(
            children: List.generate(
                24,
                (i) => Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05)),
                              left: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05)))),
                    )),
          ),
          // Bloques de tareas
          ...dayTasks.map((task) {
            final startHour = task.startTime.hour;
            final startMinute = task.startTime.minute;
            final durationMin = task.duration?.inMinutes ?? 60;

            return Positioned(
              top: (startHour * 60 + startMinute).toDouble(),
              left: 2,
              right: 2,
              height: durationMin.toDouble(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(task.color).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(task.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
            );
          }),
        ],
      ),
    );
  }
}
