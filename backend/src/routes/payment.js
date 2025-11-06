const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// Create subscription
router.post('/create-subscription', paymentController.createPaymentSubscription);

// Razorpay webhook (no auth needed, signature verification inside)
router.post('/webhook', express.raw({ type: 'application/json' }), paymentController.handleWebhook);

// Cancel subscription
router.post('/cancel-subscription', paymentController.cancelUserSubscription);

module.exports = router;
