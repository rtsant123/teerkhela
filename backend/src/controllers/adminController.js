const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Payment = require('../models/Payment');
const Notification = require('../models/Notification');
const Game = require('../models/Game');
const Prediction = require('../models/Prediction');
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

// Bulk upload past results (admin only)
const bulkUploadResults = async (req, res) => {
  try {
    const { results } = req.body; // Array of {game, date, fr, sr}

    if (!Array.isArray(results) || results.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'results array is required'
      });
    }

    let uploaded = 0;
    let errors = [];

    for (const result of results) {
      try {
        const { game, date, fr, sr } = result;

        if (!game || !date) {
          errors.push({ result, error: 'Missing game or date' });
          continue;
        }

        await Result.upsert(game, date, fr, sr);
        uploaded++;
      } catch (error) {
        errors.push({ result, error: error.message });
      }
    }

    res.json({
      success: true,
      uploaded,
      total: results.length,
      errors: errors.length > 0 ? errors : undefined,
      message: `Uploaded ${uploaded} of ${results.length} results`
    });
  } catch (error) {
    console.error('Error bulk uploading results:', error);
    res.status(500).json({
      success: false,
      message: 'Error uploading results'
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

// Generate predictions for all games
const generatePredictions = async (req, res) => {
  try {
    const { date } = req.body;

    // If no date provided, generate for tomorrow
    const targetDate = date || (() => {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      return tomorrow.toISOString().split('T')[0];
    })();

    console.log(`Admin triggered prediction generation for ${targetDate}`);

    const predictions = await Prediction.generateForAllGames(targetDate);

    res.json({
      success: true,
      message: `Generated ${predictions.length} predictions successfully`,
      predictions: predictions.map(p => ({
        game: p.game,
        fr: p.fr,
        sr: p.sr,
        confidence: p.confidence
      }))
    });
  } catch (error) {
    console.error('Error generating predictions:', error);
    res.status(500).json({
      success: false,
      message: 'Error generating predictions: ' + error.message
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

// Bulk add results for multiple games at once
const bulkAddResults = async (req, res) => {
  try {
    const { date, results } = req.body;

    if (!date || !results || !Array.isArray(results)) {
      return res.status(400).json({
        success: false,
        message: 'date and results array are required'
      });
    }

    const addedResults = [];
    const notifications = [];

    // Process each result
    for (const result of results) {
      const { gameId, game, fr, sr } = result;

      if (!game && !gameId) continue;

      // Use gameId if provided, otherwise use game name
      const gameName = game || (await Game.getById(gameId)).name;

      // Add result
      await scraperService.manualEntry(gameName, date, fr, sr, new Date().toISOString());

      addedResults.push({ game: gameName, fr, sr });

      // Prepare notification for this game
      if (fr && sr) {
        notifications.push({
          game: gameName,
          fr,
          sr
        });
      }
    }

    // Send bulk notification to premium users
    if (notifications.length > 0) {
      const premiumUsers = await User.getAllPremiumUsers();
      const tokens = premiumUsers.map(u => u.fcm_token).filter(t => t);

      if (tokens.length > 0) {
        const gamesList = notifications.map(n => `${n.game}: FR ${n.fr}, SR ${n.sr}`).join(' | ');
        await sendNotificationToMultiple(
          tokens,
          `⚡ All Results Declared!`,
          gamesList.substring(0, 100), // Limit message length
          { screen: 'home' }
        );
      }
    }

    res.json({
      success: true,
      message: `${addedResults.length} results entered successfully`,
      results: addedResults
    });
  } catch (error) {
    console.error('Error bulk adding results:', error);
    res.status(500).json({
      success: false,
      message: 'Error bulk adding results'
    });
  }
};

// Bulk upload historical results (30 days for one house)
const bulkHistoricalUpload = async (req, res) => {
  try {
    const { game, results } = req.body;

    if (!game || !results || !Array.isArray(results)) {
      return res.status(400).json({
        success: false,
        message: 'game and results array are required'
      });
    }

    const addedResults = [];

    // Process each date's result
    for (const result of results) {
      const { date, fr, sr } = result;

      if (!date || fr === undefined || sr === undefined) continue;

      // Add result (no notification for historical data)
      await scraperService.manualEntry(game, date, fr, sr, new Date(date).toISOString());

      addedResults.push({ date, fr, sr });
    }

    res.json({
      success: true,
      message: `${addedResults.length} historical results uploaded for ${game}`,
      results: addedResults
    });
  } catch (error) {
    console.error('Error uploading historical results:', error);
    res.status(500).json({
      success: false,
      message: 'Error uploading historical results'
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

// ========== GAME MANAGEMENT ==========

// Get all games
const getAllGames = async (req, res) => {
  try {
    const { includeInactive = false } = req.query;
    const games = await Game.getAll(includeInactive === 'true');

    // Get statistics for each game
    const gamesWithStats = await Promise.all(
      games.map(async (game) => {
        const stats = await Game.getStats(game.name);
        return { ...game, stats };
      })
    );

    res.json({
      success: true,
      data: gamesWithStats
    });
  } catch (error) {
    console.error('Error getting games:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching games'
    });
  }
};

// Get single game
const getGame = async (req, res) => {
  try {
    const { id } = req.params;
    const game = await Game.getById(id);

    if (!game) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }

    const stats = await Game.getStats(game.name);

    res.json({
      success: true,
      data: { ...game, stats }
    });
  } catch (error) {
    console.error('Error getting game:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching game'
    });
  }
};

// Create new game
const createGame = async (req, res) => {
  try {
    const { name, display_name, region, scrape_url, is_active, scrape_enabled, fr_time, sr_time, display_order } = req.body;

    if (!name || !display_name) {
      return res.status(400).json({
        success: false,
        message: 'name and display_name are required'
      });
    }

    // Check if game already exists
    const existing = await Game.getByName(name);
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Game with this name already exists'
      });
    }

    const game = await Game.create({
      name,
      display_name,
      region,
      scrape_url,
      is_active,
      scrape_enabled,
      fr_time,
      sr_time,
      display_order
    });

    res.json({
      success: true,
      message: 'Game created successfully',
      data: game
    });
  } catch (error) {
    console.error('Error creating game:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating game'
    });
  }
};

// Update game
const updateGame = async (req, res) => {
  try {
    const { id } = req.params;
    const { display_name, region, scrape_url, is_active, scrape_enabled, fr_time, sr_time, display_order } = req.body;

    const game = await Game.update(id, {
      display_name,
      region,
      scrape_url,
      is_active,
      scrape_enabled,
      fr_time,
      sr_time,
      display_order
    });

    if (!game) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }

    res.json({
      success: true,
      message: 'Game updated successfully',
      data: game
    });
  } catch (error) {
    console.error('Error updating game:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating game'
    });
  }
};

// Delete game (soft delete)
const deleteGame = async (req, res) => {
  try {
    const { id } = req.params;

    const game = await Game.delete(id);

    if (!game) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }

    res.json({
      success: true,
      message: 'Game deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting game:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting game'
    });
  }
};

// Toggle game active status
const toggleGameActive = async (req, res) => {
  try {
    const { id } = req.params;

    const game = await Game.toggleActive(id);

    if (!game) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }

    res.json({
      success: true,
      message: `Game ${game.is_active ? 'activated' : 'deactivated'} successfully`,
      data: game
    });
  } catch (error) {
    console.error('Error toggling game:', error);
    res.status(500).json({
      success: false,
      message: 'Error toggling game status'
    });
  }
};

// Toggle game scraping
const toggleGameScraping = async (req, res) => {
  try {
    const { id } = req.params;

    const game = await Game.toggleScraping(id);

    if (!game) {
      return res.status(404).json({
        success: false,
        message: 'Game not found'
      });
    }

    res.json({
      success: true,
      message: `Scraping ${game.scrape_enabled ? 'enabled' : 'disabled'} for ${game.display_name}`,
      data: game
    });
  } catch (error) {
    console.error('Error toggling scraping:', error);
    res.status(500).json({
      success: false,
      message: 'Error toggling scraping'
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
  generatePredictions,
  manualResultEntry,
  bulkAddResults,
  bulkUploadResults,
  bulkHistoricalUpload,
  sendPushNotification,
  getNotificationHistory,
  getRevenueChart,
  // Game management
  getAllGames,
  getGame,
  createGame,
  updateGame,
  deleteGame,
  toggleGameActive,
  toggleGameScraping
};
