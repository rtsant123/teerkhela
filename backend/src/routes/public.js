const express = require('express');
const router = express.Router();
const publicController = require('../controllers/publicController');

// Games
router.get('/games', publicController.getAllGames);

// Results
router.get('/results', publicController.getResults);
router.get('/results/:game/history', publicController.getResultHistory);

// User
router.post('/user/register', publicController.registerUser);
router.get('/user/:userId/status', publicController.getUserStatus);
router.post('/user/fcm-token', publicController.updateFcmToken);

// Formula Calculator
router.post('/formulas/calculate', publicController.calculateFormulas);

module.exports = router;
