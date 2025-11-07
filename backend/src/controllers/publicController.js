const scraperService = require('../services/scraperService');
const User = require('../models/User');
const Result = require('../models/Result');
const Game = require('../models/Game');
const { v4: uuidv4 } = require('uuid');

// Get all active games
const getAllGames = async (req, res) => {
  try {
    const games = await Game.getAll(false); // Only active games

    res.json({
      success: true,
      data: games
    });
  } catch (error) {
    console.error('Error getting games:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching games'
    });
  }
};

// Get all current results
const getResults = async (req, res) => {
  try {
    const results = await scraperService.getAllResults();

    res.json({
      success: true,
      data: results,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting results:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching results'
    });
  }
};

// Get result history for a specific game
const getResultHistory = async (req, res) => {
  try {
    const { game } = req.params;
    const { days = 7, userId } = req.query;

    // Free users get 7 days max, premium get 30 days
    let maxDays = 7;
    if (userId) {
      const isPremium = await User.isPremium(userId);
      if (isPremium) {
        maxDays = 30;
      }
    }

    const requestedDays = Math.min(parseInt(days), maxDays);
    const history = await Result.getHistory(game, requestedDays);

    res.json({
      success: true,
      game,
      days: requestedDays,
      data: history,
      isPremium: maxDays === 30
    });
  } catch (error) {
    console.error('Error getting result history:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching result history'
    });
  }
};

// Register user
const registerUser = async (req, res) => {
  try {
    const { fcmToken, deviceInfo, userId } = req.body;

    // Generate userId if not provided
    const finalUserId = userId || uuidv4();

    const user = await User.create(finalUserId, fcmToken, deviceInfo);

    res.json({
      success: true,
      userId: user.id,
      message: 'User registered successfully'
    });
  } catch (error) {
    console.error('Error registering user:', error);
    res.status(500).json({
      success: false,
      message: 'Error registering user'
    });
  }
};

// Get user status
const getUserStatus = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const isPremium = user.is_premium && user.expiry_date && new Date(user.expiry_date) > new Date();
    let daysLeft = 0;

    if (isPremium && user.expiry_date) {
      const now = new Date();
      const expiry = new Date(user.expiry_date);
      daysLeft = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24));
    }

    res.json({
      success: true,
      data: {
        userId: user.id,
        email: user.email,
        isPremium,
        expiryDate: user.expiry_date,
        daysLeft,
        subscriptionId: user.subscription_id
      }
    });
  } catch (error) {
    console.error('Error getting user status:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching user status'
    });
  }
};

// Update FCM token
const updateFcmToken = async (req, res) => {
  try {
    const { userId, fcmToken } = req.body;

    if (!userId || !fcmToken) {
      return res.status(400).json({
        success: false,
        message: 'userId and fcmToken are required'
      });
    }

    await User.updateFcmToken(userId, fcmToken);

    res.json({
      success: true,
      message: 'FCM token updated successfully'
    });
  } catch (error) {
    console.error('Error updating FCM token:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating FCM token'
    });
  }
};

module.exports = {
  getAllGames,
  getResults,
  getResultHistory,
  registerUser,
  getUserStatus,
  updateFcmToken
};
