class Prediction {
  final String game;
  final DateTime date;
  final List<int> fr;
  final List<int> sr;
  final String analysis;
  final int confidence;
  final DateTime postedAt;

  Prediction({
    required this.game,
    required this.date,
    required this.fr,
    required this.sr,
    required this.analysis,
    required this.confidence,
    required this.postedAt,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      game: json['game'] ?? '',
      date: DateTime.parse(json['date']),
      fr: List<int>.from(json['fr'] ?? []),
      sr: List<int>.from(json['sr'] ?? []),
      analysis: json['analysis'] ?? '',
      confidence: json['confidence'] ?? 0,
      postedAt: DateTime.parse(json['postedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game': game,
      'date': date.toIso8601String(),
      'fr': fr,
      'sr': sr,
      'analysis': analysis,
      'confidence': confidence,
      'postedAt': postedAt.toIso8601String(),
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

  String get confidenceLevel {
    if (confidence >= 90) return 'Very High';
    if (confidence >= 80) return 'High';
    if (confidence >= 70) return 'Good';
    if (confidence >= 60) return 'Moderate';
    return 'Low';
  }
}
