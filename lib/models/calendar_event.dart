class CalendarEvent {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final CalendarEventType eventType;
  final String? subjectId;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool isAllDay;
  final String? location;
  final EventPriority priority;
  final String colorCode;
  final bool isCompleted;
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;
  final int reminderMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.eventType,
    this.subjectId,
    required this.startDateTime,
    required this.endDateTime,
    this.isAllDay = false,
    this.location,
    this.priority = EventPriority.medium,
    this.colorCode = '#2196F3',
    this.isCompleted = false,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceEndDate,
    this.reminderMinutes = 30,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventType: CalendarEventType.values.firstWhere(
        (e) => e.name == json['event_type'],
        orElse: () => CalendarEventType.custom,
      ),
      subjectId: json['subject_id'] as String?,
      startDateTime: DateTime.parse(json['start_datetime'] as String),
      endDateTime: DateTime.parse(json['end_datetime'] as String),
      isAllDay: json['is_all_day'] as bool? ?? false,
      location: json['location'] as String?,
      priority: EventPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => EventPriority.medium,
      ),
      colorCode: json['color_code'] as String? ?? '#2196F3',
      isCompleted: json['is_completed'] as bool? ?? false,
      recurrenceType: RecurrenceType.values.firstWhere(
        (e) => e.name == json['recurrence_type'],
        orElse: () => RecurrenceType.none,
      ),
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.parse(json['recurrence_end_date'] as String)
          : null,
      reminderMinutes: json['reminder_minutes'] as int? ?? 30,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'event_type': eventType.name,
      'subject_id': subjectId,
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'is_all_day': isAllDay,
      'location': location,
      'priority': priority.name,
      'color_code': colorCode,
      'is_completed': isCompleted,
      'recurrence_type': recurrenceType.name,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'reminder_minutes': reminderMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CalendarEvent copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    CalendarEventType? eventType,
    String? subjectId,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isAllDay,
    String? location,
    EventPriority? priority,
    String? colorCode,
    bool? isCompleted,
    RecurrenceType? recurrenceType,
    DateTime? recurrenceEndDate,
    int? reminderMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      subjectId: subjectId ?? this.subjectId,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      priority: priority ?? this.priority,
      colorCode: colorCode ?? this.colorCode,
      isCompleted: isCompleted ?? this.isCompleted,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration get duration => endDateTime.difference(startDateTime);

  bool get isToday {
    final now = DateTime.now();
    return startDateTime.day == now.day &&
        startDateTime.month == now.month &&
        startDateTime.year == now.year;
  }

  bool get isUpcoming => startDateTime.isAfter(DateTime.now());

  bool get isOverdue => !isCompleted && endDateTime.isBefore(DateTime.now());
}

enum CalendarEventType {
  studySession,
  assignment,
  exam,
  break_,
  reminder,
  deadline,
  custom
}

enum EventPriority { low, medium, high, urgent }

enum RecurrenceType { none, daily, weekly, monthly }

class AssignmentCalendar {
  final String id;
  final String userId;
  final String title;
  final String? subjectId;
  final DateTime dueDate;
  final EventPriority priority;
  final int estimatedDurationMinutes;
  final bool isCompleted;
  final DateTime? completionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignmentCalendar({
    required this.id,
    required this.userId,
    required this.title,
    this.subjectId,
    required this.dueDate,
    this.priority = EventPriority.medium,
    this.estimatedDurationMinutes = 60,
    this.isCompleted = false,
    this.completionDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentCalendar.fromJson(Map<String, dynamic> json) {
    return AssignmentCalendar(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      subjectId: json['subject_id'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      priority: EventPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => EventPriority.medium,
      ),
      estimatedDurationMinutes:
          json['estimated_duration_minutes'] as int? ?? 60,
      isCompleted: json['is_completed'] as bool? ?? false,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'subject_id': subjectId,
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_completed': isCompleted,
      'completion_date': completionDate?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.day == now.day &&
        dueDate.month == now.month &&
        dueDate.year == now.year;
  }

  bool get isDueSoon => dueDate.difference(DateTime.now()).inDays <= 3;
}
