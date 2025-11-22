const express = require('express');
const router = express.Router();
const publicController = require('../controllers/publicController');

// Games
router.get('/games', publicController.getAllGames);

// Results - Comprehensive API
router.get('/results', publicController.getResults);                    // All results for today (filter with ?game=xxx)
router.get('/results/today', publicController.getTodayResults);         // All games today's results
router.get('/results/latest/:game', publicController.getLatestResult);  // Latest result for specific game
router.get('/results/:game/today', publicController.getGameTodayResult);// Today's result for specific game
router.get('/results/:game/history', publicController.getResultHistory);// 30 days history
router.get('/results/:game/all', publicController.getAllGameResults);   // All results for a game

// User
router.get('/create-test-user', publicController.createTestUser);
router.post('/user/register', publicController.registerUser);
router.get('/user/:userId/status', publicController.getUserStatus);
router.post('/user/fcm-token', publicController.updateFcmToken);

// Formula Calculator
router.post('/formulas/calculate', publicController.calculateFormulas);

// Prediction Accuracy (Public for transparency)
router.get('/accuracy/overall', publicController.getOverallAccuracy);
router.get('/accuracy/:game', publicController.getGameAccuracy);
router.get('/accuracy/recent-predictions', publicController.getRecentPredictions);

module.exports = router;
