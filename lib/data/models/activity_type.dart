enum ActivityType {
  withMotion,    // Requiere detector de movimiento
  withoutMotion  // No requiere detector de movimiento
}

class ActivityModel {
  final String id;
  final String title;
  final String category;
  final List<String> instructions;
  final ActivityType type;
  final int duration; // en segundos
  final String color;
  final bool assignedForToday;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.category,
    required this.instructions,
    required this.type,
    required this.duration,
    required this.color,
    this.assignedForToday = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'instructions': instructions,
    'type': type.toString(),
    'duration': duration,
    'color': color,
    'assignedForToday': assignedForToday,
  };

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      instructions: List<String>.from(json['instructions']),
      type: json['type'] == 'withMotion' ? ActivityType.withMotion : ActivityType.withoutMotion,
      duration: json['duration'],
      color: json['color'] ?? '0xFF0067AC',
      assignedForToday: json['assignedForToday'] ?? false,
    );
  }
}
