# Migration from Razorpay to Google Play Billing

## WHY THE CHANGE?

Google Play Store **REQUIRES** apps to use Google Play Billing for:
- In-app purchases
- Subscriptions
- Digital content

Using external payment systems (like Razorpay) for these will cause:
- ❌ App rejection
- ❌ Account suspension
- ❌ Policy violation

## GOOGLE PLAY BILLING BENEFITS:

1. **User Trust** - Users trust Google's payment system
2. **Automatic Management** - Google handles subscriptions, renewals, cancellations
3. **Multi-currency** - Supports 135+ countries and currencies
4. **Family Sharing** - Premium can be shared with family members
5. **Subscription Recovery** - Google helps recover failed payments
6. **No Fraud Risk** - Google handles all payment fraud

## GOOGLE'S COMMISSION:

- **First $1M per year:** 15% commission
- **After $1M:** 30% commission
- For subscriptions after 1 year: 15% commission (loyalty discount)

Example: ₹99 subscription = You get ₹84.15 (Google takes ₹14.85)

## IMPLEMENTATION STEPS:

### 1. PLAY CONSOLE SETUP (DO THIS FIRST!)

#### A. Create Subscription Products
1. Go to Play Console → Your App
2. Navigate to: **Monetize → Products → Subscriptions**
3. Click "Create subscription"

**Create 3 subscriptions:**

**Monthly Premium:**
- Product ID: `premium_monthly`
- Name: Monthly Premium
- Description: Premium access with AI predictions
- Price: ₹99 (auto-converts to other currencies)
- Billing period: 1 month
- Free trial: 7 days (optional)

**Quarterly Premium:**
- Product ID: `premium_quarterly`
- Name: Quarterly Premium
- Description: 3 months of premium access - Save 16%
- Price: ₹249
- Billing period: 3 months
- Free trial: 7 days (optional)

**Annual Premium:**
- Product ID: `premium_annual`
- Name: Annual Premium
- Description: 12 months of premium access - Best value!
- Price: ₹999
- Billing period: 12 months
- Free trial: 7 days (optional)

#### B. Set Up Base Plan
For each subscription:
1. Click "Add base plan"
2. Choose "Prepaid" (user pays upfront)
3. Set renewal type: "Auto-renewing"
4. Add price for India: Set your price
5. Click "Activate"

### 2. APP INTEGRATION (I'LL DO THIS)

Remove: `razorpay_flutter`
Add: `in_app_purchase`

New flow:
1. User clicks "Subscribe Now"
2. App queries available products from Google Play
3. Shows subscription options
4. User selects a plan
5. Google Play payment sheet opens
6. User completes payment via Google
7. App receives purchase token
8. Backend verifies with Google
9. Premium activated

### 3. BACKEND CHANGES NEEDED

Your Railway backend needs new endpoints:

**New endpoint: `/api/subscriptions/verify-google`**
```javascript
// Verify Google Play purchase
POST /api/subscriptions/verify-google
{
  "purchaseToken": "string",
  "productId": "premium_monthly",
  "userId": "uuid"
}
```

Backend must:
1. Call Google Play Developer API
2. Verify purchase token is valid
3. Check subscription is active
4. Save to database
5. Return premium status

**Google Play Developer API:**
- Endpoint: `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{packageName}/purchases/subscriptionsv2/tokens/{token}`
- Requires: Service account credentials from Play Console

### 4. TESTING

Google Play Billing has special test accounts:

**Test Subscriptions (No real charge):**
1. Play Console → Settings → License testing
2. Add your test email addresses
3. These accounts can make test purchases for free
4. Subscriptions auto-renew every 5 minutes (for testing)

**Test Flow:**
1. Build signed APK/AAB
2. Upload to Internal Testing track
3. Add test users
4. Download app from Play Store
5. Test subscription purchase
6. Verify premium features unlock
7. Test subscription cancellation
8. Test subscription renewal

### 5. IMPORTANT CHANGES

**Subscription Management:**
- Users manage subscriptions in Play Store (not in your app)
- You can show "Manage Subscription" button that opens Play Store
- Google handles cancellations, refunds, pauses

**Webhook for Real-time Updates:**
Play Console → Monetization → Real-time developer notifications
- Set webhook URL: `https://teerkhela-production.up.railway.app/api/webhooks/google-play`
- Google sends notifications for:
  - New subscription
  - Subscription renewed
  - Subscription cancelled
  - Subscription expired
  - Payment failed

**Grace Period:**
- If payment fails, Google gives 3-7 days grace period
- Your app should allow access during grace period
- Google will retry payment automatically

### 6. MIGRATION IMPACT

**What Users See:**
- Better payment experience (Google's UI)
- More payment methods (cards, UPI, net banking, Google Pay)
- Subscription management in Play Store
- Automatic receipts via email

**What You Lose:**
- Direct payment control
- 15-30% commission to Google
- Custom payment UI

**What You Gain:**
- Play Store compliance ✅
- User trust ✅
- Global reach ✅
- Automatic subscription management ✅
- Fraud protection ✅
- Failed payment recovery ✅

## TIMELINE:

1. **Today:** Remove Razorpay, add Play Billing (2-3 hours)
2. **Today:** Create subscriptions in Play Console (30 mins)
3. **Tomorrow:** Update backend verification (3-4 hours)
4. **Tomorrow:** Test internal release (1-2 hours)
5. **After Testing:** Upload to production

Total: 1-2 days for complete migration

## FILES THAT WILL CHANGE:

1. `pubspec.yaml` - Add in_app_purchase package
2. `subscribe_screen_full.dart` - Complete rewrite
3. `razorpay_service.dart` - DELETE
4. Backend: New endpoint for Google verification
5. Backend: Webhook handler for subscription events

## NEXT STEPS:

1. ✅ Confirm you want to proceed with migration
2. ✅ I'll remove Razorpay and add Google Play Billing
3. ✅ You create subscription products in Play Console
4. ✅ I'll update the app to use new system
5. ✅ You test the flow
6. ✅ Upload to Play Store

**Ready to start? This is the right decision for Play Store compliance!**
