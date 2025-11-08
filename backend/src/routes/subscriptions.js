const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');

// Activate test subscription
router.post('/activate-test', async (req, res) => {
  try {
    const { userId, subscriptionId, expiryDate, isTest } = req.body;

    if (!userId || !subscriptionId || !expiryDate) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: userId, subscriptionId, expiryDate'
      });
    }

    // Update user with premium status
    const updateQuery = `
      UPDATE users
      SET is_premium = true,
          subscription_id = $1,
          expiry_date = $2,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $3
      RETURNING *
    `;

    const result = await pool.query(updateQuery, [
      subscriptionId,
      expiryDate,
      userId
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    console.log(`Test subscription activated for user ${userId}, expires: ${expiryDate}`);

    // Calculate days left
    const expiry = new Date(result.rows[0].expiry_date);
    const now = new Date();
    const daysLeft = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24));

    res.json({
      success: true,
      message: 'Test subscription activated successfully',
      user: {
        userId: result.rows[0].id,
        isPremium: result.rows[0].is_premium,
        expiryDate: result.rows[0].expiry_date,
        daysLeft: daysLeft,
        subscriptionId: result.rows[0].subscription_id
      }
    });

  } catch (error) {
    console.error('Error activating test subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to activate test subscription',
      error: error.message
    });
  }
});

module.exports = router;
