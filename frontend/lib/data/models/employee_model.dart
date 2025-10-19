class Employee {
  final int id;
  final String firstname;
  final String lastname;
  final String? patronymic;
  final String? tg;
  final String? staff;
  final String? body;
  final bool drive;
  final bool parking;
  final bool telemedicine;
  final bool attorney;
  final bool accesToAutoVc;
  final int? crew;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.patronymic,
    this.tg,
    this.staff,
    this.body,
    required this.drive,
    required this.parking,
    required this.telemedicine,
    required this.attorney,
    required this.accesToAutoVc,
    this.crew,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
      patronymic: json['patronymic'] as String?,
      tg: json['tg'] as String?,
      staff: json['staff'] as String?,
      body: json['body'] as String?,
      drive: json['drive'] as bool,
      parking: json['parking'] as bool,
      telemedicine: json['telemedicine'] as bool,
      attorney: json['attorney'] as bool,
      accesToAutoVc: json['acces_to_auto_vc'] as bool,
      crew: json['crew'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'patronymic': patronymic,
      'tg': tg,
      'staff': staff,
      'body': body,
      'drive': drive,
      'parking': parking,
      'telemedicine': telemedicine,
      'attorney': attorney,
      'acces_to_auto_vc': accesToAutoVc,
      'crew': crew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    final parts = [lastname, firstname];
    if (patronymic != null && patronymic!.isNotEmpty) {
      parts.add(patronymic!);
    }
    return parts.join(' ');
  }
}
