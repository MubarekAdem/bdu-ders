import 'package:flutter/material.dart';
import '../models/lecture.dart';
import '../services/api_service.dart';

class LectureProvider with ChangeNotifier {
  List<Lecture> _lectures = [];
  bool _isLoading = false;
  String? _error;

  List<Lecture> get lectures => _lectures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setLectures(List<Lecture> lectures) {
    _lectures = lectures;
    notifyListeners();
  }

  Future<void> loadLectures() async {
    _setLoading(true);
    _setError(null);

    try {
      final lectures = await ApiService.getLectures();
      _setLectures(lectures);
    } catch (e) {
      _setError('Failed to load lectures: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createLecture({
    required String title,
    required String timeStart,
    required String timeEnd,
    required List<String> days,
    required String location,
    required String lecturerName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.createLecture(
        title: title,
        timeStart: timeStart,
        timeEnd: timeEnd,
        days: days,
        location: location,
        lecturerName: lecturerName,
      );

      if (response['lecture'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to create lecture');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLecture({
    required String id,
    String? title,
    String? timeStart,
    String? timeEnd,
    List<String>? days,
    String? location,
    String? lecturerName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.updateLecture(
        id: id,
        title: title,
        timeStart: timeStart,
        timeEnd: timeEnd,
        days: days,
        location: location,
        lecturerName: lecturerName,
      );

      if (response['lecture'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to update lecture');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteLecture(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.deleteLecture(id);

      if (response['message'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to delete lecture');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markLecture(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.markLecture(id);

      if (response['lecture'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to mark lecture');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> unmarkLecture(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.unmarkLecture(id);

      if (response['lecture'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to unmark lecture');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Lecture> getMarkedLectures() {
    return _lectures.where((lecture) => lecture.isMarked).toList();
  }

  List<Lecture> getUnmarkedLectures() {
    return _lectures.where((lecture) => !lecture.isMarked).toList();
  }

  List<Lecture> getMarkedLecturesForToday() {
    return _lectures.where((lecture) => lecture.isMarkedForToday).toList();
  }

  List<Lecture> getUnmarkedLecturesForToday() {
    return _lectures.where((lecture) => !lecture.isMarkedForToday).toList();
  }

  List<Lecture> getLecturesByDay(String day) {
    return _lectures.where((lecture) => lecture.days.contains(day)).toList();
  }

  List<Lecture> getAllLecturesByDay(String day) {
    return _lectures.where((lecture) => lecture.days.contains(day)).toList();
  }

  List<Lecture> getTodaysLectures() {
    final today = DateTime.now();
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
    return _lectures
        .where((lecture) => lecture.days.contains(todayName))
        .toList();
  }

  // Availability management methods
  Future<bool> updateLectureAvailability({
    required String id,
    required String day,
    required bool available,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.updateLectureAvailability(
        id: id,
        day: day,
        available: available,
      );

      if (response['lecture'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to update lecture availability');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Date-specific availability management
  Future<bool> updateLectureDateAvailability({
    required String id,
    required String date,
    required bool available,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.updateLectureDateAvailability(
        id: id,
        date: date,
        available: available,
      );

      if (response['lecture'] != null) {
        await loadLectures(); // Refresh the list
        return true;
      } else {
        _setError(
          response['error'] ?? 'Failed to update lecture date availability',
        );
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getLectureAvailability(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.getLectureAvailability(id);
      return response;
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Filter lectures by availability
  List<Lecture> getAvailableLecturesForDay(String day) {
    return _lectures
        .where(
          (lecture) =>
              lecture.days.contains(day) && lecture.isAvailableForDay(day),
        )
        .toList();
  }

  List<Lecture> getLecturesNotAvailableForDay(String day) {
    return _lectures
        .where(
          (lecture) =>
              lecture.days.contains(day) && !lecture.isAvailableForDay(day),
        )
        .toList();
  }

  List<Lecture> getAvailableLecturesForToday() {
    final today = DateTime.now();
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
    return getAvailableLecturesForDay(todayName);
  }

  void clearError() {
    _setError(null);
  }
}
