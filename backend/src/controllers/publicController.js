const scraperService = require('../services/scraperService');
const User = require('../models/User');
const Result = require('../models/Result');
const Game = require('../models/Game');
const PredictionResult = require('../models/PredictionResult');
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
    const { days = 30 } = req.query;

    // Public API - allow 30 days for everyone
    const requestedDays = Math.min(parseInt(days), 30);
    const history = await Result.getHistory(game, requestedDays);

    res.json({
      success: true,
      game,
      days: requestedDays,
      count: history.length,
      data: history,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting result history:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching result history'
    });
  }
};

// Get today's results for all games
const getTodayResults = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const results = await Result.getByDate(today);

    res.json({
      success: true,
      date: today,
      count: results.length,
      data: results,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting today results:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching today results'
    });
  }
};

// Get latest result for specific game
const getLatestResult = async (req, res) => {
  try {
    const { game } = req.params;
    const result = await Result.getLatest(game);

    if (!result) {
      return res.json({
        success: true,
        game,
        data: null,
        message: 'No results found for this game'
      });
    }

    res.json({
      success: true,
      game,
      data: result,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting latest result:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching latest result'
    });
  }
};

// Get latest results for ALL games (simple: date, game, fr, sr)
const getLatestResults = async (req, res) => {
  try {
    const games = await Game.getAll(false); // Active games only
    const results = [];

    for (const game of games) {
      const latest = await Result.getLatest(game.name);
      if (latest) {
        results.push({
          game: latest.game,
          date: latest.date,
          fr: latest.fr,
          sr: latest.sr
        });
      }
    }

    res.json({
      success: true,
      count: results.length,
      data: results,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting latest results:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching latest results'
    });
  }
};

// Get today's result for specific game
const getGameTodayResult = async (req, res) => {
  try {
    const { game } = req.params;
    const today = new Date().toISOString().split('T')[0];
    const result = await Result.getByGameAndDate(game, today);

    res.json({
      success: true,
      game,
      date: today,
      data: result || { game, date: today, fr: null, sr: null },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting game today result:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching today result'
    });
  }
};

// Get all results for a game (no limit)
const getAllGameResults = async (req, res) => {
  try {
    const { game } = req.params;
    const { limit = 100 } = req.query;
    const results = await Result.getAllByGame(game, parseInt(limit));

    res.json({
      success: true,
      game,
      count: results.length,
      data: results,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting all game results:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching game results'
    });
  }
};

// Create test premium user
const createTestUser = async (req, res) => {
  try {
    const testUserId = 'test-premium-user';

    // Create or update test user
    const user = await User.create(testUserId, null, 'Test Device');

    // Make them premium for 30 days
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + 30);

    await User.updatePremium(testUserId, expiryDate);

    res.json({
      success: true,
      userId: testUserId,
      message: 'Test premium user created! Valid for 30 days.',
      isPremium: true,
      expiryDate: expiryDate.toISOString()
    });
  } catch (error) {
    console.error('Error creating test user:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating test user'
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

// Formula Calculator
const calculateFormulas = async (req, res) => {
  try {
    const { fr, sr } = req.body;

    if (fr === undefined && sr === undefined) {
      return res.status(400).json({
        success: false,
        message: 'At least one of FR or SR is required'
      });
    }

    const results = {};

    // House Formula (from FR)
    if (fr !== null && fr !== undefined) {
      const frNum = parseInt(fr);
      if (isNaN(frNum) || frNum < 0 || frNum > 99) {
        return res.status(400).json({
          success: false,
          message: 'FR must be a number between 0 and 99'
        });
      }

      // House: Sum of FR digits
      const digits = frNum.toString().split('');
      let house = digits.reduce((sum, d) => sum + parseInt(d), 0);

      // If sum is 10+, add digits again
      if (house >= 10) {
        const houseDigits = house.toString().split('');
        house = houseDigits.reduce((sum, d) => sum + parseInt(d), 0);
      }

      results.house = house;

      // FR related calculations
      results.fr = {
        value: frNum,
        tens: Math.floor(frNum / 10),
        ones: frNum % 10,
        sum: digits.reduce((sum, d) => sum + parseInt(d), 0),
        isEven: frNum % 2 === 0,
        isOdd: frNum % 2 === 1
      };
    }

    // Ending Formula (from SR)
    if (sr !== null && sr !== undefined) {
      const srNum = parseInt(sr);
      if (isNaN(srNum) || srNum < 0 || srNum > 99) {
        return res.status(400).json({
          success: false,
          message: 'SR must be a number between 0 and 99'
        });
      }

      // Ending: Last digit of SR
      results.ending = srNum % 10;

      // SR related calculations
      const srDigits = srNum.toString().split('');
      results.sr = {
        value: srNum,
        tens: Math.floor(srNum / 10),
        ones: srNum % 10,
        sum: srDigits.reduce((sum, d) => sum + parseInt(d), 0),
        isEven: srNum % 2 === 0,
        isOdd: srNum % 2 === 1
      };
    }

    // Combined formulas (if both FR and SR provided)
    if (fr !== null && fr !== undefined && sr !== null && sr !== undefined) {
      const frNum = parseInt(fr);
      const srNum = parseInt(sr);

      results.combined = {
        sum: frNum + srNum,
        difference: Math.abs(frNum - srNum),
        average: ((frNum + srNum) / 2).toFixed(1)
      };
    }

    res.json({
      success: true,
      data: results,
      formulas: {
        house: 'Sum of FR digits (if ≥10, add again)',
        ending: 'Last digit of SR',
        sum: 'FR + SR'
      }
    });
  } catch (error) {
    console.error('Error calculating formulas:', error);
    res.status(500).json({
      success: false,
      message: 'Error calculating formulas'
    });
  }
};

// Get overall accuracy (all games)
const getOverallAccuracy = async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const accuracy = await PredictionResult.getOverallAccuracy(days);
    const recentPredictions = await PredictionResult.getRecentPredictions(null, 10);
    const bestGames = await PredictionResult.getBestGames(days);

    res.json({
      success: true,
      days,
      accuracy,
      recentPredictions,
      bestGames
    });
  } catch (error) {
    console.error('Error getting overall accuracy:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching accuracy stats'
    });
  }
};

// Get accuracy for specific game
const getGameAccuracy = async (req, res) => {
  try {
    const { game } = req.params;
    const days = parseInt(req.query.days) || 30;

    const accuracy = await PredictionResult.getAccuracy(game, days);
    const recentPredictions = await PredictionResult.getRecentPredictions(game, 10);
    const trend = await PredictionResult.getAccuracyTrend(game, 7);

    res.json({
      success: true,
      game,
      days,
      accuracy,
      recentPredictions,
      trend
    });
  } catch (error) {
    console.error('Error getting game accuracy:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching game accuracy'
    });
  }
};

// Get recent predictions with results
const getRecentPredictions = async (req, res) => {
  try {
    const game = req.query.game || null;
    const limit = parseInt(req.query.limit) || 10;

    const predictions = await PredictionResult.getRecentPredictions(game, limit);

    res.json({
      success: true,
      predictions,
      count: predictions.length
    });
  } catch (error) {
    console.error('Error getting recent predictions:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching recent predictions'
    });
  }
};

module.exports = {
  getAllGames,
  getResults,
  getResultHistory,
  getTodayResults,
  getLatestResult,
  getLatestResults,
  getGameTodayResult,
  getAllGameResults,
  createTestUser,
  registerUser,
  getUserStatus,
  updateFcmToken,
  calculateFormulas,
  getOverallAccuracy,
  getGameAccuracy,
  getRecentPredictions
};
