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

// Results
router.post('/results/manual-entry', adminController.manualResultEntry);

// Notifications
router.post('/notification/send', adminController.sendPushNotification);
router.get('/notifications/history', adminController.getNotificationHistory);

module.exports = router;
