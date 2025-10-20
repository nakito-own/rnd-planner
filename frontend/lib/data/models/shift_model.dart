import 'task_model.dart';

class Shift {
  final int id;
  final DateTime date;
  final DateTime timeStart;
  final DateTime timeEnd;
  final DateTime editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Task> tasks;

  Shift({
    required this.id,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tasks = const [],
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      timeStart: DateTime.parse(json['time_start'] as String),
      timeEnd: DateTime.parse(json['time_end'] as String),
      editedAt: DateTime.parse(json['edited_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'time_start': timeStart.toIso8601String(),
      'time_end': timeEnd.toIso8601String(),
      'edited_at': editedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  String get formattedDate {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedTimeRange {
    final startTime = '${timeStart.hour.toString().padLeft(2, '0')}:${timeStart.minute.toString().padLeft(2, '0')}';
    final endTime = '${timeEnd.hour.toString().padLeft(2, '0')}:${timeEnd.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  Duration get duration {
    return timeEnd.difference(timeStart);
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}ч ${minutes}м';
    }
    return '${minutes}м';
  }
}
