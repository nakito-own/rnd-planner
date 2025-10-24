class Transport {
  final int id;
  final String name;
  final String? model;
  final String? govNumber;
  final bool carsharing;
  final bool corporate;
  final bool autoVc;
  final bool hasBlockers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transport({
    required this.id,
    required this.name,
    this.model,
    this.govNumber,
    required this.carsharing,
    required this.corporate,
    required this.autoVc,
    required this.hasBlockers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json['id'] as int,
      name: json['name'] as String,
      model: json['model'] != null ? json['model'] as String : null,
      govNumber: json['gov_number'] != null ? json['gov_number'] as String : null,
      carsharing: json['carsharing'] as bool,
      corporate: json['corporate'] as bool,
      autoVc: json['auto_vc'] as bool,
      hasBlockers: json['has_blockers'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'gov_number': govNumber,
      'carsharing': carsharing,
      'corporate': corporate,
      'auto_vc': autoVc,
      'has_blockers': hasBlockers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (model != null && model!.isNotEmpty) {
      return '$name ($model)';
    }
    return name;
  }

  String get fullInfo {
    final parts = [name];
    if (model != null && model!.isNotEmpty) {
      parts.add(model!);
    }
    if (govNumber != null && govNumber!.isNotEmpty) {
      parts.add('Гос. номер: ${govNumber!}');
    }
    return parts.join(' - ');
  }
}
