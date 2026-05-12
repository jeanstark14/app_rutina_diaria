class Subtask {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int orderIndex;
  final DateTime? completedAt;

  Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.orderIndex = 0,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'orderIndex': orderIndex,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      orderIndex: map['orderIndex'] ?? 0,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Subtask copyWith({
    String? taskId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
    DateTime? completedAt,
  }) {
    return Subtask(
      id: id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      orderIndex: orderIndex ?? this.orderIndex,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
