# Referral Program Implementation

## Overview
Complete referral program UI implementation for the Flutter app with WhatsApp/SMS sharing integration, leaderboard, and rewards system.

## Files Modified/Created

### 1. API Service (`lib/services/api_service.dart`)
Added 4 new API methods for referral functionality:

```dart
// Get referral stats for a user
static Future<Map<String, dynamic>> getReferralStats(String userId)

// Apply a referral code
static Future<bool> applyReferralCode(String userId, String code)

// Claim referral rewards
static Future<Map<String, dynamic>> claimReferralRewards(String userId)

// Get referral leaderboard (top 10)
static Future<List> getReferralLeaderboard()
```

**API Endpoints:**
- `GET /referral/:userId/code` - Get referral stats
- `POST /referral/:userId/apply` - Apply referral code
- `POST /referral/:userId/claim` - Claim rewards
- `GET /referral/leaderboard` - Get top 10 referrers

**Base URL:** `https://teerkhela-production.up.railway.app/api/referral`

### 2. Referral Models (`lib/models/referral_stats.dart`)
Created two new model classes:

#### ReferralStats
```dart
class ReferralStats {
  final String code;
  final int totalReferrals;
  final int unclaimedRewards;
  final int totalRewardsClaimed;
}
```

#### LeaderboardEntry
```dart
class LeaderboardEntry {
  final String username;
  final int referrals;
  final int rank;

  String get rankEmoji // Returns 🥇🥈🥉 or #N
}
```

### 3. Profile Screen (`lib/screens/profile_screen_full.dart`)
Major updates to display referral program:

#### New State Variables:
- `ReferralStats? _referralStats` - User's referral statistics
- `List<LeaderboardEntry> _leaderboard` - Top 10 referrers
- `bool _isLoadingReferral` - Loading state
- `bool _isClaimingRewards` - Claiming state

#### New Methods:

**Data Loading:**
- `_loadReferralData()` - Fetches stats and leaderboard in parallel
- Auto-loads on screen init

**User Actions:**
- `_copyReferralCode()` - Copies code to clipboard with confirmation snackbar
- `_shareReferralCode()` - Opens WhatsApp with referral message, fallback to share dialog
- `_claimRewards()` - Claims unclaimed rewards and refreshes user status

**UI Components:**
- `_buildReferralCard(Size size)` - Premium gradient card with code, stats, and actions
- `_buildLeaderboard(Size size)` - Leaderboard with rank badges and highlighting

### 4. User Provider (`lib/providers/user_provider.dart`)
Added compatibility method:
```dart
Future<void> loadUserStatus() // Alias for refreshUserStatus
```

### 5. Dependencies (`pubspec.yaml`)
Added new package:
```yaml
share_plus: ^7.2.1
```

## UI Features

### Referral Card Design
- **Premium Gradient Background:** Purple-to-indigo gradient with elevation shadow
- **Large Referral Code:** 8% screen width, bold, with copy button
- **Stats Display:**
  - Total Referrals count
  - Unclaimed Rewards with 🎁 emoji when available
  - Amber highlight for unclaimed rewards
- **Action Buttons:**
  - **Share Code:** Premium gradient button, opens WhatsApp/share dialog
  - **Claim Rewards:** Amber button (disabled when no rewards), shows loading spinner

### Share Message Template
```
Join Teer Khela using my code {CODE} and get 5 days premium free!
Download: https://play.google.com/store/apps/details?id=com.teerkhela.app
```

### Leaderboard Features
- Displays top 10 referrers
- Rank badges: 🥇🥈🥉 for top 3, #N for others
- Gold highlighting for top 3 positions
- Shows username and referral count
- Star icon for top 3

## User Flow

1. **Profile Screen Load:**
   - Automatically fetches referral stats and leaderboard
   - Shows loading spinner during fetch

2. **Copy Code:**
   - User taps copy icon
   - Code copied to clipboard
   - Success snackbar confirmation

3. **Share Code:**
   - User taps "Share Code" button
   - Attempts to open WhatsApp with pre-filled message
   - Falls back to native share dialog if WhatsApp unavailable

4. **Claim Rewards:**
   - Button enabled only when unclaimed rewards > 0
   - Shows loading spinner during claim
   - Success snackbar shows days added
   - Refreshes both referral data and user premium status
   - Updates UI automatically

## Integration Points

### API Integration
All API calls use the existing `ApiService` helper methods:
- `_get(endpoint)` for GET requests
- `_post(endpoint, body)` for POST requests
- Automatic error handling with exceptions

### State Management
Uses Provider pattern:
- `UserProvider` for user data and premium status
- Local state for referral-specific data
- `notifyListeners()` for UI updates

### Theme Integration
Uses existing `AppTheme` constants:
- `premiumGradient` for share button
- `cardDecoration` for leaderboard
- `elevatedShadow` for referral card
- `success`, `error` colors for snackbars
- Responsive sizing with `size.width * factor`

## Error Handling

- Network errors show red snackbar with error message
- Failed API calls throw exceptions with user-friendly messages
- Loading states prevent duplicate actions
- Null safety checks for user data

## Responsive Design

All dimensions are responsive using screen width:
- Font sizes: `size.width * 0.03` to `0.08`
- Padding: `size.width * 0.03` to `0.05`
- Icon sizes: `size.width * 0.04` to `0.12`

## Testing Checklist

- [ ] Referral stats load correctly
- [ ] Copy code functionality works
- [ ] WhatsApp share opens with correct message
- [ ] Share dialog fallback works
- [ ] Claim rewards button enabled/disabled correctly
- [ ] Claiming rewards updates premium status
- [ ] Leaderboard displays top 10
- [ ] Top 3 highlighted correctly
- [ ] Loading states show properly
- [ ] Error messages display for failed API calls

## Future Enhancements

Potential improvements:
- Confetti animation on reward claim
- Pull-to-refresh for leaderboard
- Apply referral code dialog for new users
- Push notifications for new referrals
- Referral history/timeline view
- Social sharing options (Facebook, Twitter, etc.)
