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

// AI Common Numbers (premium only) - 10 numbers daily
router.get('/ai-common-numbers/:game?', checkPremium, premiumController.getAICommonNumbers);

// AI Lucky Numbers (premium only) - 10 numbers daily
router.get('/ai-lucky-numbers/:game?', checkPremium, premiumController.getAILuckyNumbers);

// AI Hit Numbers (premium only) - shows what actually hit
router.get('/ai-hit-numbers/:game?', checkPremium, premiumController.getAIHitNumbers);

module.exports = router;
