import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_provider.dart';
import '../services/theme_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDate = DateTime.now();
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(_isWeekly ? 'PLAN DE OPERACIONES SEMANAL' : 'DESPLIEGUE MENSUAL', 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isWeekly ? Icons.calendar_view_month : Icons.calendar_view_week, color: primaryColor),
            onPressed: () => setState(() => _isWeekly = !_isWeekly),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (!_isWeekly) _buildMonthPicker(primaryColor),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isWeekly ? _buildWeeklyList(primaryColor, isDark) : _buildMonthlyGrid(primaryColor, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: primaryColor), 
              onPressed: () => setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1))
            ),
            Text(
              DateFormat('MMMM yyyy', 'es_ES').format(_focusedDate).toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryColor, letterSpacing: 1),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: primaryColor), 
              onPressed: () => setState(() => _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyList(Color primaryColor, bool isDark) {
    final taskProvider = context.watch<TaskProvider>();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayDate = startOfWeek.add(Duration(days: index));
        final dayName = DateFormat('EEEE', 'es_ES').format(dayDate);
        final isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;
        
        final dayTasks = taskProvider.allTasks.where((task) {
          final isSameDay = task.startTime.year == dayDate.year && task.startTime.month == dayDate.month && task.startTime.day == dayDate.day;
          if (isSameDay) return true;
          if (dayDate.isBefore(DateTime(task.startTime.year, task.startTime.month, task.startTime.day))) return false;
          return task.repeatDays.contains(dayDate.weekday);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isToday ? primaryColor : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('d').format(dayDate),
                        style: TextStyle(
                          color: isToday ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: TextStyle(
                          color: isToday ? primaryColor : AppTheme.textGrey,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1
                        ),
                      ),
                      if (isToday)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          height: 2,
                          width: 20,
                          color: primaryColor,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (dayTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 52, bottom: 24),
                child: Text('SIN MISIONES TÁCTICAS', 
                  style: TextStyle(color: AppTheme.textGrey.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  children: dayTasks.map((task) => _buildMiniTaskCard(task, dayDate, primaryColor, isDark)).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyGrid(Color primaryColor, bool isDark) {
    final taskProvider = context.watch<TaskProvider>();
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday;
    final now = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, 
        mainAxisSpacing: 12, 
        crossAxisSpacing: 12,
        childAspectRatio: 0.8
      ),
      itemCount: daysInMonth + (firstDayOfMonth - 1),
      itemBuilder: (context, index) {
        if (index < firstDayOfMonth - 1) return const SizedBox();
        
        final day = index - (firstDayOfMonth - 2);
        final dayDate = DateTime(_focusedDate.year, _focusedDate.month, day);
        final isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;
        
        final hasTasks = taskProvider.allTasks.any((task) {
          final isSameDay = task.startTime.year == dayDate.year && task.startTime.month == dayDate.month && task.startTime.day == dayDate.day;
          if (isSameDay) return true;
          if (dayDate.isBefore(DateTime(task.startTime.year, task.startTime.month, task.startTime.day))) return false;
          return task.repeatDays.contains(dayDate.weekday);
        });

        return GestureDetector(
          onTap: () {
            taskProvider.setSelectedDate(dayDate);
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isToday ? primaryColor : (isDark ? AppTheme.darkSurface : Colors.white),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
                )
              ],
              border: hasTasks && !isToday ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.5) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(), 
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    color: isToday ? Colors.white : (isDark ? Colors.white : AppTheme.textBlack),
                    fontSize: 16
                  )
                ),
                if (hasTasks)
                  Container(
                    margin: const EdgeInsets.only(top: 6), 
                    width: 5, 
                    height: 5, 
                    decoration: BoxDecoration(
                      color: isToday ? Colors.white : primaryColor, 
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isToday) BoxShadow(color: primaryColor.withOpacity(0.5), blurRadius: 4)
                      ]
                    )
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniTaskCard(Task task, DateTime date, Color primaryColor, bool isDark) {
    final isCompleted = task.isCompletedForDate(date);
    final taskColor = Color(task.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4, 
            height: 24, 
            decoration: BoxDecoration(
              color: isCompleted ? AppTheme.textGrey.withOpacity(0.3) : taskColor, 
              borderRadius: BorderRadius.circular(2)
            )
          ),
          const SizedBox(width: 16),
          Text(
            DateFormat('HH:mm').format(task.startTime), 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w900,
              color: isCompleted ? AppTheme.textGrey : (isDark ? Colors.white70 : AppTheme.textBlack)
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.title, 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                decoration: isCompleted ? TextDecoration.lineThrough : null, 
                color: isCompleted ? AppTheme.textGrey : (isDark ? Colors.white : AppTheme.textBlack)
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ),
          if (task.priority == TaskPriority.high && !isCompleted)
            const Icon(Icons.bolt, color: Colors.orange, size: 16),
        ],
      ),
    );
  }
}
