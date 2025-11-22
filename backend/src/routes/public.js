const express = require('express');
const router = express.Router();
const publicController = require('../controllers/publicController');

// Games
router.get('/games', publicController.getAllGames);

// Results - Simple 2 Endpoint API
router.get('/results/latest', publicController.getLatestResults);       // Latest results for all games (date + FR + SR)
router.get('/results/:game/history', publicController.getResultHistory);// History for specific game (date + FR + SR)

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
