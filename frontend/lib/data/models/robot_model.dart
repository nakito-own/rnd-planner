class Robot {
  final int id;
  final int name;
  final int series;
  final bool hasBlockers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Robot({
    required this.id,
    required this.name,
    required this.series,
    required this.hasBlockers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
      id: json['id'] as int,
      name: json['name'] as int,
      series: json['series'] as int,
      hasBlockers: json['has_blockers'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'series': series,
      'has_blockers': hasBlockers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => 'Robot #$name';
  
  String get seriesInfo => 'Series $series';
}
