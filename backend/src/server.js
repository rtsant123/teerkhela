require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const cron = require('node-cron');

// Import config
const { initDatabase } = require('./config/database');
const { initializeFirebase } = require('./config/firebase');

// Import routes
const publicRoutes = require('./routes/public');
const premiumRoutes = require('./routes/premium');
const paymentRoutes = require('./routes/payment');
const adminRoutes = require('./routes/admin');

// Import services for cron jobs
const scraperService = require('./services/scraperService');
const predictionService = require('./services/predictionService');
const User = require('./models/User');
const { sendNotificationToMultiple } = require('./config/firebase');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));

// Body parser (except for webhook route which needs raw body)
app.use((req, res, next) => {
  if (req.originalUrl === '/api/payment/webhook') {
    next();
  } else {
    express.json()(req, res, next);
  }
});

app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

app.use('/api/', limiter);

// Health check
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Teer Khela API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api', publicRoutes);
app.use('/api', premiumRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/admin', adminRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error'
  });
});

// Initialize database and Firebase
const initializeApp = async () => {
  try {
    console.log('🚀 Initializing Teer Khela Backend...');

    // Initialize database
    await initDatabase();

    // Initialize Firebase (optional - won't crash if not configured)
    try {
      initializeFirebase();
    } catch (firebaseError) {
      console.log('⚠️  Firebase initialization skipped - Push notifications will not work');
    }

    console.log('✅ App initialization complete');
  } catch (error) {
    console.error('❌ Initialization error:', error);
    process.exit(1);
  }
};

// Cron Jobs
const setupCronJobs = () => {
  console.log('⏰ Setting up cron jobs...');

  // Scrape results every 10 minutes
  cron.schedule('*/10 * * * *', async () => {
    console.log('🔄 Running result scraper...');
    try {
      await scraperService.scrapeResults();
      await scraperService.fetchWordPressResults();
    } catch (error) {
      console.error('Scraper cron error:', error);
    }
  });

  // Generate predictions daily at 5:30 AM
  cron.schedule('30 5 * * *', async () => {
    console.log('🤖 Generating daily predictions...');
    try {
      await predictionService.generateAllPredictions();
    } catch (error) {
      console.error('Prediction cron error:', error);
    }
  });

  // Send daily prediction notification at 6:00 AM to premium users
  cron.schedule('0 6 * * *', async () => {
    console.log('📨 Sending daily prediction notifications...');
    try {
      const premiumUsers = await User.getAllPremiumUsers();
      const tokens = premiumUsers.map(u => u.fcm_token).filter(t => t);

      if (tokens.length > 0) {
        await sendNotificationToMultiple(
          tokens,
          '🔮 Your Daily Predictions Are Ready!',
          'Check AI predictions for all 6 Teer games',
          { screen: 'predictions' }
        );
        console.log(`✅ Sent predictions notification to ${tokens.length} users`);
      }
    } catch (error) {
      console.error('Notification cron error:', error);
    }
  });

  // Check and notify about expired subscriptions at 9:00 AM
  cron.schedule('0 9 * * *', async () => {
    console.log('⚠️ Checking for expiring subscriptions...');
    try {
      const { pool } = require('./config/database');
      const result = await pool.query(`
        SELECT * FROM users
        WHERE is_premium = true
        AND expiry_date IS NOT NULL
        AND expiry_date >= CURRENT_DATE
        AND expiry_date <= CURRENT_DATE + INTERVAL '3 days'
        AND fcm_token IS NOT NULL
      `);

      const expiringUsers = result.rows;

      for (const user of expiringUsers) {
        const daysLeft = Math.ceil((new Date(user.expiry_date) - new Date()) / (1000 * 60 * 60 * 24));

        await sendNotificationToMultiple(
          [user.fcm_token],
          '⚠️ Subscription Expiring Soon',
          `Your premium subscription expires in ${daysLeft} day${daysLeft > 1 ? 's' : ''}. Renew now to continue enjoying premium features!`,
          { screen: 'subscribe' }
        );
      }

      if (expiringUsers.length > 0) {
        console.log(`✅ Sent expiry notifications to ${expiringUsers.length} users`);
      }
    } catch (error) {
      console.error('Expiry notification cron error:', error);
    }
  });

  // Cleanup old data every day at 2:00 AM
  cron.schedule('0 2 * * *', async () => {
    console.log('🧹 Cleaning up old data...');
    try {
      const Result = require('./models/Result');
      const Prediction = require('./models/Prediction');

      await Result.deleteOldResults(90); // Keep 90 days
      await Prediction.deleteOldPredictions(30); // Keep 30 days
      console.log('✅ Old data cleaned up');
    } catch (error) {
      console.error('Cleanup cron error:', error);
    }
  });

  console.log('✅ Cron jobs set up successfully');
};

// Start server
const startServer = async () => {
  try {
    await initializeApp();
    setupCronJobs();

    app.listen(PORT, () => {
      console.log(`\n🚀 Server running on port ${PORT}`);
      console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🌐 API URL: http://localhost:${PORT}`);
      console.log(`\n✅ Teer Khela Backend is ready!\n`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Start the server
startServer();

module.exports = app;
