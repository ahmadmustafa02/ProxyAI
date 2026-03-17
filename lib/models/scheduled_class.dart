class ScheduledClass {
  final String id;
  final String className;
  final String teamName;
  final List<int> daysOfWeek;
  final int hour;
  final int minute;
  final bool enabled;

  const ScheduledClass({
    required this.id,
    required this.className,
    required this.teamName,
    required this.daysOfWeek,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'className': className,
      'teamName': teamName,
      'daysOfWeek': daysOfWeek,
      'hour': hour,
      'minute': minute,
      'enabled': enabled,
    };
  }

  factory ScheduledClass.fromJson(Map<String, dynamic> json) {
    return ScheduledClass(
      id: json['id'] as String,
      className: json['className'] as String,
      teamName: json['teamName'] as String,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>).cast<int>(),
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  ScheduledClass copyWith({
    String? id,
    String? className,
    String? teamName,
    List<int>? daysOfWeek,
    int? hour,
    int? minute,
    bool? enabled,
  }) {
    return ScheduledClass(
      id: id ?? this.id,
      className: className ?? this.className,
      teamName: teamName ?? this.teamName,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }
}
