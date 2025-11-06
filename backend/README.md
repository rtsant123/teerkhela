# Teer Khela Backend API

Complete Node.js backend for Teer Khela mobile app with AI predictions, dream interpretation, and auto-recurring subscriptions.

## Features

- ✅ Web scraping for 6 Teer games (Shillong, Khanapara, Juwai + Morning variants)
- ✅ AI-powered predictions based on historical data analysis
- ✅ Multi-language dream interpretation bot (Hindi, Bengali, English, etc.)
- ✅ Firebase Cloud Messaging for push notifications
- ✅ Razorpay auto-recurring subscriptions
- ✅ PostgreSQL database
- ✅ Admin APIs for dashboard
- ✅ Automated cron jobs

## Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Variables

Copy `.env.example` to `.env` and fill in your credentials:

```bash
cp .env.example .env
```

Required variables:
- `DATABASE_URL`: Railway PostgreSQL connection string
- `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_PLAN_ID`: From Razorpay Dashboard
- `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL`: From Firebase Console
- `JWT_SECRET`: Any random secure string
- `ADMIN_USERNAME`, `ADMIN_PASSWORD`: Admin login credentials

### 3. Database Setup

The database tables will be created automatically on first run. Make sure your PostgreSQL database is accessible.

### 4. Firebase Setup

1. Go to Firebase Console → Project Settings → Service Accounts
2. Generate new private key (downloads JSON)
3. Extract `project_id`, `private_key`, and `client_email` to `.env`

### 5. Razorpay Setup

1. Go to Razorpay Dashboard → Settings → API Keys
2. Copy `key_id` and `key_secret`
3. Create subscription plan in Dashboard → Subscriptions → Plans
4. Set amount to ₹2900 (₹29 in paise), frequency: monthly
5. Copy Plan ID to `.env`

## Running

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

Server runs on `http://localhost:5000` (or `PORT` from `.env`)

## API Endpoints

### Public Endpoints

- `GET /api/results` - Get all current results
- `GET /api/results/:game/history?days=7` - Get result history
- `POST /api/user/register` - Register user with FCM token
- `GET /api/user/:userId/status` - Get user premium status

### Premium Endpoints (require premium subscription)

- `GET /api/predictions?userId=xxx` - Get AI predictions
- `POST /api/dream-interpret` - Interpret dream with multi-language
- `GET /api/dream-history/:userId` - Get user's dream history
- `GET /api/common-numbers/:game?userId=xxx` - Get hot/cold numbers
- `POST /api/calculate-formula` - Calculate Teer formulas

### Payment Endpoints

- `POST /api/payment/create-subscription` - Create Razorpay subscription
- `POST /api/payment/webhook` - Razorpay webhook (auto-called)
- `POST /api/payment/cancel-subscription` - Cancel subscription

### Admin Endpoints (require admin JWT token)

- `POST /api/admin/login` - Admin login
- `GET /api/admin/stats` - Dashboard statistics
- `GET /api/admin/users` - Get all users
- `POST /api/admin/user/:userId/extend-premium` - Extend premium
- `POST /api/admin/predictions/override` - Override AI predictions
- `POST /api/admin/notification/send` - Send push notification
- `GET /api/admin/notifications/history` - Notification history

## Cron Jobs

The following automated tasks run on schedule:

1. **Result Scraper** - Every 10 minutes
   - Scrapes results from teerresults.com
   - Fetches results from WordPress API

2. **Generate Predictions** - Daily at 5:30 AM
   - Generates AI predictions for all 6 games
   - Saves to database

3. **Send Predictions Notification** - Daily at 6:00 AM
   - Sends push notification to all premium users
   - "Your Daily Predictions Are Ready!"

4. **Expiry Reminder** - Daily at 9:00 AM
   - Notifies users whose subscription expires in 3 days

5. **Data Cleanup** - Daily at 2:00 AM
   - Deletes results older than 90 days
   - Deletes predictions older than 30 days

## Deployment

### Railway (Recommended)

1. Push code to GitHub
2. Create new project on Railway
3. Connect GitHub repo
4. Add environment variables
5. Railway will auto-deploy on push

### Other Platforms

Works on any Node.js hosting:
- Heroku
- Render
- DigitalOcean
- AWS EC2

## Project Structure

```
backend/
├── src/
│   ├── config/          # Database, Firebase, Razorpay config
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Auth, premium check
│   ├── models/          # Database models
│   ├── routes/          # API routes
│   ├── services/        # Business logic (scraper, predictions, dream)
│   └── server.js        # Main server file
├── package.json
├── .env.example
└── README.md
```

## Testing

Test endpoints with cURL or Postman:

```bash
# Health check
curl http://localhost:5000/api/health

# Get results
curl http://localhost:5000/api/results

# Register user
curl -X POST http://localhost:5000/api/user/register \
  -H "Content-Type: application/json" \
  -d '{"fcmToken": "xxx", "deviceInfo": "Test Device"}'
```

## Support

For issues or questions, check:
- Server logs for errors
- Database connectivity
- Firebase/Razorpay credentials
- Environment variables

## License

Proprietary - All rights reserved
