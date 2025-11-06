import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Initialize
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User ID
  static Future<void> setUserId(String userId) async {
    await _prefs?.setString('userId', userId);
  }

  static String? getUserId() {
    return _prefs?.getString('userId');
  }

  // FCM Token
  static Future<void> setFcmToken(String token) async {
    await _prefs?.setString('fcmToken', token);
  }

  static String? getFcmToken() {
    return _prefs?.getString('fcmToken');
  }

  // User data
  static Future<void> setUser(User user) async {
    await _prefs?.setString('user', json.encode(user.toJson()));
  }

  static User? getUser() {
    final userJson = _prefs?.getString('user');
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Email
  static Future<void> setEmail(String email) async {
    await _prefs?.setString('email', email);
  }

  static String? getEmail() {
    return _prefs?.getString('email');
  }

  // First launch
  static Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs?.setBool('firstLaunch', isFirst);
  }

  static bool getFirstLaunch() {
    return _prefs?.getBool('firstLaunch') ?? true;
  }

  // Language preference
  static Future<void> setLanguage(String language) async {
    await _prefs?.setString('language', language);
  }

  static String getLanguage() {
    return _prefs?.getString('language') ?? 'en';
  }

  // Notification enabled
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool('notificationsEnabled', enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool('notificationsEnabled') ?? true;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Clear user data (logout)
  static Future<void> clearUserData() async {
    await _prefs?.remove('user');
    await _prefs?.remove('email');
  }
}
