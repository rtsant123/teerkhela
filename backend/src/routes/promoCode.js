const express = require('express');
const router = express.Router();
const { adminAuth } = require('../middleware/auth');
const promoCodeController = require('../controllers/promoCodeController');

// Public route - validate promo code
router.post('/promo-codes/validate', promoCodeController.validatePromoCode);

// Admin routes - manage promo codes (no auth - for simple admin app)
// Note: These are mounted at /api in server.js, so full paths are /api/promo-codes-admin/*
router.get('/promo-codes-admin', promoCodeController.getAllPromoCodes);
router.post('/promo-codes-admin', promoCodeController.createPromoCode);
router.put('/promo-codes-admin/:id', promoCodeController.updatePromoCode);
router.delete('/promo-codes-admin/:id', promoCodeController.deletePromoCode);
router.patch('/promo-codes-admin/:id/toggle', promoCodeController.togglePromoCode);
router.get('/promo-codes-admin/stats', promoCodeController.getPromoCodeStats);

module.exports = router;
