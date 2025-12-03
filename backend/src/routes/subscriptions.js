const express = require('express');
const router = express.Router();
const { pool } = require('../config/database');
const PromoCode = require('../models/PromoCode');
const { createSubscription, cancelSubscription } = require('../config/razorpay');
const User = require('../models/User');

// Create Razorpay recurring subscription
router.post('/create-subscription', async (req, res) => {
  try {
    const { user_id, plan_type, promo_code } = req.body;

    if (!user_id || !plan_type) {
      return res.status(400).json({
        success: false,
        message: 'user_id and plan_type are required'
      });
    }

    // Map plan type to Razorpay plan ID
    const planMapping = {
      'monthly': {
        id: process.env.RAZORPAY_PLAN_MONTHLY || 'plan_monthly',
        price: 9900, // ₹99 in paise
        duration_days: 30
      },
      'quarterly': {
        id: process.env.RAZORPAY_PLAN_QUARTERLY || 'plan_quarterly',
        price: 24900, // ₹249 in paise
        duration_days: 90
      },
      'annual': {
        id: process.env.RAZORPAY_PLAN_YEARLY || 'plan_yearly',
        price: 99900, // ₹999 in paise
        duration_days: 365
      }
    };

    const selectedPlan = planMapping[plan_type];
    if (!selectedPlan) {
      return res.status(400).json({
        success: false,
        message: 'Invalid plan_type. Use: monthly, quarterly, or annual'
      });
    }

    // Check if plan ID is configured
    if (!selectedPlan.id) {
      console.error('⚠️ Razorpay plan ID not configured for', plan_type);
      return res.status(400).json({
        success: false,
        message: `This subscription plan is not available right now. Please contact support.`,
        userMessage: 'Subscription plan unavailable'
      });
    }

    console.log('✅ Using plan:', plan_type, 'with ID:', selectedPlan.id);

    // Validate promo code if provided
    let discount = 0;
    let validPromo = null;
    if (promo_code) {
      const validation = await PromoCode.validateCode(promo_code);
      if (validation.valid) {
        validPromo = validation.promoCode;
        discount = validPromo.discount_percent;
      }
    }

    // Calculate first payment amount (with discount if applicable)
    let firstPaymentAmount = selectedPlan.price;
    if (discount > 0) {
      firstPaymentAmount = Math.round(selectedPlan.price * (100 - discount) / 100);
    }

    // Create subscription via Razorpay
    // Use a valid email format (Razorpay requires email format)
    const customerEmail = `user_${user_id}@teerkhela.app`;
    const result = await createSubscription(
      selectedPlan.id,
      customerEmail,
      `User ${user_id}`
    );

    if (!result.success) {
      return res.status(500).json({
        success: false,
        message: result.error || 'Failed to create subscription'
      });
    }

    // Store subscription info in database
    await User.create(user_id, null, null);

    // Return subscription details
    res.json({
      success: true,
      subscription_id: result.subscriptionId,
      short_url: result.shortUrl,
      status: result.status,
      plan_type: plan_type,
      first_payment_amount: firstPaymentAmount,
      regular_amount: selectedPlan.price,
      discount_applied: discount,
      duration_days: selectedPlan.duration_days,
      message: discount > 0
        ? `First payment: ₹${firstPaymentAmount/100}. Future payments: ₹${selectedPlan.price/100}`
        : `Recurring payment: ₹${selectedPlan.price/100}`
    });

  } catch (error) {
    console.error('Error creating subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create subscription',
      error: error.message
    });
  }
});

// Cancel recurring subscription
router.post('/cancel-subscription', async (req, res) => {
  try {
    const { user_id, subscription_id } = req.body;

    if (!user_id || !subscription_id) {
      return res.status(400).json({
        success: false,
        message: 'user_id and subscription_id are required'
      });
    }

    // Verify user owns this subscription
    const user = await User.findById(user_id);
    if (!user || user.subscription_id !== subscription_id) {
      return res.status(403).json({
        success: false,
        message: 'Subscription not found for this user'
      });
    }

    // Cancel subscription on Razorpay (at cycle end = true means premium continues until expiry)
    const result = await cancelSubscription(subscription_id, true);

    if (!result.success) {
      return res.status(500).json({
        success: false,
        message: result.error || 'Failed to cancel subscription'
      });
    }

    res.json({
      success: true,
      message: 'Subscription cancelled successfully. You will have premium access until your current billing period ends.',
      expiry_date: user.expiry_date
    });

  } catch (error) {
    console.error('Error cancelling subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel subscription',
      error: error.message
    });
  }
});

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
