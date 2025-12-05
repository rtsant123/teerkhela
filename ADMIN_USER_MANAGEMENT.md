# Admin App - Complete User Management Guide

## Overview
The admin app now has full user management capabilities including granting, extending, and revoking premium access.

## Features Added

### 1. **Grant Premium** ✅
**For Free Users**
- Click "Grant" button on any free user
- Enter number of days (default: 30)
- User receives premium access immediately
- User gets push notification: "🎉 Premium Activated!"

**How it works:**
- Backend: `POST /api/admin/user/:userId/grant-premium`
- Body: `{ "days": 30 }`
- Creates new premium user or converts free user to premium
- Sets expiry date based on days specified

### 2. **Extend Premium** ✅
**For Premium Users**
- Click "Extend" button on any premium user
- Enter number of days to add (default: 30)
- Adds days to existing expiry date
- User gets notification: "🎁 Premium Extended!"

**How it works:**
- Backend: `POST /api/admin/user/:userId/extend-premium`
- Body: `{ "days": 30 }`
- Adds specified days to current expiry date
- If already expired, extends from current date

### 3. **Revoke Premium** ✅
**For Premium Users**
- Click "Revoke" button (orange)
- Confirm action
- Immediately removes premium access
- Sets expiry date to now

**How it works:**
- Backend: `POST /api/admin/user/:userId/revoke-premium`
- No body required
- Sets `is_premium = false` and `expiry_date = now`

### 4. **Delete User** ✅
**For All Users**
- Click "Delete" button (red)
- Confirm action
- Permanently removes user from database
- Cannot be undone

**How it works:**
- Backend: `DELETE /api/admin/user/:userId`
- Removes user completely from database

## User Interface

### User Card Layout
Each user is shown in a card with:

**Top Section:**
- Premium/Free icon (green or gray)
- Phone number / User ID
- Status badge (PREMIUM in green or FREE in gray)
- Days left (for premium users)

**Middle Section (Action Buttons):**
- **Free Users**: `[Grant] [Delete]`
- **Premium Users**: `[Extend] [Revoke] [Delete]`

**Bottom Section (Details):**
- Expiry date (for premium users)
- Join date

### Button Colors
- **Grant** → Green (`Icons.workspace_premium`)
- **Extend** → Blue (`Icons.add_circle`)
- **Revoke** → Orange (`Icons.remove_circle`)
- **Delete** → Red (`Icons.delete_outline`)

## API Endpoints

### Grant Premium
```
POST /api/admin/user/:userId/grant-premium
Body: { "days": 30 }

Response:
{
  "success": true,
  "message": "Premium granted for 30 days",
  "data": {
    "id": "user123",
    "is_premium": true,
    "expiry_date": "2025-01-04T12:00:00Z",
    ...
  }
}
```

### Extend Premium
```
POST /api/admin/user/:userId/extend-premium
Body: { "days": 30 }

Response:
{
  "success": true,
  "message": "Premium extended by 30 days",
  "data": {
    "id": "user123",
    "is_premium": true,
    "expiry_date": "2025-02-03T12:00:00Z",
    ...
  }
}
```

### Revoke Premium
```
POST /api/admin/user/:userId/revoke-premium

Response:
{
  "success": true,
  "message": "Premium deactivated",
  "data": {
    "id": "user123",
    "is_premium": false,
    "expiry_date": "2025-12-05T12:00:00Z",
    ...
  }
}
```

### Delete User
```
DELETE /api/admin/user/:userId

Response:
{
  "success": true,
  "message": "User deleted successfully"
}
```

### Get All Users
```
GET /api/admin/users

Response:
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user123",
        "phone_number": "9876543210",
        "is_premium": true,
        "expiry_date": "2025-01-04T12:00:00Z",
        "created_at": "2025-11-01T10:00:00Z"
      },
      ...
    ],
    "total": 150,
    "premium_count": 45,
    "free_count": 105
  }
}
```

## Usage Examples

### Example 1: Give 7 Days Free Trial
1. Open Admin App
2. Navigate to "Manage Users"
3. Find the user
4. Click "Grant"
5. Enter "7" days
6. Click "Grant"
7. ✅ User gets 7 days premium

### Example 2: Extend Premium by 30 Days
1. Find premium user
2. Click "Extend"
3. Enter "30" days
4. Click "Extend"
5. ✅ 30 days added to expiry date

### Example 3: Revoke Premium Access
1. Find premium user
2. Click "Revoke"
3. Confirm action
4. ✅ Premium removed immediately

### Example 4: Test Promo Code
1. User enters promo code "TEST100"
2. Gets 100% discount
3. Premium activated for 30 days
4. Admin can see user in premium list
5. Admin can extend or revoke as needed

## User List Features

### Display Information
- **Total Users**: Shows count in header
- **Premium Count**: Number of premium users
- **Free Count**: Number of free users
- **Days Left**: For each premium user
- **Expiry Alerts**: Orange text if < 7 days left

### Refresh
- Pull down to refresh user list
- Auto-refreshes after any action

### Filtering (Future Enhancement)
- Filter by premium/free status
- Sort by expiry date
- Search by phone number
- View payment history

## Push Notifications

Users receive notifications when premium status changes:

### When Premium Granted
```
Title: 🎉 Premium Activated!
Message: You now have premium access for 30 days. Enjoy all features!
```

### When Premium Extended
```
Title: 🎁 Premium Extended!
Message: Your premium subscription has been extended by 30 days. Enjoy!
```

*Note: Revoke and Delete do not send notifications*

## Backend Implementation

### Files Modified
1. **backend/src/routes/admin.js**
   - Added `grant-premium`, `extend-premium`, `revoke-premium` routes
   - Moved to non-auth section for simple admin app

2. **backend/src/controllers/adminController.js**
   - Added `grantPremium` function
   - Updated exports

3. **admin_app/lib/screens/manage_users_screen.dart**
   - Added `_grantPremium()` method
   - Added `_extendPremium()` method
   - Added `_revokePremium()` method
   - Updated UI with action buttons

## Testing Workflow

### Test 1: Grant Premium to New User
1. Create new user in user app
2. Open admin app
3. Refresh user list
4. Find new user (shows as FREE)
5. Click "Grant"
6. Enter "30" days
7. ✅ Verify user shows as PREMIUM with 30 days left

### Test 2: Extend Existing Premium
1. Find premium user with < 30 days left
2. Note current expiry date
3. Click "Extend"
4. Enter "30" days
5. ✅ Verify days left increased by 30

### Test 3: Revoke Premium
1. Find premium user
2. Click "Revoke"
3. Confirm
4. ✅ Verify user shows as FREE

### Test 4: Delete User
1. Find any user
2. Click "Delete"
3. Confirm
4. ✅ Verify user removed from list

## Integration with Promo Codes

The user management system works seamlessly with promo codes:

### Scenario: User Uses 100% Promo Code
1. User enters "TEST100" in user app
2. Premium activated for 30 days automatically
3. Admin sees user as PREMIUM in admin app
4. Admin can:
   - Extend premium (add more days)
   - Revoke premium (remove access)
   - Delete user

### Scenario: User Uses 50% Promo Code
1. User enters "SAVE50" and pays ₹50
2. Premium activated after payment
3. Shows up in admin app as PREMIUM
4. Admin has full control

## Security Notes

**Current Setup:**
- ⚠️ No authentication required (for simple admin app)
- Admin endpoints are public: `/api/admin/*`
- Suitable for internal use only

**Production Recommendations:**
1. Add authentication to admin endpoints
2. Use JWT tokens for admin access
3. Add admin user roles (super admin, support, etc.)
4. Add audit logs for all user changes
5. Add rate limiting

## Troubleshooting

### Users not showing up
- Check backend is running
- Verify API endpoint: `https://teerkhela-production.up.railway.app/api/admin/users`
- Check network connection
- Pull to refresh

### Grant/Extend not working
- Verify backend deployed with latest changes
- Check Railway logs for errors
- Ensure database is accessible
- Verify user ID is correct

### Notifications not sent
- Check Firebase configuration
- Verify user has FCM token
- Check backend logs
- User must have opened app at least once

## Future Enhancements

### Planned Features
1. **Bulk Operations**
   - Grant premium to multiple users
   - Revoke multiple users
   - Export user list to CSV

2. **User Details View**
   - Payment history
   - Login history
   - Device information
   - Activity logs

3. **Analytics Dashboard**
   - Premium conversion rate
   - Revenue metrics
   - User retention
   - Popular promo codes

4. **Advanced Filters**
   - Filter by expiry date range
   - Filter by join date
   - Search by phone/email
   - Sort by various fields

5. **Communication**
   - Send custom notifications
   - Email users
   - SMS alerts

## Files Reference

### Backend
- `backend/src/routes/admin.js` - Routes
- `backend/src/controllers/adminController.js` - Logic
- `backend/src/models/User.js` - Database model

### Admin App
- `admin_app/lib/screens/manage_users_screen.dart` - Main UI
- `admin_app/lib/screens/admin_home_screen.dart` - Navigation

## Quick Reference

| Action | Button | Days Input | Result |
|--------|--------|------------|--------|
| Grant Premium | Green "Grant" | Yes | Free → Premium |
| Extend Premium | Blue "Extend" | Yes | Add days to expiry |
| Revoke Premium | Orange "Revoke" | No | Premium → Free |
| Delete User | Red "Delete" | No | Remove user |

---

**Status**: ✅ Fully Implemented & Working
**Last Updated**: 2025-12-05
**Version**: 1.0.0

**Quick Test**:
1. Deploy backend to Railway
2. Install admin APK
3. Open "Manage Users"
4. Grant premium to test user
5. Verify in user app
