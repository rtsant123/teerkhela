const express = require('express');
const router = express.Router();
const premiumController = require('../controllers/premiumController');
const { checkPremium, optionalPremiumCheck } = require('../middleware/auth');

// Predictions (premium only)
router.get('/predictions', checkPremium, premiumController.getPredictions);

// Dream interpretation (premium only)
router.post('/dream-interpret', checkPremium, premiumController.interpretDream);
router.get('/dream-history/:userId', checkPremium, premiumController.getDreamHistory);

// Common numbers (premium gets advanced features)
router.get('/common-numbers/:game', optionalPremiumCheck, premiumController.getCommonNumbers);

// Formula calculator (premium only)
router.post('/calculate-formula', checkPremium, premiumController.calculateFormula);

module.exports = router;
