const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// ===========================================
// RAZORPAY SUBSCRIPTION ROUTES (EXISTING)
// ===========================================

// Create subscription
router.post('/create-subscription', paymentController.createPaymentSubscription);

// Razorpay webhook (no auth needed, signature verification inside)
router.post('/webhook', express.raw({ type: 'application/json' }), paymentController.handleWebhook);

// Cancel subscription
router.post('/cancel-subscription', paymentController.cancelUserSubscription);

// ===========================================
// MANUAL PAYMENT SYSTEM ROUTES (NEW)
// ===========================================

// Payment Methods (public - for user app)
router.get('/methods', paymentController.getPaymentMethods);

// Payment Requests (user)
router.get('/user/:userId', paymentController.getUserPayments);
router.post('/request', paymentController.createPaymentRequest);

// Admin routes - Payment Methods Management
router.get('/admin/methods', paymentController.getAllPaymentMethods);
router.post('/admin/methods', paymentController.createPaymentMethod);
router.put('/admin/methods/:id', paymentController.updatePaymentMethod);
router.delete('/admin/methods/:id', paymentController.deletePaymentMethod);
router.post('/admin/methods/:id/toggle', paymentController.togglePaymentMethodActive);

// Admin routes - Payment Approvals
router.get('/admin/pending', paymentController.getPendingPayments);
router.post('/admin/approve/:id', paymentController.approvePayment);
router.post('/admin/reject/:id', paymentController.rejectPayment);
router.get('/admin/stats', paymentController.getPaymentStats);

module.exports = router;
