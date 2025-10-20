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
    required this.tickets,
    required this.createdAt,
    required this.updatedAt,
    this.executorName,
    this.transportName,
    this.transportGovNumber,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    print('Task.fromJson - parsing task with keys: ${json.keys.toList()}');
    print('Task.fromJson - id: ${json['id']} (type: ${json['id'].runtimeType})');
    print('Task.fromJson - shift_id: ${json['shift_id']} (type: ${json['shift_id'].runtimeType})');
    print('Task.fromJson - executor: ${json['executor']} (type: ${json['executor'].runtimeType})');
    print('Task.fromJson - robot_name: ${json['robot_name']} (type: ${json['robot_name'].runtimeType})');
    print('Task.fromJson - transport_id: ${json['transport_id']} (type: ${json['transport_id'].runtimeType})');
    
    print('Task.fromJson - creating Task object...');
    
    final task = Task(
      id: json['id'] as int,
      shiftId: json['shift_id'] != null ? json['shift_id'] as int : null,
      executor: json['executor'] != null ? json['executor'] as int : null,
      robotName: json['robot_name'] != null ? json['robot_name'] as int : null,
      transportId: json['transport_id'] != null ? json['transport_id'] as int : null,
      timeStart: DateTime.parse(json['time_start'] as String),
      timeEnd: DateTime.parse(json['time_end'] as String),
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => TaskType.custom,
      ),
      geojson: json['geojson'] != null ? json['geojson'] as Map<String, dynamic> : null,
      tickets: (json['tickets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      executorName: json['executor_name'] != null ? json['executor_name'] as String : null,
      transportName: json['transport_name'] != null ? json['transport_name'] as String : null,
      transportGovNumber: json['transport_gov_number'] != null ? json['transport_gov_number'] as String : null,
    );
    
    print('Task.fromJson - Task object created successfully');
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
      return '${hours}ч ${minutes}м';
    }
    return '${minutes}м';
  }

  String get typeDisplayName {
    switch (type) {
      case TaskType.route:
        return 'Маршрут';
      case TaskType.carpet:
        return 'Ковер';
      case TaskType.demo:
        return 'Демо';
      case TaskType.custom:
        return 'Кастом';
    }
  }

  String get typeIcon {
    switch (type) {
      case TaskType.route:
        return '🗺️';
      case TaskType.carpet:
        return '🧹';
      case TaskType.demo:
        return '🎯';
      case TaskType.custom:
        return '⚙️';
    }
  }
}
