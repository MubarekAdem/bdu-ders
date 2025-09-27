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
}
