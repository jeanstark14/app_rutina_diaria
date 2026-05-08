import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_provider.dart';
import '../services/theme_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class MasterScheduleView extends StatelessWidget {
  const MasterScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;
    
    // Agrupamos las tareas por mes y semana
    final tasks = taskProvider.tasks;
    final Map<String, List<Task>> groupedTasks = {};
    
    for (var task in tasks) {
      final month = DateFormat('MMMM yyyy', 'es').format(task.startTime);
      if (!groupedTasks.containsKey(month)) {
        groupedTasks[month] = [];
      }
      groupedTasks[month]!.add(task);
    }

    final sortedMonths = groupedTasks.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy', 'es').parse(a);
        final dateB = DateFormat('MMMM yyyy', 'es').parse(b);
        return dateA.compareTo(dateB);
      });

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('LISTA MAESTRA DE MISIONES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? _buildEmptyState(context, isDark, primaryColor)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: sortedMonths.length,
              itemBuilder: (context, index) {
                final month = sortedMonths[index];
                final monthTasks = groupedTasks[month]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        month.toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ...monthTasks.map((task) => _buildTaskTile(context, task, isDark, primaryColor)).toList(),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTaskTile(BuildContext context, Task task, bool isDark, Color primaryColor) {
    final timeStr = DateFormat('HH:mm').format(task.startTime);
    final dayStr = DateFormat('EEEE d', 'es').format(task.startTime);
    final taskColor = Color(task.color);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: taskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                DateFormat('d').format(task.startTime),
                style: TextStyle(color: taskColor, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dayStr.toUpperCase()} • $timeStr',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: task.priority == TaskPriority.high ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              task.priority.name.toUpperCase(),
              style: TextStyle(
                color: task.priority == TaskPriority.high ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: primaryColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No hay misiones programadas', style: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
