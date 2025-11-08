# 🚀 Railway Deployment Guide - Teer Khela Backend

## Prerequisites
- Railway account (https://railway.app - Free $5 credit/month)
- GitHub account (for connecting repository)
- Razorpay account (for payment keys)
- Firebase project (for notifications)

---

## Step 1: Prepare Database (PostgreSQL)

### Option A: Railway PostgreSQL (Recommended)
1. Go to Railway dashboard
2. Click **"New Project"** → **"Provision PostgreSQL"**
3. Wait for database to be created
4. Click on PostgreSQL service → **Variables** tab
5. Copy the `DATABASE_URL` (format: `postgresql://user:pass@host:port/db`)

### Option B: External PostgreSQL (Neon.tech - Free 512MB)
1. Go to https://neon.tech
2. Create free account
3. Create new project → Get connection string
4. Use this as your `DATABASE_URL`

---

## Step 2: Set Up Firebase (Push Notifications)

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. **Settings** → **Service Accounts** → **Generate New Private Key**
4. Download JSON file (e.g., `firebase-credentials.json`)
5. Copy entire JSON content (you'll paste it in Railway)

---

## Step 3: Get Razorpay Keys

1. Go to Razorpay Dashboard: https://dashboard.razorpay.com
2. Settings → API Keys → **Generate Test Key** (for testing)
3. Copy `Key ID` and `Key Secret`
4. For production: Generate Live Keys instead

---

## Step 4: Deploy Backend to Railway

### Method 1: Direct Git Push (Easiest)

#### 4.1 Create New Railway Project
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Navigate to backend folder
cd backend

# Initialize Railway project
railway init

# Link to new project
railway link
```

#### 4.2 Add Environment Variables
```bash
# Add all required environment variables
railway variables set NODE_ENV=production
railway variables set PORT=3000
railway variables set DATABASE_URL="your_postgres_url_here"
railway variables set RAZORPAY_KEY_ID="your_razorpay_key_id"
railway variables set RAZORPAY_KEY_SECRET="your_razorpay_secret"
railway variables set RAZORPAY_WEBHOOK_SECRET="your_webhook_secret"

# Firebase (paste entire JSON content in quotes)
railway variables set FIREBASE_CREDENTIALS='{"type":"service_account","project_id":"your-project",...}'

# JWT Secret (generate random string)
railway variables set JWT_SECRET="your_random_jwt_secret_here_min_32_chars"

# CORS Origin (your frontend URL, for now use *)
railway variables set CORS_ORIGIN="*"
```

#### 4.3 Deploy
```bash
# Deploy to Railway
railway up

# Your backend will be live at: https://your-project.up.railway.app
```

---

### Method 2: GitHub Integration (Recommended for Teams)

#### 4.1 Push Code to GitHub
```bash
cd D:\Riogold
git init
git add backend/
git commit -m "Initial backend setup"
git branch -M main
git remote add origin https://github.com/yourusername/teer-khela-backend.git
git push -u origin main
```

#### 4.2 Connect to Railway
1. Go to Railway Dashboard → **New Project**
2. Select **"Deploy from GitHub repo"**
3. Choose your repository
4. Select `backend` folder as root directory
5. Railway auto-detects Node.js and deploys

#### 4.3 Add Environment Variables in Railway Dashboard
1. Click on your service → **Variables** tab
2. Add all environment variables (same as Method 1)
3. Railway will auto-redeploy

---

## Step 5: Environment Variables Reference

Copy this template and fill in your values:

```env
# Server
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@host:5432/database

# Razorpay
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxx
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret

# Firebase (entire JSON as single line)
FIREBASE_CREDENTIALS={"type":"service_account","project_id":"xxx","private_key_id":"xxx","private_key":"-----BEGIN PRIVATE KEY-----\nxxx\n-----END PRIVATE KEY-----\n","client_email":"xxx@xxx.iam.gserviceaccount.com","client_id":"xxx","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"xxx"}

# JWT
JWT_SECRET=your_super_secret_random_string_min_32_characters_long

# CORS (use * for testing, specific domain for production)
CORS_ORIGIN=*
```

---

## Step 6: Verify Deployment

### 6.1 Check Health
```bash
curl https://your-project.up.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-08T10:30:00.000Z",
  "database": "connected",
  "firebase": "initialized",
  "cronJobs": "running"
}
```

### 6.2 Test API Endpoints
```bash
# Get current results
curl https://your-project.up.railway.app/api/results

# Check accuracy
curl https://your-project.up.railway.app/api/accuracy/overall

# Create test user
curl https://your-project.up.railway.app/api/create-test-user
```

### 6.3 Check Railway Logs
```bash
# View live logs
railway logs

# Or check in Railway Dashboard → Service → Logs tab
```

---

## Step 7: Update Flutter App

Once backend is deployed, update API URL in Flutter app:

### 7.1 Edit `flutter_app/lib/services/api_service.dart`
```dart
class ApiService {
  // Change from localhost to Railway URL
  static const String baseUrl = 'https://your-project.up.railway.app/api';

  // ... rest of code
}
```

### 7.2 Rebuild APK
```bash
cd flutter_app
flutter clean
flutter pub get
flutter build apk --release
```

---

## Step 8: Configure Razorpay Webhook

1. Go to Razorpay Dashboard → **Webhooks**
2. Add new webhook URL: `https://your-project.up.railway.app/api/payment/webhook`
3. Select events:
   - `subscription.activated`
   - `subscription.cancelled`
   - `subscription.charged`
4. Copy webhook secret → Update Railway variable `RAZORPAY_WEBHOOK_SECRET`

---

## Step 9: Enable Cron Jobs (Auto Results & Predictions)

Your backend has 5 automated cron jobs:

| Job | Schedule | Purpose |
|-----|----------|---------|
| **Scrape Results** | Every 30 mins | Fetch latest Teer results |
| **Generate Predictions** | Daily 2 AM | Create AI predictions |
| **Verify Predictions** | Daily 6 PM | Check prediction accuracy |
| **Send Notifications** | On result update | Push notifications to users |
| **Cleanup Old Data** | Weekly Sunday 3 AM | Remove old records |

**Note:** Railway free tier keeps services running. Cron jobs will run automatically once deployed!

---

## Step 10: Domain Setup (Optional)

### Use Custom Domain
1. Railway Dashboard → Service → **Settings**
2. **Domains** section → **Add Domain**
3. Enter your domain (e.g., `api.teerkhela.com`)
4. Add CNAME record in your DNS:
   ```
   CNAME api.teerkhela.com → your-project.up.railway.app
   ```
5. Update CORS and Flutter app URL

---

## Troubleshooting

### Database Connection Error
**Error:** `Error: connect ECONNREFUSED`

**Fix:**
- Check `DATABASE_URL` in Railway variables
- Ensure PostgreSQL service is running
- Format: `postgresql://user:pass@host:port/database`

---

### Firebase Not Initialized
**Error:** `Firebase credentials not found`

**Fix:**
- Ensure `FIREBASE_CREDENTIALS` variable is set
- Paste entire JSON as single-line string
- No line breaks in the JSON

---

### Razorpay Webhook Failed
**Error:** `Webhook signature verification failed`

**Fix:**
- Update `RAZORPAY_WEBHOOK_SECRET` in Railway
- Ensure it matches Razorpay dashboard webhook secret
- Check webhook URL is correct

---

### Cron Jobs Not Running
**Fix:**
- Check Railway logs for cron job execution
- Ensure service is not sleeping (upgrade to Hobby plan if needed)
- Free tier may sleep after inactivity - use UptimeRobot for keep-alive

---

## Cost Estimate

### Railway Free Tier
- **$5/month** credit
- ~500 hours/month server time
- 100 GB bandwidth
- **Perfect for MVP!**

### Railway Hobby Plan ($5/month)
- Unlimited hours
- 100 GB bandwidth
- Custom domains
- **Recommended for production**

### PostgreSQL
- **Railway:** ~$3/month (1GB storage)
- **Neon.tech:** FREE (512MB storage)

**Total:** $0-8/month for backend hosting!

---

## Post-Deployment Checklist

- [ ] Backend deployed successfully
- [ ] Database connected and tables created
- [ ] Health endpoint returns "healthy"
- [ ] Test user created successfully
- [ ] Razorpay webhook configured
- [ ] Firebase notifications working
- [ ] Cron jobs running (check logs)
- [ ] Flutter app API URL updated
- [ ] New APK built with production URL
- [ ] APK tested on real device

---

## Next Steps After Deployment

1. **Test Complete Flow:**
   - Install APK on phone
   - Create test subscription (₹1 test mode)
   - Check predictions load
   - Verify accuracy tracking
   - Test referral code generation

2. **Monitor:**
   - Railway logs for errors
   - Database size (upgrade if >90% full)
   - API response times
   - Cron job execution

3. **Marketing:**
   - Submit APK to Google Play
   - Share app link on social media
   - Enable referral program
   - Track user signups

---

**Your Backend URL:** https://your-project.up.railway.app
**API Docs:** https://your-project.up.railway.app/api/docs
**Health Check:** https://your-project.up.railway.app/health

🎉 **Congratulations! Your world-class Teer Khela backend is now live!**

---

**Generated with Claude Code**
**Date:** January 8, 2025
**Version:** 1.0.0
