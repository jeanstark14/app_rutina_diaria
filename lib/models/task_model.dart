enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final DateTime startTime;
  final Duration? duration;
  final String? notes;
  final List<int> repeatDays;
  final List<String> completedDates;
  final int color; // Color en formato ARGB int
  final TaskPriority priority;
  final String? notificationSound;
  final int reminderMinutes; // Minutos antes (0 = sin recordatorio)
  final bool syncEnabled; // Sincronizar con reloj nativo

  Task({
    required this.id,
    required this.title,
    required this.startTime,
    this.duration,
    this.notes,
    required this.repeatDays,
    required this.completedDates,
    this.color = 0xFF2D62ED, // Azul por defecto
    this.priority = TaskPriority.medium,
    this.notificationSound,
    this.reminderMinutes = 5, // Por defecto 5 min antes
    this.syncEnabled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'duration': duration?.inMinutes,
      'notes': notes,
      'repeatDays': repeatDays.join(','),
      'completedDates': completedDates.join(','),
      'color': color,
      'priority': priority.index,
      'notificationSound': notificationSound,
      'reminderMinutes': reminderMinutes,
      'syncEnabled': syncEnabled ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      duration:
          map['duration'] != null ? Duration(minutes: map['duration']) : null,
      notes: map['notes'],
      repeatDays:
          map['repeatDays'] != null && (map['repeatDays'] as String).isNotEmpty
              ? (map['repeatDays'] as String).split(',').map(int.parse).toList()
              : [],
      completedDates: map['completedDates'] != null &&
              (map['completedDates'] as String).isNotEmpty
          ? (map['completedDates'] as String).split(',').toList()
          : [],
      color: map['color'] ?? 0xFF2D62ED,
      priority: TaskPriority.values[map['priority'] ?? 1],
      notificationSound: map['notificationSound'],
      reminderMinutes: map['reminderMinutes'] ?? 5,
      syncEnabled: map['syncEnabled'] == 1 || map['syncEnabled'] == true,
    );
  }

  Task copyWith({
    String? title,
    DateTime? startTime,
    Duration? duration,
    String? notes,
    List<int>? repeatDays,
    List<String>? completedDates,
    int? color,
    TaskPriority? priority,
    String? notificationSound,
    int? reminderMinutes,
    bool? syncEnabled,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      repeatDays: repeatDays ?? this.repeatDays,
      completedDates: completedDates ?? this.completedDates,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      notificationSound: notificationSound ?? this.notificationSound,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }

  String get formattedTime {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  bool isCompletedForDate(DateTime date) {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return completedDates.contains(dateStr);
  }
}
