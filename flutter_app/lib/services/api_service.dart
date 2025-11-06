import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/result.dart';
import '../models/prediction.dart';
import '../models/user.dart';
import '../models/dream_interpretation.dart';

class ApiService {
  // Change this to your Railway backend URL
  static const String baseUrl = 'http://localhost:5000/api';
  // Production: static const String baseUrl = 'https://your-railway-app.up.railway.app/api';

  // GET request helper
  static Future<Map<String, dynamic>> _get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers ?? {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request helper
  static Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers ?? {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Register user
  static Future<String> registerUser(String fcmToken, String deviceInfo) async {
    final response = await _post('/user/register', {
      'fcmToken': fcmToken,
      'deviceInfo': deviceInfo,
    });

    return response['userId'];
  }

  // Get user status
  static Future<User> getUserStatus(String userId) async {
    final response = await _get('/user/$userId/status');

    if (response['success']) {
      return User.fromJson(response['data']);
    } else {
      throw Exception('Failed to get user status');
    }
  }

  // Update FCM token
  static Future<void> updateFcmToken(String userId, String fcmToken) async {
    await _post('/user/fcm-token', {
      'userId': userId,
      'fcmToken': fcmToken,
    });
  }

  // Get all current results
  static Future<Map<String, TeerResult>> getResults() async {
    final response = await _get('/results');

    if (response['success']) {
      final Map<String, TeerResult> results = {};
      final data = response['data'] as Map<String, dynamic>;

      data.forEach((key, value) {
        results[key] = TeerResult.fromJson(value as Map<String, dynamic>);
      });

      return results;
    } else {
      throw Exception('Failed to get results');
    }
  }

  // Get result history
  static Future<List<TeerResult>> getResultHistory(String game, int days, String? userId) async {
    String endpoint = '/results/$game/history?days=$days';
    if (userId != null) {
      endpoint += '&userId=$userId';
    }

    final response = await _get(endpoint);

    if (response['success']) {
      final List<dynamic> data = response['data'];
      return data.map((json) => TeerResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get result history');
    }
  }

  // Get predictions (premium only)
  static Future<Map<String, Prediction>> getPredictions(String userId) async {
    final response = await _get('/predictions?userId=$userId');

    if (response['success']) {
      final Map<String, Prediction> predictions = {};
      final data = response['data'] as Map<String, dynamic>;

      data.forEach((key, value) {
        predictions[key] = Prediction.fromJson(value as Map<String, dynamic>);
      });

      return predictions;
    } else if (response['premiumRequired'] == true) {
      throw Exception('PREMIUM_REQUIRED');
    } else {
      throw Exception('Failed to get predictions');
    }
  }

  // Interpret dream (premium only)
  static Future<DreamInterpretation> interpretDream(String userId, String dream, String language, String targetGame) async {
    final response = await _post('/dream-interpret', {
      'userId': userId,
      'dream': dream,
      'language': language,
      'targetGame': targetGame,
    });

    if (response['success']) {
      return DreamInterpretation.fromJson(response['data']);
    } else if (response['premiumRequired'] == true) {
      throw Exception('PREMIUM_REQUIRED');
    } else {
      throw Exception('Failed to interpret dream');
    }
  }

  // Get common numbers
  static Future<Map<String, dynamic>> getCommonNumbers(String game, String? userId) async {
    String endpoint = '/common-numbers/$game';
    if (userId != null) {
      endpoint += '?userId=$userId';
    }

    final response = await _get(endpoint);

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to get common numbers');
    }
  }

  // Calculate formula (premium only)
  static Future<Map<String, dynamic>> calculateFormula(String userId, String game, String formulaType, List<Map<String, int>> previousResults) async {
    final response = await _post('/calculate-formula', {
      'userId': userId,
      'game': game,
      'formulaType': formulaType,
      'previousResults': previousResults,
    });

    if (response['success']) {
      return response['data'];
    } else if (response['premiumRequired'] == true) {
      throw Exception('PREMIUM_REQUIRED');
    } else {
      throw Exception('Failed to calculate formula');
    }
  }

  // Create subscription
  static Future<Map<String, dynamic>> createSubscription(String userId, String email, String planId) async {
    final response = await _post('/payment/create-subscription', {
      'userId': userId,
      'email': email,
      'planId': planId,
    });

    if (response['success']) {
      return {
        'subscriptionId': response['subscriptionId'],
        'status': response['status'],
        'shortUrl': response['shortUrl'],
      };
    } else {
      throw Exception('Failed to create subscription');
    }
  }

  // Cancel subscription
  static Future<void> cancelSubscription(String userId, String subscriptionId) async {
    await _post('/payment/cancel-subscription', {
      'userId': userId,
      'subscriptionId': subscriptionId,
    });
  }
}
