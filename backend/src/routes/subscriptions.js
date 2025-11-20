const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');
const PromoCode = require('../models/PromoCode');

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

    // Create or update user with premium status
    const upsertQuery = `
      INSERT INTO users (id, is_premium, subscription_id, expiry_date, created_at, updated_at)
      VALUES ($1, true, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (id) DO UPDATE
      SET is_premium = true,
          subscription_id = $2,
          expiry_date = $3,
          updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;

    const result = await pool.query(upsertQuery, [
      userId,
      subscriptionId,
      expiryDate
    ]);

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

// Verify Razorpay payment and activate premium (for promo code payments)
router.post('/razorpay-verify', async (req, res) => {
  try {
    const { payment_id, order_id, signature, user_id } = req.body;

    if (!payment_id || !user_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: payment_id, user_id'
      });
    }

    // Get payment details from Razorpay to extract notes (plan_id, duration_days, promo_code)
    const Razorpay = require('razorpay');
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET
    });

    let payment;
    try {
      payment = await razorpay.payments.fetch(payment_id);
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment ID'
      });
    }

    // Extract plan details from payment notes
    const notes = payment.notes || {};
    const durationDays = parseInt(notes.duration_days) || 30;
    const planId = notes.plan_id || 'unknown';
    const promoCode = notes.promo_code;

    // Calculate expiry date
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + durationDays);

    // Create or update user with premium status
    const upsertQuery = `
      INSERT INTO users (id, is_premium, subscription_id, expiry_date, created_at, updated_at)
      VALUES ($1, true, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (id) DO UPDATE
      SET is_premium = true,
          subscription_id = $2,
          expiry_date = $3,
          updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;

    const result = await pool.query(upsertQuery, [
      user_id,
      `razorpay_${payment_id}`,
      expiryDate
    ]);

    // Increment promo code usage if promo was used
    if (promoCode) {
      try {
        await PromoCode.incrementUsage(promoCode);
      } catch (err) {
        console.log('Promo code increment failed (non-critical):', err.message);
      }
    }

    console.log(`Premium activated via Razorpay payment ${payment_id} for user ${user_id}, expires: ${expiryDate}`);

    // Calculate days left
    const expiry = new Date(result.rows[0].expiry_date);
    const now = new Date();
    const daysLeft = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24));

    res.json({
      success: true,
      message: 'Payment verified and premium activated successfully',
      duration_days: durationDays,
      user: {
        userId: result.rows[0].id,
        isPremium: result.rows[0].is_premium,
        expiryDate: result.rows[0].expiry_date,
        daysLeft: daysLeft,
        subscriptionId: result.rows[0].subscription_id
      }
    });

  } catch (error) {
    console.error('Error verifying Razorpay payment:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to verify payment',
      error: error.message
    });
  }
});

// Activate premium with promo code (100% discount)
router.post('/activate-promo', async (req, res) => {
  try {
    const { user_id, plan_id, duration_days, promo_code } = req.body;

    if (!user_id || !plan_id || !duration_days || !promo_code) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: user_id, plan_id, duration_days, promo_code'
      });
    }

    // Validate promo code
    const validation = await PromoCode.validateCode(promo_code);
    if (!validation.valid) {
      return res.status(400).json({
        success: false,
        message: validation.message || 'Invalid promo code'
      });
    }

    // Check if promo code gives 100% discount
    if (validation.promoCode.discount_percent !== 100) {
      return res.status(400).json({
        success: false,
        message: 'This promo code does not provide 100% discount'
      });
    }

    // Calculate expiry date
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + duration_days);

    // Create or update user with premium status
    const upsertQuery = `
      INSERT INTO users (id, is_premium, subscription_id, expiry_date, created_at, updated_at)
      VALUES ($1, true, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (id) DO UPDATE
      SET is_premium = true,
          subscription_id = $2,
          expiry_date = $3,
          updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;

    const result = await pool.query(upsertQuery, [
      user_id,
      `promo_${promo_code}_${plan_id}`,
      expiryDate
    ]);

    // Increment promo code usage
    await PromoCode.incrementUsage(promo_code);

    console.log(`Premium activated with promo code ${promo_code} for user ${user_id}, expires: ${expiryDate}`);

    // Calculate days left
    const expiry = new Date(result.rows[0].expiry_date);
    const now = new Date();
    const daysLeft = Math.ceil((expiry - now) / (1000 * 60 * 60 * 24));

    res.json({
      success: true,
      message: 'Premium activated successfully with promo code',
      user: {
        userId: result.rows[0].id,
        isPremium: result.rows[0].is_premium,
        expiryDate: result.rows[0].expiry_date,
        daysLeft: daysLeft,
        subscriptionId: result.rows[0].subscription_id
      }
    });

  } catch (error) {
    console.error('Error activating premium with promo code:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to activate premium',
      error: error.message
    });
  }
});

module.exports = router;
