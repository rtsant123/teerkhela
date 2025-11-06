import 'package:flutter/material.dart';
import '../models/result.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class ResultsProvider with ChangeNotifier {
  Map<String, TeerResult> _results = {};
  bool _isLoading = false;
  String? _error;

  Map<String, TeerResult> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all current results
  Future<void> loadResults() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await ApiService.getResults();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading results: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get result for specific game
  TeerResult? getResultForGame(String game) {
    return _results[game];
  }

  // Get result history for a game
  Future<List<TeerResult>> getHistory(String game, String? userId) async {
    try {
      // Premium users get 30 days, free users get 7 days
      final days = 30; // API will limit based on user status
      return await ApiService.getResultHistory(game, days, userId);
    } catch (e) {
      print('Error getting history: $e');
      throw e;
    }
  }

  // Get common numbers for a game
  Future<Map<String, dynamic>> getCommonNumbers(String game, String? userId) async {
    try {
      return await ApiService.getCommonNumbers(game, userId);
    } catch (e) {
      print('Error getting common numbers: $e');
      throw e;
    }
  }
}
