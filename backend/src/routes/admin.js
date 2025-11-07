const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { adminAuth } = require('../middleware/auth');

// Login (no auth needed)
router.post('/login', adminController.login);

// All routes below require admin auth
router.use(adminAuth);

// Dashboard
router.get('/stats', adminController.getStatistics);
router.get('/revenue-chart', adminController.getRevenueChart);

// Users
router.get('/users', adminController.getUsers);
router.post('/user/:userId/extend-premium', adminController.extendPremium);
router.post('/user/:userId/deactivate', adminController.deactivatePremium);

// Predictions
router.post('/predictions/override', adminController.overridePrediction);
router.post('/predictions/generate', adminController.generatePredictions);

// Results
router.post('/results/manual-entry', adminController.manualResultEntry);
router.post('/results/bulk-add', adminController.bulkAddResults);

// Notifications
router.post('/notification/send', adminController.sendPushNotification);
router.get('/notifications/history', adminController.getNotificationHistory);

// Games Management
router.get('/games', adminController.getAllGames);
router.get('/games/:id', adminController.getGame);
router.post('/games', adminController.createGame);
router.put('/games/:id', adminController.updateGame);
router.delete('/games/:id', adminController.deleteGame);
router.post('/games/:id/toggle-active', adminController.toggleGameActive);
router.post('/games/:id/toggle-scraping', adminController.toggleGameScraping);

module.exports = router;
