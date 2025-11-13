const express = require('express');
const router = express.Router();
const razorpayController = require('../controllers/razorpayController');

// Create Razorpay order
router.post('/create-order', razorpayController.createOrder);

// Verify payment signature
router.post('/verify-payment', razorpayController.verifyPayment);

// Get payment details
router.get('/payment/:payment_id', razorpayController.getPaymentDetails);

// Get all orders (for admin)
router.get('/orders', razorpayController.getAllOrders);

module.exports = router;
