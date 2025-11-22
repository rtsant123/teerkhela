const express = require('express');
const router = express.Router();
const publicController = require('../controllers/publicController');

// Games
router.get('/games', publicController.getAllGames);

// Results - Get all latest results
router.get('/results', publicController.getResults);                      // All results for home screen

// Results - 2 Endpoints per House
router.get('/results/:game/latest', publicController.getLatestResult);   // Latest result for specific house (date + FR + SR)
router.get('/results/:game/history', publicController.getResultHistory); // History for specific house (date + FR + SR)

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
