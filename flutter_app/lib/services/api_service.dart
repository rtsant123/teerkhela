import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/result.dart';
import '../models/prediction.dart';
import '../models/user.dart';
import '../models/dream_interpretation.dart';
import '../models/game.dart';
import '../models/forum_post.dart';
import '../models/accuracy_stats.dart';

class ApiService {
  // Railway backend URL
  static const String baseUrl = 'https://teerkhela-production.up.railway.app/api';

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

  // Get all games
  static Future<List<TeerGame>> getGames() async {
    try {
      final response = await _get('/games');

      if (response['success']) {
        final List<dynamic> data = response['data'];
        return data.map((json) => TeerGame.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get games');
      }
    } catch (e) {
      // Return default games if API fails
      return [
        TeerGame(id: 1, name: 'shillong', displayName: 'Shillong Teer', region: 'Meghalaya', isActive: true, scrapeEnabled: true, displayOrder: 1),
        TeerGame(id: 2, name: 'khanapara', displayName: 'Khanapara Teer', region: 'Assam', isActive: true, scrapeEnabled: true, displayOrder: 2),
        TeerGame(id: 3, name: 'juwai', displayName: 'Juwai Teer', region: 'Meghalaya', isActive: true, scrapeEnabled: true, displayOrder: 3),
        TeerGame(id: 4, name: 'bhutan', displayName: 'Bhutan Teer', region: 'Bhutan', isActive: true, scrapeEnabled: true, displayOrder: 4),
      ];
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

  // Create test premium user
  static Future<User> createTestUser() async {
    final response = await _get('/create-test-user');

    if (response['success']) {
      return User(
        userId: response['userId'],
        email: null,
        isPremium: response['isPremium'] ?? true,
        expiryDate: response['expiryDate'],
        daysLeft: 30,
        subscriptionId: null,
      );
    } else {
      throw Exception('Failed to create test user');
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

  // AI Common Numbers (premium only)
  static Future<Map<String, dynamic>> getAICommonNumbers(String game) async {
    final response = await _get('/ai-common-numbers/$game');

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to get AI common numbers');
    }
  }

  // AI Lucky Numbers (premium only)
  static Future<Map<String, dynamic>> getAILuckyNumbers(String game) async {
    final response = await _get('/ai-lucky-numbers/$game');

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to get AI lucky numbers');
    }
  }

  // AI Hit Numbers (premium only)
  static Future<Map<String, dynamic>> getAIHitNumbers(String game, {int days = 7}) async {
    final response = await _get('/ai-hit-numbers/$game?days=$days');

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to get AI hit numbers');
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

  // Activate test subscription (for testing purposes)
  static Future<void> activateTestSubscription({
    required String userId,
    required String subscriptionId,
    required DateTime expiryDate,
  }) async {
    await _post('/subscriptions/activate-test', {
      'userId': userId,
      'subscriptionId': subscriptionId,
      'expiryDate': expiryDate.toIso8601String(),
      'isTest': true,
    });
  }

  // ========== COMMUNITY FORUM METHODS ==========

  // Get forum posts for a specific game (or all games if game is null/empty)
  static Future<List<ForumPost>> getForumPosts({String? game}) async {
    String endpoint;
    if (game != null && game.isNotEmpty && game != 'all') {
      endpoint = '/forum/posts/game/$game';
    } else {
      endpoint = '/forum/posts/latest';
    }

    final response = await _get(endpoint);

    if (response['success']) {
      final List<dynamic> posts = response['posts'] ?? response['data'] ?? [];
      return posts.map((json) => ForumPost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get forum posts');
    }
  }

  // Create a new forum post
  static Future<ForumPost> createForumPost({
    required String userId,
    required String username,
    required String game,
    required String predictionType,
    required List<int> numbers,
    required int confidence,
    required String description,
  }) async {
    final response = await _post('/forum/posts', {
      'userId': userId,
      'username': username,
      'game': game,
      'predictionType': predictionType,
      'numbers': numbers,
      'confidence': confidence,
      'description': description,
    });

    if (response['success']) {
      return ForumPost.fromJson(response['data']);
    } else {
      throw Exception('Failed to create forum post');
    }
  }

  // Like a post
  static Future<void> likePost(String postId, String userId) async {
    await _post('/forum/posts/$postId/like', {
      'userId': userId,
    });
  }

  // Unlike a post
  static Future<void> unlikePost(String postId, String userId) async {
    await _post('/forum/posts/$postId/unlike', {
      'userId': userId,
    });
  }

  // Get community trends for a game (most common predicted numbers)
  static Future<Map<String, dynamic>> getCommunityTrends({
    required String game,
    required String predictionType,
  }) async {
    final response = await _get('/forum/trends?game=$game&predictionType=$predictionType');

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to get community trends');
    }
  }

  // ========== REFERRAL PROGRAM METHODS ==========

  // Get referral stats for a user
  static Future<Map<String, dynamic>> getReferralStats(String userId) async {
    final response = await _get('/referral/$userId/code');

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to get referral stats');
    }
  }

  // Apply a referral code
  static Future<bool> applyReferralCode(String userId, String code) async {
    final response = await _post('/referral/$userId/apply', {
      'code': code,
    });

    if (response['success']) {
      return true;
    } else {
      throw Exception(response['message'] ?? 'Failed to apply referral code');
    }
  }

  // Claim referral rewards
  static Future<Map<String, dynamic>> claimReferralRewards(String userId) async {
    final response = await _post('/referral/$userId/claim', {});

    if (response['success']) {
      return response['data'];
    } else {
      throw Exception('Failed to claim referral rewards');
    }
  }

  // Get referral leaderboard
  static Future<List> getReferralLeaderboard() async {
    final response = await _get('/referral/leaderboard');

    if (response['success']) {
      return response['data'] as List;
    } else {
      throw Exception('Failed to get referral leaderboard');
    }
  }

  // ========== ACCURACY STATS METHODS ==========

  // Get overall accuracy stats
  static Future<AccuracyStats> getAccuracyStats({String? game, int days = 30}) async {
    String endpoint = '/accuracy/overall?days=$days';
    if (game != null && game.isNotEmpty) {
      endpoint = '/accuracy/$game?days=$days';
    }

    final response = await _get(endpoint);

    if (response['success']) {
      // Backend returns: { success, days, accuracy, recentPredictions, bestGames }
      // We need to extract and transform to match AccuracyStats model
      final accuracy = response['accuracy'] ?? {};
      final recentPredictions = response['recentPredictions'] ?? [];

      return AccuracyStats.fromJson({
        'overallAccuracy': accuracy['overall'] ?? 0.0,
        'frAccuracy': accuracy['fr'] ?? 0.0,
        'srAccuracy': accuracy['sr'] ?? 0.0,
        'totalPredictions': accuracy['totalPredictions'] ?? 0,
        'successfulPredictions': accuracy['successful'] ?? 0,
        'bestPerformingGame': response['bestGames'] != null && (response['bestGames'] as List).isNotEmpty
            ? response['bestGames'][0]['game']
            : null,
        'lastPredictions': recentPredictions,
      });
    } else {
      throw Exception('Failed to get accuracy stats');
    }
  }

  // Get accuracy stats for a specific game
  static Future<AccuracyStats> getGameAccuracyStats(String game, {int days = 30}) async {
    final response = await _get('/accuracy/$game?days=$days');

    if (response['success']) {
      return AccuracyStats.fromJson(response['data']);
    } else {
      throw Exception('Failed to get game accuracy stats');
    }
  }
}
