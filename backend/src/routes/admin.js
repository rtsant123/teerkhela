const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { adminAuth } = require('../middleware/auth');

// Login (no auth needed)
router.post('/login', adminController.login);

// Manual result entry (no auth - for simple admin app)
router.post('/results/manual-entry', adminController.manualResultEntry);

// Delete result (no auth - for simple admin app)
router.delete('/results/:game/:date', adminController.deleteResult);

// Bulk historical upload (no auth - for simple admin app)
router.post('/results/bulk-historical', adminController.bulkHistoricalUpload);

// Games Management (no auth - for simple admin app)
router.post('/games', adminController.createGame);
router.get('/games', adminController.getAllGames);
router.get('/games/:id', adminController.getGame);
router.put('/games/:id', adminController.updateGame);
router.delete('/games/:id', adminController.deleteGame);
router.delete('/games', adminController.deleteAllGames);  // Cleanup endpoint
router.post('/games/restore-defaults', adminController.restoreDefaultGames);  // Restore all houses
router.post('/games/:id/toggle-active', adminController.toggleGameActive);
router.post('/games/:id/toggle-scraping', adminController.toggleGameScraping);

// Subscription Packages Management (no auth - for simple admin app)
router.get('/subscription-packages', adminController.getSubscriptionPackages);
router.post('/subscription-packages', adminController.createSubscriptionPackage);
router.put('/subscription-packages/:id', adminController.updateSubscriptionPackage);
router.delete('/subscription-packages/:id', adminController.deleteSubscriptionPackage);

// FOMO Content Management (no auth - for simple admin app)
router.get('/fomo', adminController.getFomoContent);
router.post('/fomo', adminController.createFomoContent);
router.put('/fomo/:id', adminController.updateFomoContent);
router.delete('/fomo/:id', adminController.deleteFomoContent);

// Users Management (no auth - for simple admin app)
router.get('/users', adminController.getUsers);
router.delete('/user/:userId', adminController.deleteUser);

// Test route (no auth)
router.get('/test', (req, res) => {
  res.json({ success: true, message: 'Admin routes working without auth' });
});

// All routes below require admin auth
router.use(adminAuth);

// Dashboard
router.get('/stats', adminController.getStatistics);
router.get('/revenue-chart', adminController.getRevenueChart);

// Premium extension
router.post('/user/:userId/extend-premium', adminController.extendPremium);
router.post('/user/:userId/deactivate', adminController.deactivatePremium);

// Predictions
router.post('/predictions/override', adminController.overridePrediction);
router.post('/predictions/generate', adminController.generatePredictions);

// Results (authenticated)
router.post('/results/bulk-add', adminController.bulkAddResults);
router.post('/results/bulk-upload', adminController.bulkUploadResults); // Flexible format for past results

// Notifications
router.post('/notification/send', adminController.sendPushNotification);
router.get('/notifications/history', adminController.getNotificationHistory);

module.exports = router;
