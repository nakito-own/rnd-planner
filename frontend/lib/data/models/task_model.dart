import 'package:flutter/cupertino.dart';

enum TaskType {
  route,
  carpet,
  demo,
  custom,
}

class Task {
  final int id;
  final int? shiftId;
  final int? executor;
  final int? robotName;
  final int? transportId;
  final DateTime timeStart;
  final DateTime timeEnd;
  final TaskType type;
  final Map<String, dynamic>? geojson;
  final String? geojsonFilename;
  final List<String> tickets;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? executorName;
  final String? transportName;
  final String? transportGovNumber;

  Task({
    required this.id,
    this.shiftId,
    this.executor,
    this.robotName,
    this.transportId,
    required this.timeStart,
    required this.timeEnd,
    required this.type,
    this.geojson,
    this.geojsonFilename,
    required this.tickets,
    required this.createdAt,
    required this.updatedAt,
    this.executorName,
    this.transportName,
    this.transportGovNumber,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    
    final task = Task(
      id: json['id'] as int,
      shiftId: json['shift_id'] != null ? json['shift_id'] as int : null,
      executor: json['executor'] != null ? json['executor'] as int : null,
      robotName: json['robot_name'] != null ? json['robot_name'] as int : null,
      transportId: json['transport_id'] != null ? json['transport_id'] as int : null,
      timeStart: DateTime.parse(json['time_start'] as String? ?? DateTime.now().toIso8601String()),
      timeEnd: DateTime.parse(json['time_end'] as String? ?? DateTime.now().toIso8601String()),
      type: TaskType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'custom'),
        orElse: () => TaskType.custom,
      ),
      geojson: json['geojson'] != null ? json['geojson'] as Map<String, dynamic> : null,
      geojsonFilename: json['geojson_filename'] != null ? json['geojson_filename'] as String : null,
      tickets: (json['tickets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      executorName: json['executor_name'] != null ? json['executor_name'] as String : null,
      transportName: json['transport_name'] != null ? json['transport_name'] as String : null,
      transportGovNumber: json['transport_gov_number'] != null ? json['transport_gov_number'] as String : null,
    );
    
    return task;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift_id': shiftId,
      'executor': executor,
      'robot_name': robotName,
      'transport_id': transportId,
      'time_start': timeStart.toIso8601String(),
      'time_end': timeEnd.toIso8601String(),
      'type': type.name,
      'geojson': geojson,
      'geojson_filename': geojsonFilename,
      'tickets': tickets,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'executor_name': executorName,
      'transport_name': transportName,
      'transport_gov_number': transportGovNumber,
    };
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
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  String get typeDisplayName {
    switch (type) {
      case TaskType.route:
        return 'Route';
      case TaskType.carpet:
        return 'Carpet';
      case TaskType.demo:
        return 'Demo';
      case TaskType.custom:
        return 'Custom';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case TaskType.route:
        return CupertinoIcons.arrow_swap;
      case TaskType.carpet:
        return CupertinoIcons.map;
      case TaskType.demo:
        return CupertinoIcons.bolt_fill;
      case TaskType.custom:
        return CupertinoIcons.gear;
    }
  }
}