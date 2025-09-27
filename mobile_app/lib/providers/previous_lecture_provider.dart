import 'package:flutter/material.dart';
import '../models/previous_lecture.dart';
import '../services/api_service.dart';

class PreviousLectureProvider with ChangeNotifier {
  List<PreviousLecture> _previousLectures = [];
  bool _isLoading = false;
  String? _error;

  List<PreviousLecture> get previousLectures => _previousLectures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPreviousLectures() async {
    _setLoading(true);
    _clearError();

    try {
      final lectures = await ApiService.getPreviousLectures();
      _previousLectures = lectures;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load previous lectures: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPreviousLecture({
    required String title,
    required DateTime date,
    required String telegramLink,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.createPreviousLecture(
        title: title,
        date: date,
        telegramLink: telegramLink,
      );

      if (response['success'] == true) {
        // Add the new lecture to the beginning of the list
        final newLecture = PreviousLecture.fromJson(response['previousLecture']);
        _previousLectures.insert(0, newLecture);
        notifyListeners();
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to create previous lecture');
        return false;
      }
    } catch (e) {
      _setError('Failed to create previous lecture: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePreviousLecture({
    required String id,
    String? title,
    DateTime? date,
    String? telegramLink,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.updatePreviousLecture(
        id: id,
        title: title,
        date: date,
        telegramLink: telegramLink,
      );

      if (response['success'] == true) {
        // Update the lecture in the list
        final updatedLecture = PreviousLecture.fromJson(response['previousLecture']);
        final index = _previousLectures.indexWhere((lecture) => lecture.id == id);
        if (index != -1) {
          _previousLectures[index] = updatedLecture;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to update previous lecture');
        return false;
      }
    } catch (e) {
      _setError('Failed to update previous lecture: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePreviousLecture(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.deletePreviousLecture(id);

      if (response['success'] == true) {
        // Remove the lecture from the list
        _previousLectures.removeWhere((lecture) => lecture.id == id);
        notifyListeners();
        return true;
      } else {
        _setError(response['error'] ?? 'Failed to delete previous lecture');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete previous lecture: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
