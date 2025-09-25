class ProcessGroup {
  final String id;
  final String name;
  final String description;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> members;
  final List<Process> processes;

  ProcessGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.processes,
  });

  factory ProcessGroup.fromJson(Map<String, dynamic> json) {
    return ProcessGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      members: List<String>.from(json['members']),
      processes: (json['processes'] as List<dynamic>)
          .map((e) => Process.fromJson(e))
          .toList(),
    );
  }
}

class Process {
  final String id;
  final String groupId;
  final String processName;
  final List<PausePlan> pausePlans;
  final DateTime startDate;
  final DateTime createdAt;
  final String status;
  final DateTime updatedAt;

  Process({
    required this.id,
    required this.groupId,
    required this.processName,
    required this.pausePlans,
    required this.startDate,
    required this.createdAt,
    required this.status,
    required this.updatedAt,
  });

  factory Process.fromJson(Map<String, dynamic> json) {
    return Process(
      id: json['id'],
      groupId: json['groupId'],
      processName: json['processName'],
      pausePlans: (json['pausePlans'] as List<dynamic>)
          .map((e) => PausePlan.fromJson(e))
          .toList(),
      startDate: DateTime.parse(json['startDate']),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class PausePlan {
  final String id;
  final String name;
  final String description;
  final List<Activity> activities;
  final DateTime createdAt;
  final String status;
  final DateTime updatedAt;

  PausePlan({
    required this.id,
    required this.name,
    required this.description,
    required this.activities,
    required this.createdAt,
    required this.status,
    required this.updatedAt,
  });

  factory PausePlan.fromJson(Map<String, dynamic> json) {
    return PausePlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      activities: (json['activities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Activity {
  final String activityId;
  final int order;

  Activity({
    required this.activityId,
    required this.order,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityId: json['activityId'],
      order: json['order'],
    );
  }
}

