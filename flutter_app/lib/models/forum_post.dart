class ForumPost {
  final String id;
  final String userId;
  final String username;
  final String game;
  final String predictionType; // 'FR' or 'SR'
  final List<int> numbers;
  final int confidence; // 0-100
  final String description;
  final int likes;
  final List<String> likedBy;
  final DateTime createdAt;
  final bool isPremiumUser;

  ForumPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.game,
    required this.predictionType,
    required this.numbers,
    required this.confidence,
    required this.description,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
    this.isPremiumUser = false,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Anonymous',
      game: json['game'] ?? '',
      predictionType: json['predictionType'] ?? 'FR',
      numbers: json['numbers'] != null
          ? List<int>.from(json['numbers'])
          : [],
      confidence: json['confidence'] ?? 0,
      description: json['description'] ?? '',
      likes: json['likes'] ?? 0,
      likedBy: json['likedBy'] != null
          ? List<String>.from(json['likedBy'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isPremiumUser: json['isPremiumUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'game': game,
      'predictionType': predictionType,
      'numbers': numbers,
      'confidence': confidence,
      'description': description,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremiumUser': isPremiumUser,
    };
  }

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
