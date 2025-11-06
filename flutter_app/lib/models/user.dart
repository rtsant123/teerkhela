class User {
  final String userId;
  final String? email;
  final bool isPremium;
  final DateTime? expiryDate;
  final int daysLeft;
  final String? subscriptionId;

  User({
    required this.userId,
    this.email,
    this.isPremium = false,
    this.expiryDate,
    this.daysLeft = 0,
    this.subscriptionId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      email: json['email'],
      isPremium: json['isPremium'] ?? false,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      daysLeft: json['daysLeft'] ?? 0,
      subscriptionId: json['subscriptionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'isPremium': isPremium,
      'expiryDate': expiryDate?.toIso8601String(),
      'daysLeft': daysLeft,
      'subscriptionId': subscriptionId,
    };
  }

  bool get isExpiringSoon => isPremium && daysLeft <= 3;
}
