import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';

class PredictionsProvider with ChangeNotifier {
  Map<String, Prediction> _predictions = {};
  bool _isLoading = false;
  String? _error;

  Map<String, Prediction> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPredictions => _predictions.isNotEmpty;

  // Load predictions (premium only)
  Future<void> loadPredictions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _predictions = await ApiService.getPredictions(userId);
      _error = null;
    } catch (e) {
      if (e.toString().contains('PREMIUM_REQUIRED')) {
        _error = 'PREMIUM_REQUIRED';
      } else {
        _error = e.toString();
      }
      print('Error loading predictions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get prediction for specific game
  Prediction? getPredictionForGame(String game) {
    return _predictions[game];
  }

  // Clear predictions
  void clearPredictions() {
    _predictions = {};
    notifyListeners();
  }
}
