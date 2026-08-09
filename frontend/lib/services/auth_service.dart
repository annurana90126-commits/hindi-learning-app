import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  // ─── REGISTER ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Save token and user data
        await _storage.write(key: AppConstants.tokenKey, value: data['token']);
        await _storage.write(
          key: AppConstants.userKey,
          value: jsonEncode(data['user']),
        );
        return {'success': true, 'user': data['user']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server. Check your connection.',
      };
    }
  }

  // ─── LOGIN ─────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _storage.write(key: AppConstants.tokenKey, value: data['token']);
        await _storage.write(
          key: AppConstants.userKey,
          value: jsonEncode(data['user']),
        );
        return {'success': true, 'user': data['user']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Cannot connect to server. Check your connection.',
      };
    }
  }

  // ─── SAVE USER (NEW) ───────────────────────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  // ─── LOGOUT ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  // ─── GET SAVED TOKEN ───────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    return _storage.read(key: AppConstants.tokenKey);
  }

  // ─── GET SAVED USER ────────────────────────────────────────────────────────
  static Future<UserModel?> getSavedUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);

    if (userJson == null) return null;

    final map = jsonDecode(userJson);

    return UserModel.fromJson(map);
  }

  // ─── IS LOGGED IN ──────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ─── GET LATEST USER FROM SERVER ─────────────────────────────────────────────
static Future<UserModel?> getProfile() async {
  try {
    final token = await getToken();

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Save latest user locally
      await _storage.write(
        key: AppConstants.userKey,
        value: jsonEncode(data['user']),
      );

      return UserModel.fromJson(data['user']);
    }

    return null;
  } catch (e) {
    return null;
  }
}
}