class ReferralStats {
  final String code;
  final int totalReferrals;
  final int unclaimedRewards;
  final int totalRewardsClaimed;

  ReferralStats({
    required this.code,
    required this.totalReferrals,
    required this.unclaimedRewards,
    required this.totalRewardsClaimed,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      code: json['code'] ?? '',
      totalReferrals: json['totalReferrals'] ?? 0,
      unclaimedRewards: json['unclaimedRewards'] ?? 0,
      totalRewardsClaimed: json['totalRewardsClaimed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'totalReferrals': totalReferrals,
      'unclaimedRewards': unclaimedRewards,
      'totalRewardsClaimed': totalRewardsClaimed,
    };
  }
}

class LeaderboardEntry {
  final String username;
  final int referrals;
  final int rank;

  LeaderboardEntry({
    required this.username,
    required this.referrals,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'] ?? 'Anonymous',
      referrals: json['referrals'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }

  String get rankEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}
