# 🔐 Credentials Checklist - Fill This Out Before Deployment

Copy this template and fill in your actual values. **Keep this file secure and never commit it to Git!**

---

## ✅ RAILWAY (Backend Hosting)

- [ ] **Railway Account:** https://railway.app
- [ ] **Project Created:** Yes/No
- [ ] **PostgreSQL Added:** Yes/No
- [ ] **Backend URL:** `_______________________________`

---

## 💳 RAZORPAY (Payment Processing)

**Sign up:** https://dashboard.razorpay.com/signup

### API Keys
- [ ] **Key ID:** `rzp_live_____________________________`
- [ ] **Key Secret:** `_______________________________`

### Subscription Plan
- [ ] **Plan ID:** `plan_____________________________`
- [ ] **Amount:** ₹29
- [ ] **Billing Cycle:** Monthly

### Webhook
- [ ] **Webhook URL:** `https://your-railway-url.up.railway.app/api/payment/webhook`
- [ ] **Webhook Secret:** `_______________________________`

**Note:** Use TEST keys (rzp_test_xxx) for testing, then switch to LIVE keys (rzp_live_xxx) for production.

---

## 🔥 FIREBASE (Push Notifications)

**Sign up:** https://console.firebase.google.com

### Project Details
- [ ] **Project ID:** `_______________________________`
- [ ] **Project Name:** `_______________________________`

### Service Account (for Backend)
- [ ] **Project ID:** `_______________________________`
- [ ] **Private Key:**
```
-----BEGIN PRIVATE KEY-----
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
-----END PRIVATE KEY-----
```
- [ ] **Client Email:** `firebase-adminsdk-xxxxx@xxxxx.iam.gserviceaccount.com`

### Configuration Files (for Flutter)
- [ ] **google-services.json** downloaded from Firebase Console
- [ ] Placed in: `flutter_app/android/app/google-services.json`

### Cloud Messaging
- [ ] **Cloud Messaging API enabled:** Yes/No
- [ ] **Server Key (optional):** `_______________________________`

**How to get Service Account:**
1. Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download JSON file
4. Extract: project_id, private_key, client_email

---

## 🔑 ADMIN CREDENTIALS

Choose strong passwords for admin access:

- [ ] **JWT Secret (32+ chars):** `_______________________________`
- [ ] **Admin Username:** `admin` (or customize)
- [ ] **Admin Password:** `_______________________________`

**Generate JWT Secret:**
```bash
# Option 1: Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Option 2: Online
https://www.grc.com/passwords.htm
```

---

## 🌐 DEPLOYMENT URLS

Fill these in after deployment:

- [ ] **Backend API:** `https://___________________________.up.railway.app`
- [ ] **Admin Dashboard:** `https://___________________________.vercel.app`
- [ ] **Flutter APK Location:** `https://___________________________.com/download/teerkhela.apk`

---

## 📝 ENVIRONMENT VARIABLES FOR RAILWAY

Copy this to Railway Variables (RAW Editor):

```env
PORT=5000
NODE_ENV=production

# Database (auto-added by Railway)
DATABASE_URL=${{Postgres.DATABASE_URL}}

# Razorpay
RAZORPAY_KEY_ID=rzp_live_____________________________
RAZORPAY_KEY_SECRET=_______________________________
RAZORPAY_PLAN_ID=plan_____________________________
RAZORPAY_WEBHOOK_SECRET=_______________________________

# Firebase
FIREBASE_PROJECT_ID=_______________________________
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@xxxxx.iam.gserviceaccount.com

# Admin
JWT_SECRET=_______________________________
ADMIN_USERNAME=admin
ADMIN_PASSWORD=_______________________________

# Scraping
TEER_RESULTS_URL=https://teerresults.com
WORDPRESS_API_URL=https://yoursite.com/wp-json/wp/v2
```

---

## 📱 FLUTTER APP UPDATES

After backend is deployed, update these files:

### 1. API Service
**File:** `flutter_app/lib/services/api_service.dart`
**Line:** 6

```dart
// Change from:
static const String baseUrl = 'http://localhost:5000/api';

// To:
static const String baseUrl = 'https://YOUR_RAILWAY_URL.up.railway.app/api';
```

### 2. Razorpay Keys
**File:** `flutter_app/lib/screens/subscribe_screen_full.dart`
**Lines:** 19-20

```dart
static const String razorpayKeyId = 'rzp_live_YOUR_KEY_ID';
static const String planId = 'plan_YOUR_PLAN_ID';
```

### 3. Firebase Config
**File:** `flutter_app/android/app/google-services.json`

- [ ] Downloaded from Firebase Console
- [ ] Placed in correct location

---

## 💻 ADMIN DASHBOARD UPDATES

After backend is deployed, update:

**File:** `admin-dashboard/src/services/api.js`
**Line:** 3

```javascript
// Change from:
const API_BASE_URL = 'http://localhost:5000/api';

// To:
const API_BASE_URL = 'https://YOUR_RAILWAY_URL.up.railway.app/api';
```

---

## ✅ TESTING CHECKLIST

After deployment, test these:

### Backend Tests
- [ ] Health check: `GET /api/health`
- [ ] Get results: `GET /api/results`
- [ ] Admin login: `POST /api/admin/login`
- [ ] Scraper running (check logs)
- [ ] Predictions generating (check logs)

### Razorpay Tests
- [ ] Create test subscription
- [ ] Payment success flow
- [ ] Webhook receives events
- [ ] User premium status updates

### Firebase Tests
- [ ] Send test notification
- [ ] Flutter app receives notification
- [ ] Notification tap navigation works

### Flutter App Tests
- [ ] App installs on Android
- [ ] Results load from backend
- [ ] Premium features blocked for free users
- [ ] Payment opens Razorpay
- [ ] Payment success unlocks premium
- [ ] Notifications received

### Admin Dashboard Tests
- [ ] Login with credentials
- [ ] Dashboard statistics load
- [ ] User list displays
- [ ] Can extend premium
- [ ] Manual result entry works
- [ ] Send notification works

---

## 🚨 SECURITY REMINDERS

- [ ] **NEVER commit .env files to Git** (already in .gitignore)
- [ ] **Use strong admin password** (12+ characters, mixed case, numbers, symbols)
- [ ] **Keep this checklist file secure** (don't share publicly)
- [ ] **Use LIVE Razorpay keys only in production** (test keys for development)
- [ ] **Enable 2FA on Railway, GitHub, Razorpay, Firebase**
- [ ] **Regularly rotate JWT_SECRET and admin password**
- [ ] **Monitor Railway logs for suspicious activity**

---

## 📊 ACCOUNT LIMITS (Free Tiers)

### Railway
- **Free:** $5/month credit
- **Estimated usage:** $5-15/month (with database)
- **Upgrade when:** Traffic grows or free credit exhausted

### Razorpay
- **Free:** Unlimited transactions
- **Charges:** 2% per transaction (deducted automatically)
- **Settlement:** T+2 days to bank account

### Firebase
- **Free (Spark):**
  - Cloud Messaging: Unlimited
  - Storage: 1 GB
  - Realtime DB: 1 GB
- **Paid (Blaze):** Pay as you go (if needed)

### Vercel (Admin Dashboard)
- **Free:** Unlimited deployments
- **Bandwidth:** 100 GB/month
- **More than enough for admin dashboard**

---

## 📞 SUPPORT LINKS

- **Railway:** https://railway.app/help
- **Razorpay:** https://razorpay.com/support/
- **Firebase:** https://firebase.google.com/support
- **Vercel:** https://vercel.com/support

---

## ✅ COMPLETION STATUS

Mark as you complete each step:

- [ ] Railway account created
- [ ] Razorpay account verified
- [ ] Firebase project created
- [ ] All credentials gathered
- [ ] Backend deployed to Railway
- [ ] Environment variables configured
- [ ] Backend tested and working
- [ ] Flutter app updated with URLs
- [ ] APK built and tested
- [ ] Admin dashboard deployed
- [ ] End-to-end testing complete

---

**🎉 Once all checkboxes are marked, your Teer Khela app is LIVE!**
