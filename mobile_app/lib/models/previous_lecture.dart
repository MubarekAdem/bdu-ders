class PreviousLecture {
  final String id;
  final String title;
  final DateTime date;
  final String telegramLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  PreviousLecture({
    required this.id,
    required this.title,
    required this.date,
    required this.telegramLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PreviousLecture.fromJson(Map<String, dynamic> json) {
    return PreviousLecture(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: DateTime.parse(json['date']),
      telegramLink: json['telegramLink'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'telegramLink': telegramLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to format date for display
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get relative date (e.g., "2 days ago")
  String get relativeDate {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}
