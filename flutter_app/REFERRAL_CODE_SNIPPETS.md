# Referral Program - Code Snippets

## Quick Reference for Key Code Sections

### 1. API Service Methods (lib/services/api_service.dart)

```dart
// Get referral stats for a user
static Future<Map<String, dynamic>> getReferralStats(String userId) async {
  final response = await _get('/referral/$userId/code');
  if (response['success']) {
    return response['data'];
  } else {
    throw Exception('Failed to get referral stats');
  }
}

// Apply a referral code
static Future<bool> applyReferralCode(String userId, String code) async {
  final response = await _post('/referral/$userId/apply', {'code': code});
  if (response['success']) {
    return true;
  } else {
    throw Exception(response['message'] ?? 'Failed to apply referral code');
  }
}

// Claim referral rewards
static Future<Map<String, dynamic>> claimReferralRewards(String userId) async {
  final response = await _post('/referral/$userId/claim', {});
  if (response['success']) {
    return response['data'];
  } else {
    throw Exception('Failed to claim referral rewards');
  }
}

// Get referral leaderboard
static Future<List> getReferralLeaderboard() async {
  final response = await _get('/referral/leaderboard');
  if (response['success']) {
    return response['data'] as List;
  } else {
    throw Exception('Failed to get referral leaderboard');
  }
}
```

### 2. Referral Stats Model (lib/models/referral_stats.dart)

```dart
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
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '#$rank';
    }
  }
}
```

### 3. Profile Screen Integration Points

#### Imports Required:
```dart
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/referral_stats.dart';
```

#### State Variables:
```dart
ReferralStats? _referralStats;
List<LeaderboardEntry> _leaderboard = [];
bool _isLoadingReferral = false;
bool _isClaimingRewards = false;
```

#### Load Referral Data:
```dart
Future<void> _loadReferralData() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.user?.userId;

  if (userId == null) return;

  setState(() => _isLoadingReferral = true);

  try {
    // Load stats and leaderboard in parallel
    final results = await Future.wait([
      ApiService.getReferralStats(userId),
      ApiService.getReferralLeaderboard(),
    ]);

    setState(() {
      _referralStats = ReferralStats.fromJson(results[0]);
      _leaderboard = (results[1] as List)
          .map((json) => LeaderboardEntry.fromJson(json))
          .toList();
      _isLoadingReferral = false;
    });
  } catch (e) {
    setState(() => _isLoadingReferral = false);
    // Show error snackbar
  }
}
```

#### Copy Code:
```dart
Future<void> _copyReferralCode() async {
  if (_referralStats == null) return;

  await Clipboard.setData(ClipboardData(text: _referralStats!.code));

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Referral code copied to clipboard!'),
      backgroundColor: AppTheme.success,
    ),
  );
}
```

#### Share Code (WhatsApp + Fallback):
```dart
Future<void> _shareReferralCode() async {
  if (_referralStats == null) return;

  final code = _referralStats!.code;
  final message = 'Join Teer Khela using my code $code and get 5 days premium free! Download: https://play.google.com/store/apps/details?id=com.teerkhela.app';

  // Try WhatsApp first
  final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');

  try {
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      await Share.share(message, subject: 'Join Teer Khela');
    }
  } catch (e) {
    await Share.share(message, subject: 'Join Teer Khela');
  }
}
```

#### Claim Rewards:
```dart
Future<void> _claimRewards() async {
  if (_referralStats == null || _referralStats!.unclaimedRewards == 0) return;

  final userId = Provider.of<UserProvider>(context, listen: false).user?.userId;
  if (userId == null) return;

  setState(() => _isClaimingRewards = true);

  try {
    final result = await ApiService.claimReferralRewards(userId);

    setState(() => _isClaimingRewards = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully claimed ${result['daysAdded']} days of premium!'),
        backgroundColor: AppTheme.success,
      ),
    );

    // Reload data
    _loadReferralData();
    await Provider.of<UserProvider>(context, listen: false).loadUserStatus();
  } catch (e) {
    setState(() => _isClaimingRewards = false);
    // Show error
  }
}
```

#### In Build Method (after premium card):
```dart
SizedBox(height: AppTheme.space16),

// Referral Program Card
_buildReferralCard(size),

SizedBox(height: AppTheme.space16),

// Leaderboard Section
if (_leaderboard.isNotEmpty) _buildLeaderboard(size),
if (_leaderboard.isNotEmpty) SizedBox(height: AppTheme.space16),
```

### 4. Referral Card UI

```dart
Widget _buildReferralCard(Size size) {
  if (_isLoadingReferral) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: AppTheme.cardDecoration,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  if (_referralStats == null) return const SizedBox.shrink();

  final hasRewards = _referralStats!.unclaimedRewards > 0;

  return Container(
    padding: EdgeInsets.all(size.width * 0.05),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF9333EA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      boxShadow: AppTheme.elevatedShadow,
    ),
    child: Column(
      children: [
        // Header
        // Referral Code Display
        // Stats Row (Referrals | Rewards)
        // Action Buttons (Share | Claim)
      ],
    ),
  );
}
```

### 5. Leaderboard UI

```dart
Widget _buildLeaderboard(Size size) {
  return Container(
    decoration: AppTheme.cardDecoration,
    child: Column(
      children: [
        // Header with trophy icon
        Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: AppTheme.premiumGold),
              const SizedBox(width: 8),
              Text('Referral Leaderboard', style: AppTheme.heading3),
            ],
          ),
        ),
        const Divider(height: 1),

        // List of top 10
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _leaderboard.length > 10 ? 10 : _leaderboard.length,
          itemBuilder: (context, index) {
            final entry = _leaderboard[index];
            final isTopThree = entry.rank <= 3;

            return Container(
              // Rank emoji + Username + Referral count
              // Gold highlighting for top 3
            );
          },
        ),
      ],
    ),
  );
}
```

### 6. pubspec.yaml Addition

```yaml
dependencies:
  # ... existing dependencies ...
  share_plus: ^7.2.1
```

## Usage Examples

### To fetch and display referral stats:
```dart
// In initState or any async method
_loadReferralData();
```

### To check if user has rewards:
```dart
final hasRewards = _referralStats?.unclaimedRewards ?? 0 > 0;
```

### To enable/disable claim button:
```dart
ElevatedButton(
  onPressed: hasRewards && !_isClaimingRewards ? _claimRewards : null,
  child: Text('Claim Rewards'),
)
```

### To show loading state:
```dart
if (_isLoadingReferral) {
  return CircularProgressIndicator();
}
```

## API Response Examples

### GET /referral/:userId/code
```json
{
  "success": true,
  "data": {
    "code": "ABCD1234",
    "totalReferrals": 5,
    "unclaimedRewards": 10,
    "totalRewardsClaimed": 25
  }
}
```

### POST /referral/:userId/claim
```json
{
  "success": true,
  "data": {
    "daysAdded": 10,
    "newExpiryDate": "2025-12-31T00:00:00Z"
  }
}
```

### GET /referral/leaderboard
```json
{
  "success": true,
  "data": [
    {"rank": 1, "username": "John Doe", "referrals": 150},
    {"rank": 2, "username": "Jane Smith", "referrals": 120},
    {"rank": 3, "username": "Bob Wilson", "referrals": 95}
  ]
}
```

## Error Handling Pattern

```dart
try {
  final result = await ApiService.someMethod();
  // Process result
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Testing Commands

```bash
# Install dependencies
flutter pub get

# Analyze code
flutter analyze

# Run app
flutter run

# Build APK
flutter build apk
```
