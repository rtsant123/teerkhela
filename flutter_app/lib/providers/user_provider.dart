import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _user?.isPremium ?? false;
  String? get userId => _user?.userId;

  // Initialize user from storage
  Future<void> initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to get user from storage
      final storedUser = StorageService.getUser();
      if (storedUser != null) {
        _user = storedUser;
        notifyListeners();

        // Refresh user status from API
        await refreshUserStatus();
      } else {
        // Create new user
        await _createNewUser();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new user
  Future<void> _createNewUser() async {
    try {
      final fcmToken = StorageService.getFcmToken() ?? '';
      final deviceInfo = 'Android'; // You can get actual device info

      final userId = await ApiService.registerUser(fcmToken, deviceInfo);
      await StorageService.setUserId(userId);

      // Get user status
      final user = await ApiService.getUserStatus(userId);
      _user = user;
      await StorageService.setUser(user);

      notifyListeners();
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  // Refresh user status from API
  Future<void> refreshUserStatus() async {
    if (_user == null) return;

    try {
      final user = await ApiService.getUserStatus(_user!.userId);
      _user = user;
      await StorageService.setUser(user);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error refreshing user status: $e');
    }
  }

  // Set premium status (called after successful payment)
  void setPremium(bool isPremium) {
    if (_user != null) {
      _user = User(
        userId: _user!.userId,
        email: _user!.email,
        isPremium: isPremium,
        expiryDate: _user!.expiryDate,
        daysLeft: _user!.daysLeft,
        subscriptionId: _user!.subscriptionId,
      );
      StorageService.setUser(_user!);
      notifyListeners();
    }
  }

  // Update email
  void updateEmail(String email) {
    if (_user != null) {
      _user = User(
        userId: _user!.userId,
        email: email,
        isPremium: _user!.isPremium,
        expiryDate: _user!.expiryDate,
        daysLeft: _user!.daysLeft,
        subscriptionId: _user!.subscriptionId,
      );
      StorageService.setUser(_user!);
      StorageService.setEmail(email);
      notifyListeners();
    }
  }

  // Use test premium user
  Future<void> useTestUser() async {
    try {
      final testUser = await ApiService.createTestUser();
      _user = testUser;
      await StorageService.setUser(testUser);
      await StorageService.setUserId(testUser.userId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Error using test user: $e');
      throw e;
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    await StorageService.clearUserData();
    notifyListeners();
  }
}
