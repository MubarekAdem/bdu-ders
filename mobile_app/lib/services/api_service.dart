import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lecture.dart';
import '../models/previous_lecture.dart';

class ApiService {
  static const String baseUrl = 'http://10.240.97.20:3000/api';
  static String? _token;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> validateToken() async {
    final token = await getToken();
    print('Validating token: ${token != null ? "EXISTS" : "NULL"}');
    if (token == null) return false;

    try {
      print('Making request to: $baseUrl/auth/me');

      // Add timeout to prevent hanging
      final response = await http
          .get(Uri.parse('$baseUrl/auth/me'), headers: _headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hasUser = data['user'] != null;
        print('Token validation result: $hasUser');
        return hasUser;
      } else {
        // Token is invalid, clear it
        print('Token invalid (status ${response.statusCode}), clearing it');
        await clearToken();
        return false;
      }
    } catch (e) {
      // Network error or invalid token, clear it
      print('Token validation error: $e');
      await clearToken();
      return false;
    }
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(
      'Failed to fetch data: ${data['error'] ?? 'Unknown error'}',
    );
  }

  // Authentication
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await setToken(data['token']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await setToken(data['token']);
    }
    return data;
  }

  // Lectures
  static Future<List<Lecture>> getLectures() async {
    final response = await http.get(
      Uri.parse('$baseUrl/lectures'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['lectures'] as List)
          .map((json) => Lecture.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load lectures');
  }

  static Future<Map<String, dynamic>> createLecture({
    required String title,
    required String timeStart,
    required String timeEnd,
    required List<String> days,
    required String location,
    required String lecturerName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lectures'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'days': days,
        'location': location,
        'lecturerName': lecturerName,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateLecture({
    required String id,
    String? title,
    String? timeStart,
    String? timeEnd,
    List<String>? days,
    String? location,
    String? lecturerName,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (timeStart != null) body['timeStart'] = timeStart;
    if (timeEnd != null) body['timeEnd'] = timeEnd;
    if (days != null) body['days'] = days;
    if (location != null) body['location'] = location;
    if (lecturerName != null) body['lecturerName'] = lecturerName;

    final response = await http.put(
      Uri.parse('$baseUrl/lectures/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteLecture(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/lectures/$id'),
      headers: _headers,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markLecture(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lectures/$id/mark'),
      headers: _headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(
      'Failed to mark lecture: ${data['error'] ?? 'Unknown error'}',
    );
  }

  static Future<Map<String, dynamic>> unmarkLecture(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/lectures/$id/mark'),
      headers: _headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(
      'Failed to unmark lecture: ${data['error'] ?? 'Unknown error'}',
    );
  }

  // Previous Lectures
  static Future<List<PreviousLecture>> getPreviousLectures() async {
    final response = await http.get(
      Uri.parse('$baseUrl/previous-lectures'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['previousLectures'] as List)
          .map((json) => PreviousLecture.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load previous lectures');
  }

  static Future<Map<String, dynamic>> createPreviousLecture({
    required String title,
    required DateTime date,
    required String telegramLink,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/previous-lectures'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'date': date.toIso8601String(),
        'telegramLink': telegramLink,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePreviousLecture({
    required String id,
    String? title,
    DateTime? date,
    String? telegramLink,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (date != null) body['date'] = date.toIso8601String();
    if (telegramLink != null) body['telegramLink'] = telegramLink;

    final response = await http.put(
      Uri.parse('$baseUrl/previous-lectures/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deletePreviousLecture(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/previous-lectures/$id'),
      headers: _headers,
    );

    return jsonDecode(response.body);
  }
}
