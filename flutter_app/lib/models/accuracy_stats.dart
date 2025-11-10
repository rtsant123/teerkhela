import 'package:flutter/material.dart';

class AccuracyStats {
  final double overallAccuracy;
  final double frAccuracy;
  final double srAccuracy;
  final int totalPredictions;
  final int successfulPredictions;
  final String? bestPerformingGame;
  final List<PredictionResult> lastPredictions;
  final Map<String, GameAccuracy>? gameStats;

  AccuracyStats({
    required this.overallAccuracy,
    required this.frAccuracy,
    required this.srAccuracy,
    required this.totalPredictions,
    required this.successfulPredictions,
    this.bestPerformingGame,
    required this.lastPredictions,
    this.gameStats,
  });

  factory AccuracyStats.fromJson(Map<String, dynamic> json) {
    return AccuracyStats(
      overallAccuracy: (json['overallAccuracy'] ?? 0).toDouble(),
      frAccuracy: (json['frAccuracy'] ?? 0).toDouble(),
      srAccuracy: (json['srAccuracy'] ?? 0).toDouble(),
      totalPredictions: json['totalPredictions'] ?? 0,
      successfulPredictions: json['successfulPredictions'] ?? 0,
      bestPerformingGame: json['bestPerformingGame'],
      lastPredictions: (json['lastPredictions'] as List<dynamic>?)
              ?.map((item) => PredictionResult.fromJson(item))
              .toList() ??
          [],
      gameStats: json['gameStats'] != null
          ? (json['gameStats'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                GameAccuracy.fromJson(value),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallAccuracy': overallAccuracy,
      'frAccuracy': frAccuracy,
      'srAccuracy': srAccuracy,
      'totalPredictions': totalPredictions,
      'successfulPredictions': successfulPredictions,
      'bestPerformingGame': bestPerformingGame,
      'lastPredictions': lastPredictions.map((p) => p.toJson()).toList(),
      'gameStats': gameStats?.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  String get accuracyPercentageText => '${overallAccuracy.toStringAsFixed(0)}%';

  Color get accuracyColor {
    if (overallAccuracy >= 70) {
      return const Color(0xFF10B981); // Green
    } else if (overallAccuracy >= 60) {
      return const Color(0xFF3B82F6); // Blue
    } else {
      return const Color(0xFFF59E0B); // Amber
    }
  }
}

class PredictionResult {
  final String id;
  final String game;
  final DateTime date;
  final List<int> predictedFr;
  final List<int> predictedSr;
  final int? actualFr;
  final int? actualSr;
  final bool isHit;
  final String predictionType; // 'FR', 'SR', or 'BOTH'

  PredictionResult({
    required this.id,
    required this.game,
    required this.date,
    required this.predictedFr,
    required this.predictedSr,
    this.actualFr,
    this.actualSr,
    required this.isHit,
    required this.predictionType,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      id: json['id'] ?? json['_id'] ?? '',
      game: json['game'] ?? '',
      date: DateTime.parse(json['date']),
      predictedFr: List<int>.from(json['predictedFr'] ?? []),
      predictedSr: List<int>.from(json['predictedSr'] ?? []),
      actualFr: json['actualFr'],
      actualSr: json['actualSr'],
      isHit: json['isHit'] ?? false,
      predictionType: json['predictionType'] ?? 'BOTH',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game': game,
      'date': date.toIso8601String(),
      'predictedFr': predictedFr,
      'predictedSr': predictedSr,
      'actualFr': actualFr,
      'actualSr': actualSr,
      'isHit': isHit,
      'predictionType': predictionType,
    };
  }

  String get displayName {
    final names = {
      'shillong': 'Shillong Teer',
      'khanapara': 'Khanapara Teer',
      'juwai': 'Juwai Teer',
      'shillong-morning': 'Shillong Morning',
      'juwai-morning': 'Juwai Morning',
      'khanapara-morning': 'Khanapara Morning',
    };
    return names[game] ?? game;
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class GameAccuracy {
  final String game;
  final double accuracy;
  final int totalPredictions;
  final int successfulPredictions;
  final double frAccuracy;
  final double srAccuracy;

  GameAccuracy({
    required this.game,
    required this.accuracy,
    required this.totalPredictions,
    required this.successfulPredictions,
    required this.frAccuracy,
    required this.srAccuracy,
  });

  factory GameAccuracy.fromJson(Map<String, dynamic> json) {
    return GameAccuracy(
      game: json['game'] ?? '',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      totalPredictions: json['totalPredictions'] ?? 0,
      successfulPredictions: json['successfulPredictions'] ?? 0,
      frAccuracy: (json['frAccuracy'] ?? 0).toDouble(),
      srAccuracy: (json['srAccuracy'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game': game,
      'accuracy': accuracy,
      'totalPredictions': totalPredictions,
      'successfulPredictions': successfulPredictions,
      'frAccuracy': frAccuracy,
      'srAccuracy': srAccuracy,
    };
  }

  String get displayName {
    final names = {
      'shillong': 'Shillong Teer',
      'khanapara': 'Khanapara Teer',
      'juwai': 'Juwai Teer',
      'shillong-morning': 'Shillong Morning',
      'juwai-morning': 'Juwai Morning',
      'khanapara-morning': 'Khanapara Morning',
    };
    return names[game] ?? game;
  }
}
