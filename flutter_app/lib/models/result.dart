class TeerResult {
  final String game;
  final DateTime date;
  final int? fr;
  final int? sr;
  final String? declaredTime;
  final bool isAuto;

  TeerResult({
    required this.game,
    required this.date,
    this.fr,
    this.sr,
    this.declaredTime,
    this.isAuto = true,
  });

  factory TeerResult.fromJson(Map<String, dynamic> json) {
    return TeerResult(
      game: json['game'] ?? '',
      date: DateTime.parse(json['date']),
      fr: json['fr'],
      sr: json['sr'],
      declaredTime: json['declaredTime'] ?? json['declared_time'],
      isAuto: json['isAuto'] ?? json['is_auto'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game': game,
      'date': date.toIso8601String(),
      'fr': fr,
      'sr': sr,
      'declaredTime': declaredTime,
      'isAuto': isAuto,
    };
  }

  bool get isComplete => fr != null && sr != null;

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
