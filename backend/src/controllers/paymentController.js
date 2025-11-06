const {
  createSubscription,
  cancelSubscription,
  verifyWebhookSignature,
  getPayment
} = require('../config/razorpay');
const User = require('../models/User');
const Payment = require('../models/Payment');
const { sendNotificationToUser } = require('../config/firebase');

// Create subscription
const createPaymentSubscription = async (req, res) => {
  try {
    const { userId, email, planId } = req.body;

    if (!userId || !email) {
      return res.status(400).json({
        success: false,
        message: 'userId and email are required'
      });
    }

    const finalPlanId = planId || process.env.RAZORPAY_PLAN_ID;

    // Create subscription via Razorpay
    const result = await createSubscription(finalPlanId, email);

    if (!result.success) {
      return res.status(500).json({
        success: false,
        message: result.error || 'Error creating subscription'
      });
    }

    // Update user email
    await User.updateEmail(userId, email);

    res.json({
      success: true,
      subscriptionId: result.subscriptionId,
      status: result.status,
      shortUrl: result.shortUrl
    });
  } catch (error) {
    console.error('Error creating subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating subscription'
    });
  }
};

// Razorpay webhook
const handleWebhook = async (req, res) => {
  try {
    const webhookSignature = req.headers['x-razorpay-signature'];
    const webhookBody = req.body;

    // Verify signature
    const isValid = verifyWebhookSignature(webhookBody, webhookSignature);

    if (!isValid) {
      console.error('Invalid webhook signature');
      return res.status(400).json({
        success: false,
        message: 'Invalid signature'
      });
    }

    const event = webhookBody.event;
    const payload = webhookBody.payload;

    console.log(`📥 Received webhook: ${event}`);

    // Handle different webhook events
    switch (event) {
      case 'subscription.charged':
        await handleSubscriptionCharged(payload);
        break;

      case 'subscription.activated':
        await handleSubscriptionActivated(payload);
        break;

      case 'subscription.cancelled':
        await handleSubscriptionCancelled(payload);
        break;

      case 'subscription.completed':
        await handleSubscriptionCompleted(payload);
        break;

      case 'payment.failed':
        await handlePaymentFailed(payload);
        break;

      default:
        console.log(`Unhandled webhook event: ${event}`);
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({
      success: false,
      message: 'Webhook processing error'
    });
  }
};

// Handle subscription charged (payment successful)
const handleSubscriptionCharged = async (payload) => {
  try {
    const subscription = payload.subscription.entity;
    const payment = payload.payment.entity;

    console.log(`💰 Subscription charged: ${subscription.id}`);

    // Find user by subscription ID or email
    const email = subscription.notes?.customer_email;
    const userResult = await User.pool.query(
      'SELECT * FROM users WHERE subscription_id = $1 OR email = $2',
      [subscription.id, email]
    );

    if (userResult.rows.length === 0) {
      console.error('User not found for subscription:', subscription.id);
      return;
    }

    const user = userResult.rows[0];

    // Calculate expiry date (30 days from now)
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + 30);

    // Update user premium status
    await User.updatePremiumStatus(user.id, true, expiryDate, subscription.id);

    // Record payment
    await Payment.create(
      user.id,
      subscription.id,
      payment.id,
      payment.order_id,
      payment.amount,
      'success'
    );

    // Send welcome notification (only for first payment)
    if (subscription.paid_count === 1) {
      if (user.fcm_token) {
        await sendNotificationToUser(
          user.fcm_token,
          '🎉 Welcome to Premium!',
          'Your premium subscription is now active. Enjoy all features!',
          { screen: 'predictions' }
        );
      }
    } else {
      // Renewal notification
      if (user.fcm_token) {
        await sendNotificationToUser(
          user.fcm_token,
          '✅ Subscription Renewed',
          'Your premium subscription has been renewed successfully.',
          { screen: 'profile' }
        );
      }
    }

    console.log(`✅ Premium activated for user ${user.id}`);
  } catch (error) {
    console.error('Error handling subscription charged:', error);
  }
};

// Handle subscription activated
const handleSubscriptionActivated = async (payload) => {
  try {
    const subscription = payload.subscription.entity;
    console.log(`✅ Subscription activated: ${subscription.id}`);
  } catch (error) {
    console.error('Error handling subscription activated:', error);
  }
};

// Handle subscription cancelled
const handleSubscriptionCancelled = async (payload) => {
  try {
    const subscription = payload.subscription.entity;
    console.log(`❌ Subscription cancelled: ${subscription.id}`);

    // Find user
    const userResult = await User.pool.query(
      'SELECT * FROM users WHERE subscription_id = $1',
      [subscription.id]
    );

    if (userResult.rows.length > 0) {
      const user = userResult.rows[0];

      // Don't deactivate immediately, let it expire naturally
      console.log(`User ${user.id} subscription cancelled, will expire on ${user.expiry_date}`);

      // Send notification
      if (user.fcm_token) {
        await sendNotificationToUser(
          user.fcm_token,
          '⚠️ Subscription Cancelled',
          'Your subscription has been cancelled. You can still use premium features until the end of your billing period.',
          { screen: 'profile' }
        );
      }
    }
  } catch (error) {
    console.error('Error handling subscription cancelled:', error);
  }
};

// Handle subscription completed (all cycles done)
const handleSubscriptionCompleted = async (payload) => {
  try {
    const subscription = payload.subscription.entity;
    console.log(`✅ Subscription completed: ${subscription.id}`);

    // Deactivate premium
    const userResult = await User.pool.query(
      'SELECT * FROM users WHERE subscription_id = $1',
      [subscription.id]
    );

    if (userResult.rows.length > 0) {
      const user = userResult.rows[0];
      await User.deactivatePremium(user.id);
      console.log(`Premium deactivated for user ${user.id}`);
    }
  } catch (error) {
    console.error('Error handling subscription completed:', error);
  }
};

// Handle payment failed
const handlePaymentFailed = async (payload) => {
  try {
    const payment = payload.payment.entity;
    console.log(`❌ Payment failed: ${payment.id}`);

    // Send notification to user
    // Find user by order ID or subscription ID
    // This is implementation-specific based on your data
  } catch (error) {
    console.error('Error handling payment failed:', error);
  }
};

// Cancel subscription
const cancelUserSubscription = async (req, res) => {
  try {
    const { userId, subscriptionId } = req.body;

    if (!userId || !subscriptionId) {
      return res.status(400).json({
        success: false,
        message: 'userId and subscriptionId are required'
      });
    }

    // Verify user owns this subscription
    const user = await User.findById(userId);
    if (!user || user.subscription_id !== subscriptionId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    // Cancel on Razorpay
    const result = await cancelSubscription(subscriptionId, false);

    if (!result.success) {
      return res.status(500).json({
        success: false,
        message: result.error || 'Error cancelling subscription'
      });
    }

    res.json({
      success: true,
      message: 'Subscription cancelled successfully'
    });
  } catch (error) {
    console.error('Error cancelling subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Error cancelling subscription'
    });
  }
};

module.exports = {
  createPaymentSubscription,
  handleWebhook,
  cancelUserSubscription
};
