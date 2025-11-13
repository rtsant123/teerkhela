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

  // Onboarding complete
  static Future<void> setOnboardingComplete(bool complete) async {
    await _prefs?.setBool('onboarding_complete', complete);
  }

  static bool getOnboardingComplete() {
    return _prefs?.getBool('onboarding_complete') ?? false;
  }

  // Phone number
  static Future<void> setPhoneNumber(String phoneNumber) async {
    await _prefs?.setString('phoneNumber', phoneNumber);
  }

  static String? getPhoneNumber() {
    return _prefs?.getString('phoneNumber');
  }

  // Login state
  static Future<void> setIsLoggedIn(bool isLoggedIn) async {
    await _prefs?.setBool('isLoggedIn', isLoggedIn);
  }

  static bool getIsLoggedIn() {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  // Dark Mode preference
  static Future<void> setDarkMode(bool isDarkMode) async {
    await _prefs?.setBool('darkMode', isDarkMode);
  }

  static Future<bool> getDarkMode() async {
    return _prefs?.getBool('darkMode') ?? false;
  }

  // Device ID (for device-based premium)
  static Future<void> setDeviceId(String deviceId) async {
    await _prefs?.setString('deviceId', deviceId);
  }

  static String? getDeviceId() {
    return _prefs?.getString('deviceId');
  }

  // Premium status (for guest users)
  static Future<void> setPremiumStatus(bool isPremium) async {
    await _prefs?.setBool('isPremium', isPremium);
  }

  static bool getPremiumStatus() {
    return _prefs?.getBool('isPremium') ?? false;
  }

  // Premium expiry date
  static Future<void> setPremiumExpiry(String expiryDate) async {
    await _prefs?.setString('premiumExpiry', expiryDate);
  }

  static String? getPremiumExpiry() {
    return _prefs?.getString('premiumExpiry');
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Clear user data (logout)
  static Future<void> clearUserData() async {
    await _prefs?.remove('user');
    await _prefs?.remove('email');
    await _prefs?.remove('phoneNumber');
    await _prefs?.remove('isLoggedIn');
  }
}
