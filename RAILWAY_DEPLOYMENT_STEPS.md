# 🚀 Railway Deployment Guide - Step by Step

## ✅ COMPLETED: Code Pushed to GitHub
- **Repository:** https://github.com/rtsant123/teerkhela
- **Files:** 77 files, 13,026 lines of code
- **Status:** Ready for deployment

---

## 🎯 NEXT: Deploy Backend to Railway

### STEP 1: Create Railway Account & Project (5 minutes)

1. **Go to Railway:** https://railway.app
2. **Sign up/Login** with GitHub (recommended)
3. Click **"New Project"**
4. Select **"Deploy from GitHub repo"**
5. **Authorize Railway** to access your GitHub account
6. Select repository: **`rtsant123/teerkhela`**
7. Railway will detect your project structure

### STEP 2: Configure Root Directory (Important!)

Since your backend is in a subdirectory, you need to tell Railway:

1. After selecting the repo, Railway will ask about the service
2. Click on the deployment settings
3. **Set Root Directory:** `backend`
4. **Set Start Command:** `npm start` (or leave default)
5. Click **"Deploy"**

### STEP 3: Add PostgreSQL Database (3 minutes)

1. In your Railway project dashboard
2. Click **"+ New"** → **"Database"** → **"Add PostgreSQL"**
3. Railway will automatically:
   - Create a PostgreSQL database
   - Generate a DATABASE_URL
   - Add it to your environment variables

### STEP 4: Add Environment Variables (5 minutes)

Click on your backend service → **"Variables"** tab → **"RAW Editor"**

**Copy and paste this template, then fill in your actual values:**

```env
PORT=5000
NODE_ENV=production

# Database (Railway will auto-add this, but verify it exists)
DATABASE_URL=${{Postgres.DATABASE_URL}}

# Razorpay (Get from https://dashboard.razorpay.com/app/keys)
RAZORPAY_KEY_ID=rzp_live_YOUR_KEY_HERE
RAZORPAY_KEY_SECRET=YOUR_SECRET_HERE
RAZORPAY_PLAN_ID=plan_YOUR_PLAN_ID_HERE
RAZORPAY_WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET

# Firebase (Get from Firebase Console → Project Settings → Service Accounts)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com

# Admin Credentials (Choose strong password!)
JWT_SECRET=your_random_32_character_secret_key_here
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_admin_password_here

# Scraping URLs
TEER_RESULTS_URL=https://teerresults.com
WORDPRESS_API_URL=https://yoursite.com/wp-json/wp/v2
```

**Click "Save"** - Railway will automatically redeploy.

---

## 🔐 STEP 5: Get Your Credentials

### A. Razorpay Setup (if not done)

1. **Go to:** https://dashboard.razorpay.com/signup
2. Complete KYC verification
3. Go to **Settings → API Keys → Generate Keys**
4. Copy **Key ID** and **Key Secret**
5. Go to **Subscriptions → Plans → Create Plan**
   - Amount: ₹29
   - Billing Cycle: Monthly
   - Copy the **Plan ID**

### B. Firebase Setup (if not done)

1. **Go to:** https://console.firebase.google.com
2. Create new project (or use existing)
3. Enable **Cloud Messaging:**
   - Project Settings → Cloud Messaging → Enable API
4. Get **Service Account:**
   - Project Settings → Service Accounts
   - Click **"Generate New Private Key"**
   - Download the JSON file
   - Extract these values:
     - `project_id`
     - `private_key` (keep the `\n` characters)
     - `client_email`

### C. Generate JWT Secret

Run this command in your terminal:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Or use: https://www.grc.com/passwords.htm (63 random characters)

---

## 📡 STEP 6: Get Your Backend URL

After deployment completes:

1. Go to your Railway project
2. Click on your backend service
3. Go to **"Settings"** tab
4. Scroll to **"Domains"** section
5. Click **"Generate Domain"**
6. You'll get a URL like: `https://teerkhela-backend-production.up.railway.app`

**Copy this URL - you'll need it for:**
- Flutter app API configuration
- Admin dashboard API configuration
- Razorpay webhook configuration

---

## 🧪 STEP 7: Test Your Backend

Test these endpoints in your browser:

```
1. Health Check:
   https://your-railway-url.up.railway.app/api/health

   Expected: {"status":"ok","timestamp":"..."}

2. Get Results:
   https://your-railway-url.up.railway.app/api/results

   Expected: {"results": {...}}

3. Test Admin Login (use Postman or curl):
   POST https://your-railway-url.up.railway.app/api/admin/login
   Body: {"username":"admin","password":"your_password"}

   Expected: {"token":"...","message":"Login successful"}
```

---

## ⚙️ STEP 8: Configure Razorpay Webhook

1. **Go to:** https://dashboard.razorpay.com/app/webhooks
2. Click **"+ New Webhook"**
3. **Webhook URL:** `https://your-railway-url.up.railway.app/api/payment/webhook`
4. **Active Events:** Select all subscription events:
   - `subscription.activated`
   - `subscription.charged`
   - `subscription.completed`
   - `subscription.cancelled`
   - `subscription.paused`
   - `subscription.resumed`
5. Click **"Create Webhook"**
6. Copy the **Webhook Secret**
7. Add it to Railway environment variables as `RAZORPAY_WEBHOOK_SECRET`

---

## 🔄 STEP 9: Verify Cron Jobs Are Running

Check Railway logs for these messages:

```
[Scraper] Starting scrape at 10:00 AM
[Predictions] Generating predictions at 5:30 AM
[Notifications] Sending daily notifications at 6:00 AM
```

**To view logs:**
1. Railway Dashboard → Your Service
2. Click **"Deployments"** tab
3. Click on latest deployment
4. View **"Logs"** in real-time

---

## 🎉 SUCCESS CHECKLIST

- [ ] Railway project created
- [ ] PostgreSQL database added
- [ ] All environment variables configured
- [ ] Domain generated
- [ ] Health check returns {"status":"ok"}
- [ ] Results endpoint returns data
- [ ] Admin login works
- [ ] Razorpay webhook configured
- [ ] Cron jobs appear in logs

---

## 🐛 TROUBLESHOOTING

### "Application failed to respond"
- Check logs for errors
- Verify DATABASE_URL is set
- Ensure PORT is 5000
- Check that root directory is set to `backend`

### "Database connection failed"
- Verify PostgreSQL is added to project
- Check DATABASE_URL format: `postgresql://user:pass@host:port/db`
- Ensure database is in same project

### "Firebase error"
- Verify FIREBASE_PRIVATE_KEY has `\n` characters (not actual newlines)
- Wrap private key in double quotes
- Check project_id and client_email are correct

### "Razorpay webhook not working"
- Verify webhook URL is correct
- Check RAZORPAY_WEBHOOK_SECRET matches
- Test webhook with Razorpay dashboard test feature

---

## 📊 RAILWAY COSTS

**Free Tier:**
- $5 worth of usage per month
- Good for testing and small traffic

**Paid Plans:**
- Pay-as-you-go: ~$5-20/month for small apps
- Scales automatically with usage

**Your estimated cost:** $5-15/month (includes database + backend)

---

## 🔄 AUTOMATIC DEPLOYMENTS

Railway is now connected to your GitHub repo!

**Every time you push to GitHub:**
```bash
git add .
git commit -m "Update feature"
git push
```

Railway will automatically:
1. Detect the push
2. Build your app
3. Deploy new version
4. Zero downtime

---

## 📞 NEED HELP?

1. **Railway Docs:** https://docs.railway.app
2. **Railway Discord:** https://discord.gg/railway
3. **Check Logs:** Railway Dashboard → Deployments → Logs
4. **Check this guide:** Review each step carefully

---

## ✅ NEXT AFTER BACKEND IS LIVE

1. Update Flutter app with your Railway URL
2. Build Flutter APK
3. Deploy admin dashboard to Vercel
4. Test end-to-end payment flow

**Once backend is deployed, let me know and I'll help you configure the Flutter app and admin dashboard!**
