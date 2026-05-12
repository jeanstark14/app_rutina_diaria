import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_provider.dart';
import '../services/user_provider.dart';
import '../services/theme_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';

class TaskDetailModal extends StatefulWidget {
  final Task task;

  const TaskDetailModal({super.key, required this.task});

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> {
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.task.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;
    final taskColor = Color(widget.task.color);
    
    final isCompleted = widget.task.isCompletedForDate(taskProvider.selectedDate);
    final completedSubtasks = widget.task.completedSubtasksCount;
    final totalSubtasks = widget.task.subtasks.length;
    final progressPercent = widget.task.subtaskProgressPercent;

    return Dialog(
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: taskColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: taskColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconForTask(widget.task.title),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.textBlack,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Prioridad ${_getPriorityText(widget.task.priority)}',
                                  style: TextStyle(
                                    color: taskColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.task.duration?.inMinutes ?? 30} min',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : AppTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: isDark ? Colors.white : AppTheme.textBlack,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información de tiempo
                    _buildInfoSection(
                      'INFORMACIÓN DE MISIÓN',
                      [
                        _buildInfoRow(
                          'Hora de inicio',
                          DateFormat('HH:mm').format(widget.task.startTime),
                          primaryColor,
                        ),
                        _buildInfoRow(
                          'Fecha',
                          DateFormat('dd MMM yyyy', 'es_ES').format(widget.task.startTime),
                          primaryColor,
                        ),
                        if (widget.task.repeatDays.isNotEmpty)
                          _buildInfoRow(
                            'Repetición',
                            _getRepeatText(widget.task.repeatDays),
                            primaryColor,
                          ),
                      ],
                      isDark,
                      primaryColor,
                    ),

                    const SizedBox(height: 20),

                    // Subtareas
                    if (totalSubtasks > 0) ...[
                      _buildSubtasksSection(
                        totalSubtasks,
                        completedSubtasks,
                        progressPercent,
                        taskColor,
                        isDark,
                        primaryColor,
                        taskProvider,
                        userProvider,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Notas
                    _buildNotesSection(
                      isDark,
                      primaryColor,
                      taskProvider,
                    ),
                  ],
                ),
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('EDITAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isCompleted ? null : () async {
                        final xp = await taskProvider.toggleTaskStatus(widget.task);
                        userProvider.addXp(xp);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isCompleted 
                                  ? 'Misión desmarcada' 
                                  : '¡Misión completada! +$xp XP'),
                              backgroundColor: taskColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(isCompleted ? Icons.undo : Icons.check_circle),
                      label: Text(isCompleted ? 'DESMARCAR' : 'COMPLETAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? Colors.grey : taskColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    List<Widget> children,
    bool isDark,
    Color primaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black12 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection(
    int totalSubtasks,
    int completedSubtasks,
    int progressPercent,
    Color taskColor,
    bool isDark,
    Color primaryColor,
    TaskProvider taskProvider,
    UserProvider userProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SUBTAREAS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1,
              ),
            ),
            Text(
              '$completedSubtasks/$totalSubtasks ($progressPercent%)',
              style: TextStyle(
                color: taskColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black12 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Progress bar
              Container(
                height: 4,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressPercent / 100.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: taskColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Subtasks list
              ...widget.task.subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final xp = await taskProvider.toggleSubtask(
                              widget.task.id, subtask.id);
                          userProvider.addXp(xp);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: subtask.isCompleted
                                  ? taskColor
                                  : (isDark
                                      ? Colors.white30
                                      : Colors.grey.shade400),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: subtask.isCompleted
                                ? taskColor
                                : Colors.transparent,
                          ),
                          child: subtask.isCompleted
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${index + 1}. ${subtask.title}',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtask.isCompleted
                                ? (isDark
                                    ? Colors.white38
                                    : Colors.grey.shade500)
                                : (isDark
                                    ? Colors.white70
                                    : AppTheme.textBlack),
                            decoration: subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(
    bool isDark,
    Color primaryColor,
    TaskProvider taskProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NOTAS DE LA MISIÓN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 1,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditingNotes = !_isEditingNotes;
                });
              },
              child: Text(_isEditingNotes ? 'GUARDAR' : 'EDITAR'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black12 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isEditingNotes
              ? TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textBlack,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Añade notas sobre esta misión...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  widget.task.notes?.isEmpty ?? true
                      ? 'Sin notas agregadas'
                      : widget.task.notes!,
                  style: TextStyle(
                    color: widget.task.notes?.isEmpty ?? true
                        ? (isDark ? Colors.white38 : Colors.grey.shade500)
                        : (isDark ? Colors.white70 : AppTheme.textBlack),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
        ),
      ],
    );
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Nivel S';
      case TaskPriority.medium:
        return 'Nivel A';
      case TaskPriority.low:
        return 'Nivel B';
    }
  }

  String _getRepeatText(List<int> repeatDays) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final selectedDays = repeatDays.map((day) => days[day - 1]).join(', ');
    return 'Repite: $selectedDays';
  }

  IconData _getIconForTask(String title) {
    title = title.toLowerCase();
    if (title.contains('desayuno') || title.contains('comida'))
      return Icons.restaurant;
    if (title.contains('gym') || title.contains('ejercicio')) return Icons.bolt;
    if (title.contains('trabajo')) return Icons.work;
    if (title.contains('reunión')) return Icons.hub;
    if (title.contains('descanso')) return Icons.bed;
    if (title.contains('lectura')) return Icons.menu_book;
    if (title.contains('estudio')) return Icons.menu_book;
    if (title.contains('cine')) return Icons.movie;
    if (title.contains('compra')) return Icons.shopping_cart;
    if (title.contains('limpieza')) return Icons.cleaning_services;
    if (title.contains('paseo')) return Icons.directions_walk;
    if (title.contains('meditar')) return Icons.menu_book_outlined;
    if (title.contains('Creacion de Contenido')) return Icons.video_call;
    return Icons.shield;
  }
}
