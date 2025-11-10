class User {
  final String userId;
  final String? email;
  final String? phoneNumber;
  final String? name;
  final bool isPremium;
  final DateTime? expiryDate;
  final int daysLeft;
  final String? subscriptionId;
  final bool isGuest;

  User({
    required this.userId,
    this.email,
    this.phoneNumber,
    this.name,
    this.isPremium = false,
    this.expiryDate,
    this.daysLeft = 0,
    this.subscriptionId,
    this.isGuest = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      isPremium: json['isPremium'] ?? false,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      daysLeft: json['daysLeft'] ?? 0,
      subscriptionId: json['subscriptionId'],
      isGuest: json['isGuest'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'name': name,
      'isPremium': isPremium,
      'expiryDate': expiryDate?.toIso8601String(),
      'daysLeft': daysLeft,
      'subscriptionId': subscriptionId,
      'isGuest': isGuest,
    };
  }

  bool get isExpiringSoon => isPremium && daysLeft <= 3;
  bool get isLoggedIn => !isGuest && phoneNumber != null;
}
