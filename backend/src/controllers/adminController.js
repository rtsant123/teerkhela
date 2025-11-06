const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Payment = require('../models/Payment');
const Notification = require('../models/Notification');
const predictionService = require('../services/predictionService');
const scraperService = require('../services/scraperService');
const { sendNotificationToMultiple, sendNotificationToUser } = require('../config/firebase');

// Admin login
const login = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required'
      });
    }

    // Check credentials against env
    if (username !== process.env.ADMIN_USERNAME || password !== process.env.ADMIN_PASSWORD) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { username, role: 'admin' },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      token,
      message: 'Login successful'
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({
      success: false,
      message: 'Login error'
    });
  }
};

// Get dashboard statistics
const getStatistics = async (req, res) => {
  try {
    const userStats = await User.getStatistics();
    const paymentStats = await Payment.getStatistics();
    const notificationStats = await Notification.getStatistics();

    // Calculate conversion rate
    const conversionRate = userStats.totalUsers > 0
      ? ((userStats.premiumUsers / userStats.totalUsers) * 100).toFixed(1)
      : 0;

    res.json({
      success: true,
      data: {
        totalUsers: userStats.totalUsers,
        premiumUsers: userStats.premiumUsers,
        freeUsers: userStats.totalUsers - userStats.premiumUsers,
        activeSubscriptions: userStats.activeSubscriptions,
        newToday: userStats.newToday,
        conversionRate: parseFloat(conversionRate),
        revenueToday: paymentStats.todayRevenue,
        revenueThisMonth: paymentStats.thisMonthRevenue,
        totalRevenue: paymentStats.totalRevenue,
        totalPayments: paymentStats.totalPayments,
        notificationsSent: notificationStats.totalSent,
        notificationsToday: notificationStats.sentToday
      }
    });
  } catch (error) {
    console.error('Error getting statistics:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching statistics'
    });
  }
};

// Get all users
const getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 50, filter = 'all' } = req.query;

    const result = await User.getAll(parseInt(page), parseInt(limit), filter);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error getting users:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching users'
    });
  }
};

// Extend user premium
const extendPremium = async (req, res) => {
  try {
    const { userId } = req.params;
    const { days = 30 } = req.body;

    const user = await User.extendPremium(userId, parseInt(days));

    // Send notification
    if (user.fcm_token) {
      await sendNotificationToUser(
        user.fcm_token,
        '🎁 Premium Extended!',
        `Your premium subscription has been extended by ${days} days. Enjoy!`,
        { screen: 'profile' }
      );
    }

    res.json({
      success: true,
      message: `Premium extended by ${days} days`,
      data: user
    });
  } catch (error) {
    console.error('Error extending premium:', error);
    res.status(500).json({
      success: false,
      message: 'Error extending premium'
    });
  }
};

// Deactivate user premium
const deactivatePremium = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.deactivatePremium(userId);

    res.json({
      success: true,
      message: 'Premium deactivated',
      data: user
    });
  } catch (error) {
    console.error('Error deactivating premium:', error);
    res.status(500).json({
      success: false,
      message: 'Error deactivating premium'
    });
  }
};

// Override prediction
const overridePrediction = async (req, res) => {
  try {
    const { date, game, fr, sr, analysis, confidence } = req.body;

    if (!date || !game || !fr || !sr) {
      return res.status(400).json({
        success: false,
        message: 'date, game, fr, and sr are required'
      });
    }

    await predictionService.overridePrediction(
      game,
      date,
      fr,
      sr,
      analysis || 'Admin override',
      confidence || 90
    );

    res.json({
      success: true,
      message: 'Prediction overridden successfully'
    });
  } catch (error) {
    console.error('Error overriding prediction:', error);
    res.status(500).json({
      success: false,
      message: 'Error overriding prediction'
    });
  }
};

// Manual result entry
const manualResultEntry = async (req, res) => {
  try {
    const { game, date, fr, sr, declaredTime } = req.body;

    if (!game || !date) {
      return res.status(400).json({
        success: false,
        message: 'game and date are required'
      });
    }

    await scraperService.manualEntry(game, date, fr, sr, declaredTime);

    // Send notification to premium users about new result
    if (fr && sr) {
      const premiumUsers = await User.getAllPremiumUsers();
      const tokens = premiumUsers.map(u => u.fcm_token).filter(t => t);

      if (tokens.length > 0) {
        await sendNotificationToMultiple(
          tokens,
          `⚡ ${game.toUpperCase()} Result Declared!`,
          `FR: ${fr} | SR: ${sr}`,
          { screen: 'result-detail', game }
        );
      }
    }

    res.json({
      success: true,
      message: 'Result entered successfully'
    });
  } catch (error) {
    console.error('Error entering result:', error);
    res.status(500).json({
      success: false,
      message: 'Error entering result'
    });
  }
};

// Send push notification
const sendPushNotification = async (req, res) => {
  try {
    const { title, body, target = 'all-premium', action, screen, userId } = req.body;

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: 'title and body are required'
      });
    }

    // Create notification record
    const notification = await Notification.create(title, body, target, action, screen);

    const data = {};
    if (action && screen) {
      data.action = action;
      data.screen = screen;
    }

    let result;

    if (target === 'all-premium') {
      // Send to all premium users
      const premiumUsers = await User.getAllPremiumUsers();
      const tokens = premiumUsers.map(u => u.fcm_token).filter(t => t);

      if (tokens.length === 0) {
        return res.json({
          success: true,
          message: 'No premium users with FCM tokens',
          sent: 0
        });
      }

      result = await sendNotificationToMultiple(tokens, title, body, data);

      // Update notification stats
      await Notification.updateStats(notification.id, result.sent, result.sent);
    } else if (target === 'all') {
      // Send to all users
      const allUsersResult = await User.pool.query(
        'SELECT fcm_token FROM users WHERE fcm_token IS NOT NULL'
      );
      const tokens = allUsersResult.rows.map(u => u.fcm_token);

      if (tokens.length === 0) {
        return res.json({
          success: true,
          message: 'No users with FCM tokens',
          sent: 0
        });
      }

      result = await sendNotificationToMultiple(tokens, title, body, data);

      await Notification.updateStats(notification.id, result.sent, result.sent);
    } else if (userId) {
      // Send to specific user
      const user = await User.findById(userId);

      if (!user || !user.fcm_token) {
        return res.status(404).json({
          success: false,
          message: 'User not found or no FCM token'
        });
      }

      result = await sendNotificationToUser(user.fcm_token, title, body, data);

      await Notification.updateStats(notification.id, result.success ? 1 : 0, result.success ? 1 : 0);
    } else {
      return res.status(400).json({
        success: false,
        message: 'Invalid target'
      });
    }

    res.json({
      success: true,
      message: 'Notification sent successfully',
      sent: result.sent || (result.success ? 1 : 0),
      failed: result.failed || 0
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      success: false,
      message: 'Error sending notification'
    });
  }
};

// Get notification history
const getNotificationHistory = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    const result = await Notification.getHistory(parseInt(page), parseInt(limit));

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error getting notification history:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching notification history'
    });
  }
};

// Get revenue chart data
const getRevenueChart = async (req, res) => {
  try {
    const data = await Payment.getRevenueChartData();

    res.json({
      success: true,
      data
    });
  } catch (error) {
    console.error('Error getting revenue chart:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching revenue chart'
    });
  }
};

module.exports = {
  login,
  getStatistics,
  getUsers,
  extendPremium,
  deactivatePremium,
  overridePrediction,
  manualResultEntry,
  sendPushNotification,
  getNotificationHistory,
  getRevenueChart
};
