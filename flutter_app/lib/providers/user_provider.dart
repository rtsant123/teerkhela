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
  bool get isPremium {
    // Check local storage first (for users who paid via Razorpay)
    final localPremium = StorageService.getPremiumStatus();
    if (localPremium) {
      // Check if not expired
      final expiryStr = StorageService.getPremiumExpiry();
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isBefore(expiry)) {
          return true;
        }
      }
    }
    // Fall back to user object
    return _user?.isPremium ?? false;
  }
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

  // Initialize user with device ID (no login required)
  Future<void> initializeWithDeviceId(String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists in storage
      final storedUser = StorageService.getUser();
      if (storedUser != null) {
        _user = storedUser;
        // Refresh premium status from API (skips for test users)
        await refreshUserStatus();
      } else {
        // Create new user with device ID
        final userId = deviceId;
        await StorageService.setUserId(userId);

        // Create user object (starts as free user)
        _user = User(
          userId: userId,
          isPremium: false,
          isGuest: false,
        );

        // Try to register with backend
        try {
          final fcmToken = StorageService.getFcmToken() ?? '';
          await ApiService.registerUser(fcmToken, 'Android - $deviceId');

          // Get user status from backend
          final backendUser = await ApiService.getUserStatus(userId);
          _user = backendUser;
        } catch (e) {
          print('Backend registration failed, using local user: $e');
        }

        // Save user to storage
        await StorageService.setUser(_user!);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error initializing with device ID: $e');
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
      // Silently fail for test users or network errors
      // Real users will sync on next successful call
      print('Could not refresh user status (this is OK for test users): $e');
      // Don't set error to avoid showing error to user
    }
  }

  // Load user status (alias for refreshUserStatus for compatibility)
  Future<void> loadUserStatus() async {
    await refreshUserStatus();
  }

  // Set premium status (called after successful payment)
  void setPremium(bool isPremium) {
    if (_user != null) {
      _user = User(
        userId: _user!.userId,
        email: _user!.email,
        phoneNumber: _user!.phoneNumber,
        name: _user!.name,
        isPremium: isPremium,
        expiryDate: _user!.expiryDate,
        daysLeft: _user!.daysLeft,
        subscriptionId: _user!.subscriptionId,
        isGuest: _user!.isGuest,
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
        phoneNumber: _user!.phoneNumber,
        name: _user!.name,
        isPremium: _user!.isPremium,
        expiryDate: _user!.expiryDate,
        daysLeft: _user!.daysLeft,
        subscriptionId: _user!.subscriptionId,
        isGuest: _user!.isGuest,
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

  // Activate test premium (calls backend to create real test user)
  Future<void> activateTestPremium(int days) async {
    try {
      print('Activating test premium for $days days...');

      if (_user == null) {
        print('Error: User is null. Cannot activate premium.');
        throw Exception('User not initialized. Please restart the app.');
      }

      // Create test subscription with backend
      final testSubscriptionId = 'test_${_user!.userId}_${DateTime.now().millisecondsSinceEpoch}';
      final expiryDate = DateTime.now().add(Duration(days: days));

      // Call backend to activate test premium (creates user in DB)
      await ApiService.activateTestSubscription(
        userId: _user!.userId,
        subscriptionId: testSubscriptionId,
        expiryDate: expiryDate,
      );

      // Try to refresh from backend to get updated premium status
      // If this fails (user not in DB yet), update locally
      try {
        await refreshUserStatus();
      } catch (e) {
        print('Could not refresh from backend, updating locally: $e');
        // Update user locally with premium status
        _user = User(
          userId: _user!.userId,
          email: _user!.email,
          phoneNumber: _user!.phoneNumber,
          name: _user!.name,
          isPremium: true,
          expiryDate: expiryDate,
          daysLeft: days,
          subscriptionId: testSubscriptionId,
          isGuest: _user!.isGuest,
        );

        await StorageService.setUser(_user!);
        notifyListeners();
      }

      print('Test premium activated successfully via backend. isPremium: ${_user!.isPremium}');
    } catch (e) {
      print('Error activating test premium: $e');
      throw Exception('Failed to activate test premium. Please check your internet connection.');
    }
  }

  // Logout
  Future<void> logout() async {
    _user = null;
    await StorageService.clearUserData();
    notifyListeners();
  }

  // Phone Authentication Methods

  // Send OTP for signup
  Future<void> sendOtp(String phoneNumber) async {
    // Simulate OTP sending (in production, call your backend API)
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, we'll just simulate success
    // In production, you would call your backend to send SMS
    print('OTP sent to $phoneNumber');

    // Store the phone number temporarily
    await StorageService.setPhoneNumber(phoneNumber);
  }

  // Signup with phone number
  Future<void> signupWithPhone(String phoneNumber, String name, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate OTP verification (in production, verify with backend)
      await Future.delayed(const Duration(seconds: 1));

      // For demo, accept any 6-digit OTP
      if (otp.length != 6) {
        throw Exception('Invalid OTP');
      }

      // Create user ID (in production, get from backend)
      final userId = 'USER_${DateTime.now().millisecondsSinceEpoch}';

      // Create user object
      _user = User(
        userId: userId,
        phoneNumber: phoneNumber,
        name: name,
        isPremium: false,
        isGuest: false,
      );

      // Save to storage
      await StorageService.setUser(_user!);
      await StorageService.setUserId(userId);
      await StorageService.setPhoneNumber(phoneNumber);
      await StorageService.setIsLoggedIn(true);

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error during signup: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with phone number
  Future<void> loginWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate login (in production, verify with backend)
      await Future.delayed(const Duration(seconds: 1));

      // Check if user exists in storage
      final storedPhone = StorageService.getPhoneNumber();

      if (storedPhone == phoneNumber) {
        // User exists, load their data
        final storedUser = StorageService.getUser();
        if (storedUser != null) {
          _user = storedUser;
        } else {
          // Create new user with this phone
          final userId = 'USER_${DateTime.now().millisecondsSinceEpoch}';
          _user = User(
            userId: userId,
            phoneNumber: phoneNumber,
            isPremium: false,
            isGuest: false,
          );
          await StorageService.setUser(_user!);
          await StorageService.setUserId(userId);
        }
      } else {
        // New phone number, create new user
        final userId = 'USER_${DateTime.now().millisecondsSinceEpoch}';
        _user = User(
          userId: userId,
          phoneNumber: phoneNumber,
          isPremium: false,
          isGuest: false,
        );
        await StorageService.setUser(_user!);
        await StorageService.setUserId(userId);
        await StorageService.setPhoneNumber(phoneNumber);
      }

      await StorageService.setIsLoggedIn(true);
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error during login: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Skip login (guest mode)
  Future<void> skipLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Create guest user
      final userId = 'GUEST_${DateTime.now().millisecondsSinceEpoch}';
      _user = User(
        userId: userId,
        isPremium: false,
        isGuest: true,
      );

      await StorageService.setUser(_user!);
      await StorageService.setUserId(userId);
      await StorageService.setIsLoggedIn(false);

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error during skip login: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _user?.isLoggedIn ?? false;
  bool get isGuest => _user?.isGuest ?? true;
}
