import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserRecord {
  const UserRecord({
    required this.name,
    required this.email,
    required this.phone,
    required this.lifeStory,
  });

  final String name;
  final String email;
  final String phone;
  final String lifeStory;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'lifeStory': lifeStory,
      };

  factory UserRecord.fromJson(Map<String, dynamic> json) => UserRecord(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        lifeStory: json['lifeStory'] as String? ?? '',
      );
}

class UserStorage {
  static const _usersKey = 'registered_users';
  static const _currentEmailKey = 'current_user_email';

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static Future<List<UserRecord>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(UserRecord.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> emailExists(String email) async {
    final normalized = normalizeEmail(email);
    final users = await getUsers();
    return users.any((user) => normalizeEmail(user.email) == normalized);
  }

  static Future<void> register(UserRecord user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    final normalized = normalizeEmail(user.email);

    if (users.any((u) => normalizeEmail(u.email) == normalized)) {
      throw StateError('Этот email уже зарегистрирован.');
    }

    users.add(user);
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
    await prefs.setString(_currentEmailKey, normalized);
  }

  static Future<UserRecord?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentEmailKey);
    if (email == null) return null;

    final users = await getUsers();
    for (final user in users) {
      if (normalizeEmail(user.email) == email) return user;
    }
    return null;
  }

  static Future<int> getUserCount() async => (await getUsers()).length;
}
