const Razorpay = require('razorpay');
const crypto = require('crypto');

// Initialize Razorpay instance
const razorpayInstance = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET
});

// Create subscription
const createSubscription = async (planId, customerEmail, customerName = '') => {
  try {
    const subscription = await razorpayInstance.subscriptions.create({
      plan_id: planId,
      customer_notify: 1,
      quantity: 1,
      total_count: 12, // 12 months (can be changed or made unlimited)
      notes: {
        customer_email: customerEmail,
        customer_name: customerName
      }
    });

    console.log('✅ Razorpay subscription created:', subscription.id);
    return {
      success: true,
      subscriptionId: subscription.id,
      status: subscription.status,
      shortUrl: subscription.short_url
    };
  } catch (error) {
    console.error('❌ Error creating Razorpay subscription:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

// Fetch subscription details
const getSubscription = async (subscriptionId) => {
  try {
    const subscription = await razorpayInstance.subscriptions.fetch(subscriptionId);
    return {
      success: true,
      subscription
    };
  } catch (error) {
    console.error('❌ Error fetching subscription:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

// Cancel subscription
const cancelSubscription = async (subscriptionId, cancelAtCycleEnd = false) => {
  try {
    const subscription = await razorpayInstance.subscriptions.cancel(
      subscriptionId,
      cancelAtCycleEnd
    );

    console.log('✅ Subscription cancelled:', subscriptionId);
    return {
      success: true,
      subscription
    };
  } catch (error) {
    console.error('❌ Error cancelling subscription:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

// Verify webhook signature
const verifyWebhookSignature = (webhookBody, webhookSignature) => {
  try {
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_WEBHOOK_SECRET)
      .update(JSON.stringify(webhookBody))
      .digest('hex');

    return expectedSignature === webhookSignature;
  } catch (error) {
    console.error('❌ Error verifying webhook signature:', error);
    return false;
  }
};

// Fetch payment details
const getPayment = async (paymentId) => {
  try {
    const payment = await razorpayInstance.payments.fetch(paymentId);
    return {
      success: true,
      payment
    };
  } catch (error) {
    console.error('❌ Error fetching payment:', error);
    return {
      success: false,
      error: error.message
    };
  }
};

module.exports = {
  razorpayInstance,
  createSubscription,
  getSubscription,
  cancelSubscription,
  verifyWebhookSignature,
  getPayment
};
