class DayAvailability {
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  DayAvailability({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      monday: json['Monday'] ?? true,
      tuesday: json['Tuesday'] ?? true,
      wednesday: json['Wednesday'] ?? true,
      thursday: json['Thursday'] ?? true,
      friday: json['Friday'] ?? true,
      saturday: json['Saturday'] ?? true,
      sunday: json['Sunday'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Monday': monday,
      'Tuesday': tuesday,
      'Wednesday': wednesday,
      'Thursday': thursday,
      'Friday': friday,
      'Saturday': saturday,
      'Sunday': sunday,
    };
  }

  DayAvailability copyWith({
    bool? monday,
    bool? tuesday,
    bool? wednesday,
    bool? thursday,
    bool? friday,
    bool? saturday,
    bool? sunday,
  }) {
    return DayAvailability(
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
    );
  }
}

class Lecture {
  final String id;
  final String title;
  final String timeStart;
  final String timeEnd;
  final List<String> days;
  final String location;
  final String lecturerName;
  final bool isMarked;
  final DateTime? markedDate;
  final List<DateTime>? markedDates;
  final DayAvailability dayAvailability;
  final Map<String, bool>?
  dateAvailability; // Date-specific availability (YYYY-MM-DD)
  final DateTime createdAt;

  Lecture({
    required this.id,
    required this.title,
    required this.timeStart,
    required this.timeEnd,
    required this.days,
    required this.location,
    required this.lecturerName,
    required this.isMarked,
    this.markedDate,
    this.markedDates,
    required this.dayAvailability,
    this.dateAvailability,
    required this.createdAt,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      timeStart: json['timeStart'] ?? '',
      timeEnd: json['timeEnd'] ?? '',
      days: List<String>.from(json['days'] ?? []),
      location: json['location'] ?? '',
      lecturerName: json['lecturerName'] ?? '',
      isMarked: json['isMarked'] ?? false, // Default to not marked
      markedDate: json['markedDate'] != null
          ? DateTime.parse(json['markedDate'])
          : null,
      markedDates: json['markedDates'] != null
          ? (json['markedDates'] as List)
                .map((date) => DateTime.parse(date))
                .toList()
          : null,
      dayAvailability: DayAvailability.fromJson(json['dayAvailability'] ?? {}),
      dateAvailability: json['dateAvailability'] != null
          ? Map<String, bool>.from(json['dateAvailability'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'days': days,
      'location': location,
      'lecturerName': lecturerName,
      'isMarked': isMarked,
      'markedDate': markedDate?.toIso8601String(),
      'markedDates': markedDates
          ?.map((date) => date.toIso8601String())
          .toList(),
      'dayAvailability': dayAvailability.toJson(),
      if (dateAvailability != null) 'dateAvailability': dateAvailability,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Check if this lecture is marked for a specific date
  bool isMarkedForDate(DateTime date) {
    if (markedDates == null) return false;

    final targetDate = DateTime(date.year, date.month, date.day);
    return markedDates!.any((markedDate) {
      final markedDay = DateTime(
        markedDate.year,
        markedDate.month,
        markedDate.day,
      );
      return markedDay.isAtSameMomentAs(targetDate);
    });
  }

  /// Check if this lecture is marked for today
  bool get isMarkedForToday {
    // First check the markedDates array
    if (markedDates != null && markedDates!.isNotEmpty) {
      return isMarkedForDate(DateTime.now());
    }
    // Fallback to the isMarked field if markedDates is not available
    return isMarked;
  }

  /// Check if this lecture is available for a specific day of the week
  bool isAvailableForDay(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
        return dayAvailability.monday;
      case 'tuesday':
        return dayAvailability.tuesday;
      case 'wednesday':
        return dayAvailability.wednesday;
      case 'thursday':
        return dayAvailability.thursday;
      case 'friday':
        return dayAvailability.friday;
      case 'saturday':
        return dayAvailability.saturday;
      case 'sunday':
        return dayAvailability.sunday;
      default:
        return false;
    }
  }

  /// Check if this lecture is available for today
  bool get isAvailableForToday {
    final today = DateTime.now();
    final todayString = _formatDateString(today);

    // First check date-specific availability
    if (dateAvailability != null &&
        dateAvailability!.containsKey(todayString)) {
      return dateAvailability![todayString]!;
    }

    // Fall back to day-of-week availability
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final todayName = dayNames[today.weekday - 1];
    return isAvailableForDay(todayName);
  }

  /// Check if this lecture is available for a specific date
  bool isAvailableForDate(DateTime date) {
    final dateString = _formatDateString(date);

    // First check date-specific availability
    if (dateAvailability != null && dateAvailability!.containsKey(dateString)) {
      return dateAvailability![dateString]!;
    }

    // Fall back to day-of-week availability
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = dayNames[date.weekday - 1];
    return isAvailableForDay(dayName);
  }

  /// Format date as YYYY-MM-DD string
  String _formatDateString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
