# 🎯 Teer Khela - Complete Deployment Checklist

## ✅ Pre-Deployment (All Done!)

### Backend Development
- [x] Express.js server setup
- [x] PostgreSQL database schema (12 tables)
- [x] 40+ API endpoints implemented
- [x] AI prediction algorithm (10 numbers)
- [x] Web scraping for 6 Teer games
- [x] Razorpay payment integration
- [x] Firebase Cloud Messaging setup
- [x] JWT authentication
- [x] 5 automated cron jobs
- [x] Referral program backend
- [x] Community forum backend
- [x] Accuracy tracking system
- [x] Error handling & logging

### Flutter App Development
- [x] 20 screens built
- [x] Material Design 3 theme
- [x] Dark mode implementation
- [x] State management (Provider)
- [x] API integration
- [x] Razorpay payment UI
- [x] Firebase notifications UI
- [x] Splash screen with animations
- [x] Onboarding tutorial (3 screens)
- [x] Shimmer loading states
- [x] Page transitions
- [x] Referral program UI
- [x] Community forum UI
- [x] Accuracy display widgets

### Documentation
- [x] Privacy Policy
- [x] Terms of Service
- [x] Contact Us page
- [x] About Us page
- [x] Refund Policy
- [x] API documentation
- [x] Railway deployment guide
- [x] Complete feature summary

### Production APK
- [x] All compilation errors fixed
- [x] Production APK built (27 MB)
- [x] APK location: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

---

## 🚀 Deployment Steps

### Step 1: Backend Deployment (Railway)
- [ ] Create Railway account
- [ ] Provision PostgreSQL database
- [ ] Set up environment variables
- [ ] Deploy backend code
- [ ] Verify health endpoint
- [ ] Check database tables created
- [ ] Test API endpoints
- [ ] Configure Razorpay webhook
- [ ] Verify cron jobs running
- [ ] Check logs for errors

**Guide:** See `RAILWAY_DEPLOYMENT_GUIDE.md`

### Step 2: Firebase Setup
- [ ] Create Firebase project
- [ ] Generate service account key
- [ ] Add `FIREBASE_CREDENTIALS` to Railway
- [ ] Download `google-services.json`
- [ ] Add to Flutter app: `android/app/google-services.json`
- [ ] Test push notifications

### Step 3: Razorpay Setup
- [ ] Create Razorpay account
- [ ] Generate API keys (Test mode first)
- [ ] Add keys to Railway environment
- [ ] Configure webhook URL
- [ ] Test payment flow
- [ ] Create subscription plans (₹49/₹99/month)
- [ ] Switch to Live mode for production

### Step 4: Update Flutter App with Production URLs
- [ ] Edit `lib/services/api_service.dart`
- [ ] Change `baseUrl` to Railway URL
- [ ] Update Razorpay key
- [ ] Add `google-services.json`
- [ ] Update version code/name

**Example:**
```dart
// Before
static const String baseUrl = 'http://localhost:3000/api';

// After
static const String baseUrl = 'https://your-project.up.railway.app/api';
```

### Step 5: Rebuild Production APK
```bash
cd flutter_app
flutter clean
flutter pub get
flutter build apk --release
```

- [ ] APK built successfully
- [ ] APK size checked (should be ~27 MB)
- [ ] APK located at: `build/app/outputs/flutter-apk/app-release.apk`

### Step 6: Test on Real Device
- [ ] Transfer APK to Android phone
- [ ] Install APK (enable "Unknown sources")
- [ ] Test app launch (splash → onboarding → home)
- [ ] Test live results loading
- [ ] Test predictions (requires subscription)
- [ ] Test Dream AI
- [ ] Test formula calculator
- [ ] Test referral code generation
- [ ] Test subscription payment (₹1 test)
- [ ] Test community forum
- [ ] Test dark mode toggle
- [ ] Check push notifications

---

## 📱 Google Play Store Submission

### Step 1: Create Google Play Developer Account
- [ ] Pay $25 one-time registration fee
- [ ] Complete developer profile
- [ ] Add payment method (for receiving money)

### Step 2: Prepare Store Listing
- [ ] App name: "Teer Khela - AI Predictions"
- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] 8+ screenshots (phone + tablet)
- [ ] Privacy Policy URL
- [ ] Terms of Service URL

### Step 3: App Content Rating
- [ ] Complete questionnaire
- [ ] Declare app category (Entertainment/Games)
- [ ] Age rating (18+ recommended for betting)

### Step 4: Pricing & Distribution
- [ ] Select free/paid (Free with in-app purchases)
- [ ] Select countries (India, Bangladesh, etc.)
- [ ] Content guidelines compliance

### Step 5: App Release
- [ ] Upload signed APK/AAB
- [ ] Complete all forms
- [ ] Submit for review
- [ ] Wait 1-3 days for approval

**Note:** Consider building AAB (Android App Bundle) instead of APK for Play Store:
```bash
flutter build appbundle --release
```

---

## 🔐 App Signing (Required for Play Store)

### Generate Upload Key
```bash
cd flutter_app/android

# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Follow prompts to set password and details
```

### Configure Gradle
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

Edit `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Build Signed APK
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

---

## 📊 Post-Launch Monitoring

### Analytics & Tracking
- [ ] Set up Firebase Analytics
- [ ] Track key events:
  - App installs
  - Subscription conversions
  - Prediction views
  - Referral clicks
  - Daily active users
- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Track API errors in Railway logs

### Performance Monitoring
- [ ] Railway logs (check for errors)
- [ ] Database size (upgrade if >90% full)
- [ ] API response times (<500ms)
- [ ] Cron job execution (daily check)
- [ ] Push notification delivery rate

### Business Metrics
- [ ] Daily active users (DAU)
- [ ] Subscription conversion rate
- [ ] Referral conversion rate
- [ ] Monthly recurring revenue (MRR)
- [ ] Customer lifetime value (LTV)
- [ ] Churn rate

---

## 🎉 Launch Checklist

### Day Before Launch
- [ ] Backend deployed and stable (24h uptime)
- [ ] Database backup configured
- [ ] All environment variables set
- [ ] Payment gateway in Live mode
- [ ] Test user accounts created
- [ ] Social media accounts created
- [ ] Marketing materials ready

### Launch Day
- [ ] Final APK tested on 3+ devices
- [ ] Google Play listing live
- [ ] Backend health check ✅
- [ ] Announce on social media
- [ ] Share referral program
- [ ] Monitor first 100 users

### Week 1 Post-Launch
- [ ] Respond to user feedback
- [ ] Fix critical bugs (if any)
- [ ] Monitor crash reports daily
- [ ] Track subscription conversions
- [ ] Adjust pricing if needed
- [ ] Run marketing campaigns

---

## 🛠️ Troubleshooting Common Issues

### APK Won't Install
**Fix:** Enable "Install from Unknown Sources" in Android settings

### API Not Loading
**Fix:** Check Railway deployment status, verify API URL in app

### Payment Failing
**Fix:** Ensure Razorpay is in Live mode, webhook configured correctly

### Notifications Not Working
**Fix:** Verify Firebase credentials, check FCM token generation

### Predictions Not Showing
**Fix:** Ensure user has active subscription, check API response

---

## 📞 Support Channels

### For Users
- Email: support@teerkhela.com (set up email)
- In-app chat (future feature)
- WhatsApp support (add number)

### For Developers
- Railway logs: `railway logs`
- Firebase Console: https://console.firebase.google.com
- Razorpay Dashboard: https://dashboard.razorpay.com
- Google Play Console: https://play.google.com/console

---

## 🎯 Success Metrics (First Month)

**Conservative Targets:**
- [ ] 500+ downloads
- [ ] 25+ paid subscribers
- [ ] ₹1,225+ MRR
- [ ] 5%+ conversion rate
- [ ] <1% crash rate
- [ ] 4.0+ star rating

**Stretch Targets:**
- [ ] 2,000+ downloads
- [ ] 100+ paid subscribers
- [ ] ₹5,000+ MRR
- [ ] 10%+ conversion rate
- [ ] <0.5% crash rate
- [ ] 4.5+ star rating

---

## 📈 Growth Roadmap

### Week 1-2: Stabilization
- Monitor and fix bugs
- Collect user feedback
- Improve AI accuracy

### Week 3-4: Viral Growth
- Launch referral program marketing
- Social media campaigns
- WhatsApp group promotion

### Month 2: Feature Expansion
- Add more Teer games
- Improve accuracy algorithm
- Add Pro tier features

### Month 3: Scaling
- Backend optimization
- Multi-region deployment
- Influencer partnerships

---

**Last Updated:** January 8, 2025
**Version:** 1.0.0
**Generated with Claude Code**
