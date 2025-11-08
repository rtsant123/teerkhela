const express = require('express');
const router = express.Router();
const Referral = require('../models/Referral');

// Get user's referral code and stats
router.get('/:userId/code', async (req, res) => {
  try {
    const { userId } = req.params;
    const stats = await Referral.getStats(userId);

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error getting referral code:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching referral code'
    });
  }
});

// Apply referral code (when new user signs up)
router.post('/apply', async (req, res) => {
  try {
    const { userId, referralCode } = req.body;

    if (!userId || !referralCode) {
      return res.status(400).json({
        success: false,
        message: 'userId and referralCode are required'
      });
    }

    const referral = await Referral.applyCode(userId, referralCode);

    res.json({
      success: true,
      message: 'Referral code applied successfully!',
      referral
    });
  } catch (error) {
    console.error('Error applying referral code:', error);
    res.status(400).json({
      success: false,
      message: error.message || 'Error applying referral code'
    });
  }
});

// Claim referral rewards
router.post('/:userId/claim', async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await Referral.claimRewards(userId);

    if (result.rewardDays === 0) {
      return res.json({
        success: true,
        message: 'No unclaimed rewards',
        data: result
      });
    }

    res.json({
      success: true,
      message: `🎉 Claimed ${result.rewardDays} days of premium! (${result.referralsCount} referrals)`,
      data: result
    });
  } catch (error) {
    console.error('Error claiming rewards:', error);
    res.status(500).json({
      success: false,
      message: 'Error claiming rewards'
    });
  }
});

// Get referral leaderboard
router.get('/leaderboard', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const leaderboard = await Referral.getLeaderboard(limit);

    res.json({
      success: true,
      data: leaderboard
    });
  } catch (error) {
    console.error('Error getting leaderboard:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching leaderboard'
    });
  }
});

module.exports = router;
