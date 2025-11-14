# Google Play Store Preparation Guide

## CURRENT STATUS
- App Name: **Teer Khela**
- Package: `com.teerkhela.app`
- Version: 1.0.0+1

## STEP 1: CREATE APP SIGNING KEY (REQUIRED)

Run this command to create your signing key:

```bash
keytool -genkey -v -keystore D:\Riogold\flutter_app\android\app\teerkhela-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias teerkhela
```

**IMPORTANT:** You'll be asked for:
1. Keystore password - **SAVE THIS PASSWORD SECURELY**
2. Key password - **SAVE THIS PASSWORD SECURELY**
3. Your name
4. Organizational unit
5. Organization name
6. City
7. State
8. Country code

**WARNING:** If you lose these passwords, you can NEVER update your app again!

## STEP 2: CONFIGURE SIGNING (I'LL DO THIS FOR YOU)

Create `android/key.properties` file with your keystore details.

## STEP 3: BUILD APP BUNDLE FOR PLAY STORE

After signing is configured, run:
```bash
cd flutter_app
flutter build appbundle --release
```

Output: `flutter_app/build/app/outputs/bundle/release/app-release.aab`

## STEP 4: GOOGLE PLAY CONSOLE SETUP

### 4.1 Create Play Console Account
- Go to: https://play.google.com/console
- Pay one-time $25 registration fee
- Verify your identity

### 4.2 Create New App
1. Click "Create app"
2. Fill in:
   - App name: **Teer Khela**
   - Default language: English
   - App or game: App
   - Free or paid: Free (with in-app purchases)
3. Accept declarations

### 4.3 Store Listing (Content Required)

#### App Details:
- **Short description** (80 chars max):
  ```
  AI-powered Teer predictions, live results, dream analysis & premium features
  ```

- **Full description** (4000 chars max):
  ```
  Teer Khela - Your Ultimate Teer Prediction App

  Get accurate AI-powered predictions for all major Teer games including Shillong, Khanapara, Juwai, and more. Our advanced prediction engine analyzes historical data to provide you with the best possible numbers.

  KEY FEATURES:
  ✅ Live Teer Results - Get instant notifications for all game results
  ✅ AI Predictions - Advanced machine learning predictions for FR & SR
  ✅ Dream Dictionary - Interpret your dreams into Teer numbers (100+ symbols)
  ✅ Lucky VIP Numbers - Personalized lucky numbers daily
  ✅ Common Numbers - Today's most probable winning numbers
  ✅ Formula Calculator - Calculate target numbers with custom formulas
  ✅ Hit Numbers Analysis - Track your winning numbers
  ✅ Complete History - Access historical results and patterns
  ✅ Multi-language Support - English, Hindi, Bengali, Assamese

  PREMIUM FEATURES:
  🌟 Unlimited AI Predictions for all 6 games
  🌟 Advanced Dream Dictionary Bot
  🌟 Exclusive Lucky VIP Numbers
  🌟 Top 7 Common Numbers Daily
  🌟 Formula Calculator & Analysis Tools
  🌟 Ad-Free Experience
  🌟 Priority Support

  SUBSCRIPTION PLANS:
  - Monthly: ₹49
  - Quarterly: ₹129 (Save 12%)
  - Yearly: ₹499 (Save 15%)

  Stay ahead of the game with real-time updates and expert predictions!
  ```

#### Graphics Required:
1. **App icon** - 512x512px (already done)
2. **Feature graphic** - 1024x500px (NEEDED)
3. **Phone screenshots** - 2-8 images, min 320px (NEEDED)
4. **7-inch tablet screenshots** - Optional
5. **10-inch tablet screenshots** - Optional

### 4.4 Content Rating
Complete the questionnaire:
- Select "Utility, Productivity, Communication, or Other"
- Answer questions about violence, sexuality, etc.
- Your app should get "Everyone" or "Teen" rating

### 4.5 Target Audience
- Age range: 18+ (gambling-related content)
- Target countries: India primarily

### 4.6 Privacy Policy
**REQUIRED!** Your privacy policy URL: https://your-website.com/privacy-policy

You need to create a privacy policy page covering:
- What data you collect (device ID, phone, email)
- How you use it (payments, notifications)
- Third-party services (Razorpay, Firebase)
- User rights (data deletion, access)

### 4.7 App Category
- Category: **Entertainment** or **Lifestyle**
- Tags: Teer, Predictions, Gaming, Entertainment

### 4.8 Contact Details
- Email: Your developer email
- Phone: Optional
- Website: Optional

### 4.9 Data Safety
Declare data collection:
- ✅ Collects: User credentials, Payment info, Device ID
- ✅ Shares: With Razorpay for payments
- ✅ Encryption: Data encrypted in transit
- ✅ Data deletion: Users can request deletion

## STEP 5: PRODUCTION TRACK

### Internal Testing (Optional but Recommended)
1. Upload AAB to Internal testing
2. Add testers (max 100)
3. Test for 1-2 weeks

### Production Release
1. Upload app-release.aab
2. Set release name: "1.0.0"
3. Add release notes
4. Choose rollout percentage: Start with 20%, then 50%, then 100%

## STEP 6: REVIEW & PUBLISH

### Before Submit Checklist:
- ✅ Tested on multiple devices
- ✅ No crashes or bugs
- ✅ Payment flow works
- ✅ Notifications work
- ✅ All features accessible
- ✅ Privacy policy published
- ✅ Screenshots uploaded
- ✅ Content rating completed
- ✅ Store listing complete

### Review Time
- First review: 3-7 days
- Updates: 1-3 days

## STEP 7: POST-PUBLISH

### Monitor:
1. Crashes & ANRs in Play Console
2. User reviews and ratings
3. Installation metrics
4. Revenue (subscription data)

### Optimize:
1. A/B test store listing
2. Respond to reviews
3. Release updates regularly
4. Add new features based on feedback

## IMPORTANT NOTES:

### ⚠️ Gambling Policy
Teer is legal in certain Indian states. Make sure:
- Your app complies with local laws
- You're targeting appropriate regions
- You're not accepting bets/wagers
- You're only providing information/predictions

### 🔒 Security
- Never share your keystore file
- Never commit keystore to git
- Back up keystore securely (Google Drive, USB)
- Store passwords in password manager

### 💰 Payments
- Razorpay integration is production-ready
- Test subscriptions in internal testing
- Monitor payment success rates
- Handle subscription cancellations

## HELPFUL LINKS:
- Play Console: https://play.google.com/console
- Play Store Guidelines: https://play.google.com/about/developer-content-policy/
- App Signing: https://developer.android.com/studio/publish/app-signing
- Flutter Deployment: https://docs.flutter.dev/deployment/android

## NEED HELP?
If you encounter issues during submission:
1. Check Play Console policy center
2. Review rejection reasons carefully
3. Make necessary changes
4. Resubmit

---

**Ready to proceed? Let's create your keystore and build the App Bundle!**
