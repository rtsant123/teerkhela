# Quick Start: Test and Upload to Play Store

## YOUR CURRENT SITUATION
- Play Console account: ✅ Approved
- App code: ✅ Ready with Google Play Billing
- Want to: Test yourself, then upload to Play Store

## STEP-BY-STEP GUIDE

---

## PART 1: CREATE SUBSCRIPTION PRODUCTS (30 minutes)

### Go to Play Console
1. Open: https://play.google.com/console
2. Select **Teer Khela** app
3. Navigate to: **Monetize → Products → Subscriptions**

### Create 3 Subscriptions

#### Subscription 1: Monthly Premium

Click "Create subscription":
```
Product ID: premium_monthly ⚠️ EXACT (cannot change later)
Name: Monthly Premium
Description: Premium access with AI predictions and ad-free experience

Click "Add base plan":
- Base plan ID: monthly-base
- Billing period: 1 month
- Renewal type: Prepaid
- Auto-renewing: Yes

Set prices:
- Primary country: India
- Price: ₹99.00

Optional (recommended):
- Free trial: 7 days

Click "Activate"
```

#### Subscription 2: Quarterly Premium

Click "Create subscription":
```
Product ID: premium_quarterly ⚠️ EXACT
Name: Quarterly Premium
Description: 3 months of premium - Save 16% compared to monthly!

Click "Add base plan":
- Base plan ID: quarterly-base
- Billing period: 3 months
- Renewal type: Prepaid
- Auto-renewing: Yes

Set prices:
- Primary country: India
- Price: ₹249.00

Optional:
- Free trial: 7 days

Click "Activate"
```

#### Subscription 3: Annual Premium

Click "Create subscription":
```
Product ID: premium_annual ⚠️ EXACT
Name: Annual Premium
Description: 12 months of premium - Best value! Save 16%

Click "Add base plan":
- Base plan ID: annual-base
- Billing period: 12 months
- Renewal type: Prepaid
- Auto-renewing: Yes

Set prices:
- Primary country: India
- Price: ₹999.00

Optional:
- Free trial: 7 days

Click "Activate"
```

### Verify All 3 Products
Go to **Monetize → Products → Subscriptions** and confirm you see:
- ✅ premium_monthly (₹99) - Active
- ✅ premium_quarterly (₹249) - Active
- ✅ premium_annual (₹999) - Active

---

## PART 2: SET UP TEST ACCOUNT (5 minutes)

### Add Your Email for Testing

1. Go to: **Setup → License testing**
2. Add your Gmail account:
   ```
   your-email@gmail.com
   ```
3. Click "Save changes"

**Why?** This lets you test subscriptions without real charges!

### Important Notes:
- Test subscriptions are FREE
- They auto-renew every 5 minutes (not 1 month)
- Only works with signed release builds from Play Store
- Won't work with debug builds or sideloaded APKs

---

## PART 3: CREATE APP SIGNING KEY (15 minutes)

⚠️ **CRITICAL:** This key is required to publish on Play Store. If you lose it, you can NEVER update your app!

### Generate Keystore

Open Command Prompt and run:
```bash
keytool -genkey -v -keystore D:\Riogold\teerkhela-upload-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias teerkhela
```

You'll be asked for:
```
Enter keystore password: [Create a strong password]
Re-enter new password: [Same password]
What is your first and last name?: [Your name]
What is the name of your organizational unit?: [e.g., Development]
What is the name of your organization?: [Your company or name]
What is the name of your City or Locality?: [Your city]
What is the name of your State or Province?: [Your state]
What is the two-letter country code?: IN
Is this correct? yes

Enter key password for <teerkhela>: [Press Enter to use same password]
```

**SAVE THESE PASSWORDS SECURELY!**

Write them down here:
```
Keystore password: __________________
Key password: __________________
```

⚠️ Back up `D:\Riogold\teerkhela-upload-key.jks` to:
- Google Drive
- USB drive
- Email to yourself

---

## PART 4: CONFIGURE SIGNING

After you create the keystore, tell me the passwords and I'll configure the signing.

---

## PART 5: BUILD APP BUNDLE (10 minutes)

Once signing is configured, we'll build the AAB:

```bash
cd flutter_app
flutter clean
flutter pub get
flutter build appbundle --release
```

Output will be at:
```
flutter_app/build/app/outputs/bundle/release/app-release.aab
```

This AAB file is what you upload to Play Store!

---

## PART 6: UPLOAD TO INTERNAL TESTING (20 minutes)

### Create Internal Testing Release

1. Go to Play Console → **Testing → Internal testing**
2. Click "Create new release"
3. Upload `app-release.aab`
4. Release name: `1.0.0 - Google Play Billing`
5. Release notes (English):
   ```
   First release with Google Play Billing:
   - Premium subscriptions via Google Play
   - AI predictions for all 6 Teer games
   - Dream dictionary bot (100+ symbols)
   - Lucky VIP numbers
   - Formula calculator
   - Ad-free experience for premium users
   ```
6. Click "Save"
7. Click "Review release"
8. Click "Start rollout to Internal testing"

### Add Testers

1. Go to **Testing → Internal testing → Testers**
2. Create email list: `Internal Testers`
3. Add email addresses:
   ```
   your-test-email@gmail.com
   ```
4. Click "Save changes"
5. Copy the testing link (it looks like: `https://play.google.com/apps/internaltest/...`)

### Download and Test

1. Open the testing link on your Android phone
2. Click "Become a tester"
3. Click "Download it on Google Play"
4. Install the app
5. Open app and test:
   - ✅ Navigate to Subscribe screen
   - ✅ See all 3 subscription options (₹99, ₹249, ₹999)
   - ✅ Try to purchase (won't be charged - test account)
   - ✅ Verify premium features unlock
   - ✅ Test "Restore Purchases" button
   - ✅ Test all premium features
   - ✅ Check for crashes

---

## PART 7: UPLOAD TO PRODUCTION (30 minutes)

### Before Production Upload

Checklist:
- ✅ Tested in Internal Testing
- ✅ All 3 subscriptions working
- ✅ Premium features working
- ✅ No crashes
- ✅ Backend verification working
- ✅ Store listing complete
- ✅ Screenshots uploaded
- ✅ Privacy policy published

### Create Production Release

1. Go to Play Console → **Production**
2. Click "Create new release"
3. Upload SAME `app-release.aab` from internal testing
4. Release name: `1.0.0`
5. Release notes (all languages if needed):
   ```
   First release of Teer Khela app:

   FEATURES:
   ✅ Live Teer results for 6 games
   ✅ AI-powered predictions
   ✅ Dream dictionary bot
   ✅ Lucky VIP numbers
   ✅ Formula calculator
   ✅ Complete results history
   ✅ Multi-language support

   PREMIUM SUBSCRIPTION:
   - Monthly: ₹99
   - Quarterly: ₹249 (Save 16%)
   - Annual: ₹999 (Save 16%)

   Premium includes:
   - Unlimited AI predictions
   - Dream bot with 100+ symbols
   - Lucky VIP numbers
   - Formula calculator
   - Ad-free experience
   ```
6. Click "Save"
7. Click "Review release"
8. Choose rollout: **100%** (or start with 20% for cautious rollout)
9. Click "Start rollout to Production"

### Submit for Review

1. Review all sections in Play Console dashboard
2. Ensure all required fields are complete:
   - ✅ App content (Content rating)
   - ✅ Store listing
   - ✅ Privacy policy
   - ✅ Target audience
   - ✅ Data safety
   - ✅ Subscription products (3 active)
3. Click "Send for review"

### Review Timeline

- **First app review:** 3-7 days
- **Update reviews:** 1-3 days
- Check email for review status

---

## PART 8: AFTER APPROVAL

### Monitor Your App

Play Console → **Overview** dashboard shows:
- 📊 Installs
- 📊 Uninstalls
- 📊 Ratings
- 📊 Crashes
- 📊 ANRs (App Not Responding)
- 💰 Subscription revenue

### Subscription Management

**Monetize → Subscriptions** shows:
- Active subscribers
- New subscriptions
- Cancellations
- Revenue

Google pays you monthly via wire transfer.

### User Reviews

1. Respond to reviews (improves ratings!)
2. Fix bugs users report
3. Release updates regularly

---

## TESTING TIPS

### Test Subscription Flow

1. Open app on test account device
2. Go to Subscribe screen
3. Should see 3 options:
   ```
   Monthly Premium - ₹99
   Quarterly Premium - ₹249
   Annual Premium - ₹999
   ```
4. Click "Subscribe Now" on Monthly
5. Google Play payment sheet opens
6. Complete purchase (FREE for test account)
7. App shows "Premium subscription activated!"
8. Premium features unlock immediately
9. Check backend database for subscription entry

### Test Auto-Renewal

- Test subscriptions renew every 5 minutes
- Check if premium status persists after renewal
- Verify backend receives renewal webhook

### Test Cancellation

1. Open Play Store
2. Menu → Subscriptions
3. Find Teer Khela subscription
4. Click "Cancel subscription"
5. Verify app still shows premium until expiry
6. After expiry, premium features lock

### Test Restore Purchases

1. Uninstall app
2. Reinstall from Play Store
3. Open app
4. Click "Restore Purchases" in Subscribe screen
5. Premium status should restore

---

## COMMON ISSUES

### Products not showing in app

**Solution:**
- Wait 2-3 hours for Google cache update
- Verify all 3 products are "Active" in Play Console
- Clear Play Store cache: Settings → Apps → Play Store → Clear cache
- Reinstall app from Play Store

### "Item not available" error

**Solution:**
- Must download from Play Store (not sideload APK)
- Must be signed release build
- Test account must be in License testing list
- Products must be activated in Play Console

### Backend verification failing

**Solution:**
- Check Railway logs for errors
- Verify service account credentials uploaded
- Test with Play Console "Send test notification"
- Check database has correct schema

### Payment not completing

**Solution:**
- Verify test account added to License testing
- Check Google Play payment method is set up
- Try different payment method
- Check Play Console for error messages

---

## REVENUE CALCULATOR

### Monthly Revenue (1000 subscribers)

If you get:
- 400 monthly subscribers (₹99 × 400 = ₹39,600)
- 300 quarterly subscribers (₹249 × 300 / 3 = ₹24,900)
- 300 annual subscribers (₹999 × 300 / 12 = ₹24,975)

**Total monthly revenue:** ₹89,475
**After Google's 15% fee:** ₹76,054

**Annual revenue:** ₹9,12,650

---

## NEXT STEPS

### Today:
1. ✅ Create 3 subscription products in Play Console
2. ✅ Add your email to License testing
3. ✅ Generate keystore (save passwords!)
4. ✅ I'll configure signing

### Tomorrow:
5. ✅ Build AAB
6. ✅ Upload to Internal Testing
7. ✅ Test subscriptions yourself

### After Testing:
8. ✅ Update backend verification (if needed)
9. ✅ Complete store listing
10. ✅ Upload screenshots
11. ✅ Publish privacy policy
12. ✅ Submit to Production

**Timeline: 2-3 days to Internal Testing, 1 week to Production**

---

## IMPORTANT REMINDERS

1. ⚠️ **NEVER lose your keystore or passwords** - you can NEVER update your app!
2. ⚠️ Product IDs CANNOT be changed once created
3. ⚠️ Test accounts can make purchases for FREE
4. ⚠️ Real users will be charged via Google Play
5. ⚠️ Backend verification is REQUIRED (prevent fraud)
6. ⚠️ Always verify purchases on backend
7. ⚠️ Users manage subscriptions in Play Store (not in app)
8. ⚠️ Google pays you monthly (not instant)

---

## READY TO START?

Tell me when you've:
1. Created the 3 subscription products in Play Console
2. Added your test email
3. Generated the keystore

Then I'll:
- Configure signing
- Build the AAB
- Help you upload and test

**Let's get your app live on Play Store!** 🚀
