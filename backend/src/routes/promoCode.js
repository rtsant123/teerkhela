const express = require('express');
const router = express.Router();
const { adminAuth } = require('../middleware/auth');
const promoCodeController = require('../controllers/promoCodeController');

// Public route - validate promo code
router.post('/promo-codes/validate', promoCodeController.validatePromoCode);

// Admin routes - manage promo codes (no auth - for simple admin app)
router.get('/admin/promo-codes', promoCodeController.getAllPromoCodes);
router.post('/admin/promo-codes', promoCodeController.createPromoCode);
router.put('/admin/promo-codes/:id', promoCodeController.updatePromoCode);
router.delete('/admin/promo-codes/:id', promoCodeController.deletePromoCode);
router.patch('/admin/promo-codes/:id/toggle', promoCodeController.togglePromoCode);
router.get('/admin/promo-codes/stats', promoCodeController.getPromoCodeStats);

module.exports = router;
