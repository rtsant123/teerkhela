class DreamInterpretation {
  final String originalLanguage;
  final String translatedDream;
  final List<String> symbols;
  final Map<String, String> symbolMeanings;
  final List<int> numbers;
  final String analysis;
  final int confidence;
  final bool basedOnPastResults;
  final List<int> recentHotNumbers;
  final String recommendation;

  DreamInterpretation({
    required this.originalLanguage,
    required this.translatedDream,
    required this.symbols,
    required this.symbolMeanings,
    required this.numbers,
    required this.analysis,
    required this.confidence,
    required this.basedOnPastResults,
    required this.recentHotNumbers,
    required this.recommendation,
  });

  factory DreamInterpretation.fromJson(Map<String, dynamic> json) {
    return DreamInterpretation(
      originalLanguage: json['originalLanguage'] ?? 'en',
      translatedDream: json['translatedDream'] ?? '',
      symbols: List<String>.from(json['symbols'] ?? []),
      symbolMeanings: Map<String, String>.from(json['symbolMeanings'] ?? {}),
      numbers: List<int>.from(json['numbers'] ?? []),
      analysis: json['analysis'] ?? '',
      confidence: json['confidence'] ?? 0,
      basedOnPastResults: json['basedOnPastResults'] ?? false,
      recentHotNumbers: List<int>.from(json['recentHotNumbers'] ?? []),
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalLanguage': originalLanguage,
      'translatedDream': translatedDream,
      'symbols': symbols,
      'symbolMeanings': symbolMeanings,
      'numbers': numbers,
      'analysis': analysis,
      'confidence': confidence,
      'basedOnPastResults': basedOnPastResults,
      'recentHotNumbers': recentHotNumbers,
      'recommendation': recommendation,
    };
  }

  String get confidenceLevel {
    if (confidence >= 90) return 'Very High';
    if (confidence >= 80) return 'High';
    if (confidence >= 70) return 'Good';
    if (confidence >= 60) return 'Moderate';
    return 'Low';
  }

  String get languageName {
    final languages = {
      'hi': 'Hindi',
      'bn': 'Bengali',
      'as': 'Assamese',
      'en': 'English',
      'ne': 'Nepali',
    };
    return languages[originalLanguage] ?? originalLanguage;
  }
}
