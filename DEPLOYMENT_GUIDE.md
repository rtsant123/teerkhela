# 🚀 Teer Khela - Complete Deployment Guide

## Overview

This guide covers deploying all three components:
1. **Backend API** → Railway
2. **Flutter Mobile App** → Direct APK distribution
3. **Admin Dashboard** → Vercel

---

## 📋 Pre-Deployment Checklist

### Backend Requirements
- [ ] Railway account (https://railway.app)
- [ ] PostgreSQL database URL
- [ ] Razorpay account with Plan ID
- [ ] Firebase project with Admin SDK credentials
- [ ] GitHub repository (optional but recommended)

### Flutter Requirements
- [ ] Flutter SDK installed
- [ ] Android Studio (for building APK)
- [ ] Firebase `google-services.json` file
- [ ] Razorpay Live API keys
- [ ] Website to host APK (optional: WordPress)

### Admin Dashboard Requirements
- [ ] Vercel account (https://vercel.com)
- [ ] GitHub repository (optional)

---

## 1️⃣ Backend Deployment (Railway)

### Step 1: Prepare Backend

```bash
cd backend

# Create .env file
cp .env.example .env

# Fill in all credentials in .env
nano .env
```

**Required Environment Variables:**
```env
PORT=5000
NODE_ENV=production

DATABASE_URL=postgresql://user:password@host:port/database

RAZORPAY_KEY_ID=rzp_live_xxxxx
RAZORPAY_KEY_SECRET=your_secret
RAZORPAY_PLAN_ID=plan_xxxxx
RAZORPAY_WEBHOOK_SECRET=webhook_secret

FIREBASE_PROJECT_ID=your_project
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n..."
FIREBASE_CLIENT_EMAIL=xxx@xxx.iam.gserviceaccount.com

JWT_SECRET=your_random_secret_key
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password

WORDPRESS_API_URL=https://yoursite.com/wp-json/wp/v2
TEER_RESULTS_URL=https://teerresults.com
```

### Step 2: Test Locally

```bash
npm install
npm start

# Test endpoints
curl http://localhost:5000/api/health
```

### Step 3: Deploy to Railway

#### Option A: GitHub (Recommended)

```bash
# Initialize git if not already
git init
git add .
git commit -m "Initial commit"

# Push to GitHub
git remote add origin https://github.com/yourusername/teer-khela-backend.git
git push -u origin main
```

**In Railway Dashboard:**
1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Select your repository
4. Railway will auto-detect Node.js

#### Option B: Railway CLI

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize
railway init

# Deploy
railway up
```

### Step 4: Add Environment Variables in Railway

1. Go to your project → Variables
2. Click "RAW Editor"
3. Paste all your .env variables
4. Save

### Step 5: Configure Database

Railway provides free PostgreSQL:
1. Click "New" → "Database" → "PostgreSQL"
2. Copy the DATABASE_URL
3. Add to your project variables

### Step 6: Get Your Backend URL

```
https://your-project-name.up.railway.app
```

Test: `https://your-project-name.up.railway.app/api/health`

### Step 7: Configure Razorpay Webhook

1. Go to Razorpay Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-railway-url.up.railway.app/api/payment/webhook`
3. Select all subscription events
4. Copy webhook secret to .env

---

## 2️⃣ Flutter App Deployment (APK)

### Step 1: Prepare Flutter App

```bash
cd flutter_app

# Rename main file
cp lib/main_complete.dart lib/main.dart

# Update API base URL
nano lib/services/api_service.dart
```

**In `lib/services/api_service.dart`:**
```dart
// Change from:
static const String baseUrl = 'http://localhost:5000/api';

// To:
static const String baseUrl = 'https://your-railway-url.up.railway.app/api';
```

### Step 2: Add Firebase Configuration

```bash
# Download google-services.json from Firebase Console
# Place it in: android/app/google-services.json
```

### Step 3: Update Razorpay Keys

**In `lib/screens/subscribe_screen_full.dart`:**
```dart
// Change from:
static const String razorpayKeyId = 'rzp_live_YOUR_KEY_ID';
static const String planId = 'plan_xxxxx';

// To your actual keys:
static const String razorpayKeyId = 'rzp_live_YOUR_ACTUAL_KEY';
static const String planId = 'plan_YOUR_ACTUAL_PLAN_ID';
```

### Step 4: Update App Name and Icon (Optional)

**In `android/app/src/main/AndroidManifest.xml`:**
```xml
<application
    android:label="Teer Khela"
    android:icon="@mipmap/ic_launcher">
```

### Step 5: Build APK

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

**APK Size:** ~50-60 MB

### Step 6: Test APK

```bash
# Install on connected Android device
flutter install --release

# Or manually:
# Copy app-release.apk to phone
# Install and test all features
```

### Step 7: Distribute APK

#### Option A: WordPress
```bash
# Upload to: /wp-content/uploads/apps/teerkhela.apk
# Create download page with link
```

#### Option B: Direct Download
- Upload to Google Drive / Dropbox
- Get shareable link
- Share with users

#### Option C: Your Website
- Upload to your web hosting
- Create download page
- Example: `https://yoursite.com/download/teerkhela.apk`

### Important Notes for Users

**Users need to:**
1. Enable "Install from Unknown Sources" in Android settings
2. Download the APK file
3. Open and install
4. Allow all permissions (especially notifications)

---

## 3️⃣ Admin Dashboard Deployment (Vercel)

### Step 1: Prepare Dashboard

```bash
cd admin-dashboard

# Update API URL
nano src/services/api.js
```

**In `src/services/api.js`:**
```javascript
// Change from:
const API_BASE_URL = 'http://localhost:5000/api';

// To:
const API_BASE_URL = 'https://your-railway-url.up.railway.app/api';
```

### Step 2: Test Build Locally

```bash
npm install
npm run build

# Test production build
npm run preview
```

### Step 3: Deploy to Vercel

#### Option A: Vercel CLI (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Follow prompts
# For production: vercel --prod
```

#### Option B: GitHub + Vercel Dashboard

```bash
# Push to GitHub
git add .
git commit -m "Admin dashboard"
git push
```

**In Vercel Dashboard:**
1. Click "New Project"
2. Import from GitHub
3. Select repository
4. Configure:
   - Framework Preset: Vite
   - Build Command: `npm run build`
   - Output Directory: `dist`
5. Deploy

### Step 4: Get Your Dashboard URL

```
https://teer-khela-admin.vercel.app
```

### Step 5: Configure Custom Domain (Optional)

In Vercel:
1. Go to project → Settings → Domains
2. Add custom domain: `admin.yoursite.com`
3. Update DNS records as instructed

---

## 🔐 Post-Deployment Security

### Backend
- [ ] Use strong JWT_SECRET (random 32+ characters)
- [ ] Use strong ADMIN_PASSWORD
- [ ] Enable HTTPS only (Railway does this automatically)
- [ ] Monitor logs for suspicious activity

### Flutter App
- [ ] Use production Razorpay keys (not test)
- [ ] Test payment flow thoroughly
- [ ] Monitor Firebase for failed notifications

### Admin Dashboard
- [ ] Change default admin password immediately
- [ ] Use HTTPS only (Vercel does this automatically)
- [ ] Limit admin access to trusted IPs (optional)

---

## 🧪 Testing Checklist

### Backend API
```bash
# Health check
curl https://your-backend.up.railway.app/api/health

# Get results
curl https://your-backend.up.railway.app/api/results

# Test admin login (use Postman)
POST /api/admin/login
{
  "username": "admin",
  "password": "your_password"
}
```

### Flutter App
- [ ] App installs successfully
- [ ] Home screen loads results
- [ ] Predictions screen shows premium gate
- [ ] Subscribe button opens Razorpay
- [ ] Payment completes successfully
- [ ] Premium features unlock after payment
- [ ] Push notifications received
- [ ] Dream bot works in multiple languages

### Admin Dashboard
- [ ] Login works
- [ ] Dashboard shows statistics
- [ ] User list loads
- [ ] Can extend premium
- [ ] Predictions override works
- [ ] Manual result entry works
- [ ] Notifications send successfully

---

## 📊 Monitoring

### Backend (Railway)
- View logs: Railway Dashboard → Project → Deployments → Logs
- Monitor: CPU, Memory, Network usage
- Set up alerts for errors

### Flutter App
- Monitor Firebase Analytics
- Track crash reports
- Monitor Razorpay dashboard for payments

### Admin Dashboard
- Monitor Vercel Analytics
- Check for 404 errors
- Monitor API response times

---

## 🆘 Troubleshooting

### Backend Issues

**Problem:** Can't connect to database
- **Solution:** Check DATABASE_URL is correct
- **Solution:** Ensure PostgreSQL is running on Railway

**Problem:** Cron jobs not running
- **Solution:** Check server logs
- **Solution:** Verify node-cron package installed

**Problem:** Razorpay webhook not working
- **Solution:** Verify webhook URL in Razorpay dashboard
- **Solution:** Check RAZORPAY_WEBHOOK_SECRET matches

### Flutter App Issues

**Problem:** App won't install
- **Solution:** Enable "Unknown Sources" in Android
- **Solution:** Check APK is not corrupted (re-download)

**Problem:** Payment not working
- **Solution:** Check Razorpay keys are live (not test)
- **Solution:** Verify plan ID is correct

**Problem:** Notifications not received
- **Solution:** Check google-services.json is correct
- **Solution:** Ensure notification permissions granted

### Admin Dashboard Issues

**Problem:** Can't login
- **Solution:** Verify ADMIN_USERNAME and ADMIN_PASSWORD in backend
- **Solution:** Clear browser localStorage

**Problem:** API calls failing
- **Solution:** Check API_BASE_URL is correct
- **Solution:** Verify backend is running
- **Solution:** Check CORS settings in backend

---

## 📝 Maintenance

### Regular Tasks
- **Daily:** Monitor error logs
- **Weekly:** Check user signups and conversions
- **Monthly:** Review revenue and user growth
- **Quarterly:** Update dependencies (npm audit)

### Updates
```bash
# Backend
cd backend
npm update
npm audit fix

# Flutter
cd flutter_app
flutter upgrade
flutter pub upgrade

# Admin Dashboard
cd admin-dashboard
npm update
npm audit fix
```

---

## 🎉 Deployment Complete!

Your Teer Khela app is now live:

- ✅ **Backend API:** https://your-backend.up.railway.app
- ✅ **Flutter APK:** Ready for distribution
- ✅ **Admin Dashboard:** https://your-admin.vercel.app

### Next Steps:
1. Share APK download link with users
2. Monitor backend logs for errors
3. Test all features end-to-end
4. Start marketing your app!

---

## 📞 Support

For deployment issues:
1. Check logs (Railway/Vercel dashboards)
2. Test API endpoints with Postman
3. Review this guide step-by-step
4. Check Firebase/Razorpay dashboards

**Good luck! 🚀**
