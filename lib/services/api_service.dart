import 'dart:convert';
import 'dart:io';
import 'package:grand_egyptian_museum/models/admin_stats.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../models/ticket_type.dart';
import '../models/selected_ticket.dart';
import '../models/booking_model.dart';
import '../models/hall_model.dart';

class ApiService {

  // ── Base URL ──────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else {
      return 'http://10.0.2.2:8080/api';
    }
  }

  static String? _token;
  static UserModel? currentUser;

  static void setToken(String token) => _token = token;
  static String? get token => _token;
  static bool get isLoggedIn => _token != null;
  static bool get isAdmin => currentUser?.role == 'ADMIN';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── AUTH ──────────────────────────────────────────────────
  static Future<UserModel> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['token'] != null) {
      setToken(data['token']);
      currentUser = UserModel.fromJson(data);
      return currentUser!;
    }

    throw Exception(data['message'] ?? 'Login failed');
  }

  static Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? country,
    String? nationalId,
    String? passportNumber,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'country': country,
        'nationalId': nationalId,
        'passportNumber': passportNumber,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['token'] != null) {
      setToken(data['token']);
      currentUser = UserModel.fromJson(data);
      return currentUser!;
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  static void logout() {
    _token = null;
    currentUser = null;
  }

  // ── HALLS ─────────────────────────────────────────────────
  static Future<List<HallModel>> getHalls() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/halls'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return (jsonDecode(res.body) as List)
            .map((j) => HallModel.fromJson(j))
            .toList();
      }
    } catch (e) {
      print("Error fetching halls: $e");
    }

    return HallsData.halls
        .map((j) => HallModel.fromJson(j))
        .toList();
  }

  static Future<HallModel> getHall(int id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/halls/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return HallModel.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      print("Error fetching hall: $e");
    }

    return HallModel.fromJson(
      HallsData.halls.firstWhere((h) => h['id'] == id),
    );
  }

  // ── TICKETS ───────────────────────────────────────────────
  static Future<List<TicketType>> getTicketTypes() async {
    final res = await http.get(
      Uri.parse('$baseUrl/tickets/types'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((j) => TicketType.fromJson(j))
          .toList();
    }

    throw Exception("Failed to load ticket types");
  }

  // ── BOOKINGS ──────────────────────────────────────────────
  static Future<BookingModel> createBooking({
    required String visitDate,
    required int? hallId,
    required List<SelectedTicket> tickets,
    required Map<String, String> paymentInfo,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers,
      body: jsonEncode({
        'visitDate': visitDate,
        'hallId': hallId,
        'tickets': tickets
            .where((t) => t.quantity > 0)
            .map((t) => {
          'type':     t.ticket.ticketType,
          'quantity': t.quantity,
          'price':    t.ticket.price,
        })
            .toList(),
        'payment': paymentInfo,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return BookingModel.fromJson(data);
    }

    throw Exception(data['message'] ?? 'Booking failed');
  }

  static Future<List<BookingModel>> getMyBookings() async {
    final res = await http.get(
      Uri.parse('$baseUrl/bookings/my'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List)
          .map((j) => BookingModel.fromJson(j))
          .toList();
    }

    throw Exception('Failed to load bookings');
  }

  // ── ADMIN ─────────────────────────────────────────────────
  static Future<AdminStats> getStatistics() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/statistics'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final Map<String, dynamic> data =
      jsonDecode(res.body) as Map<String, dynamic>;
      return AdminStats.fromJson(data);
    }

    throw Exception('Failed to load statistics');
  }

  static Future<HallModel> updateHall(
      int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/halls/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );

    if (res.statusCode == 200) {
      return HallModel.fromJson(jsonDecode(res.body));
    }

    throw Exception('Update failed');
  }

  static Future<List<dynamic>> getAdminUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List;
    }

    throw Exception('Failed to load users');
  }

  static Future<void> toggleBlockUser(int userId) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/block'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Block failed');
    }
  }

  static Future<void> deleteUser(int userId, String reason) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: _headers,
      body: jsonEncode({'reason': reason}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Delete failed');
    }
  }

  static Future<List<dynamic>> getAdminLogs() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/logs'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List;
    }

    throw Exception('Failed to load logs');
  }

  // ── IMAGE (URL) ───────────────────────────────────────────
  static Future<void> updateHallImage(int hallId, String imageUrl) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/halls/$hallId'),
      headers: _headers,
      body: jsonEncode({'imageUrl': imageUrl}),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['message'] ?? 'Update failed');
    }
  }

  // ── IMAGE (UPLOAD) ────────────────────────────────────────
  static Future<void> uploadHallImage(int hallId, File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/halls/$hallId/upload-image'),
      );

      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var response = await request.send();

      if (response.statusCode != 200) {
        final respStr = await response.stream.bytesToString();
        throw Exception(respStr);
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }
}