const {
  createSubscription,
  cancelSubscription,
  verifyWebhookSignature,
  getPayment
} = require('../config/razorpay');
const User = require('../models/User');
const Payment = require('../models/Payment');
const { sendNotificationToUser } = require('../config/firebase');

// ===========================================
// RAZORPAY SUBSCRIPTION METHODS (EXISTING)
// ===========================================

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

// ===========================================
// MANUAL PAYMENT SYSTEM (NEW)
// ===========================================

// Mock data storage
let paymentMethods = [
  {
    id: 1,
    name: 'PhonePe',
    type: 'upi',
    details: 'UPI ID: 9876543210@phonepe',
    qr_code_url: null,
    instructions: 'Scan QR or send to UPI ID. Make sure to enter your device ID in remarks.',
    is_active: true,
    created_at: new Date().toISOString()
  },
  {
    id: 2,
    name: 'Google Pay',
    type: 'upi',
    details: 'UPI ID: 9876543210@okaxis',
    qr_code_url: null,
    instructions: 'Send payment to the UPI ID and upload screenshot.',
    is_active: true,
    created_at: new Date().toISOString()
  },
  {
    id: 3,
    name: 'Bank Transfer',
    type: 'bank',
    details: 'Account: 1234567890, IFSC: SBIN0001234, Name: RioGold',
    qr_code_url: null,
    instructions: 'Transfer to bank account and upload the receipt.',
    is_active: true,
    created_at: new Date().toISOString()
  }
];

let paymentRequests = [
  {
    id: 1,
    user_id: 'device123',
    package_id: 1,
    package_name: 'Monthly Premium',
    amount: 49,
    payment_method_id: 1,
    payment_method_name: 'PhonePe',
    transaction_id: 'TXN123456789',
    user_name: 'Rajesh Kumar',
    proof_image_url: null,
    status: 'pending',
    rejection_reason: null,
    created_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    approved_at: null,
    approved_by: null,
    user_email: 'user@example.com'
  },
  {
    id: 2,
    user_id: 'device456',
    package_id: 2,
    package_name: 'Yearly Premium',
    amount: 499,
    payment_method_id: 2,
    payment_method_name: 'Google Pay',
    transaction_id: 'TXN987654321',
    user_name: 'Priya Sharma',
    proof_image_url: null,
    status: 'approved',
    rejection_reason: null,
    created_at: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    approved_at: new Date(Date.now() - 23 * 60 * 60 * 1000).toISOString(),
    approved_by: 'admin',
    user_email: 'user2@example.com'
  }
];

let paymentMethodIdCounter = 4;
let paymentRequestIdCounter = 3;

// Payment Methods Management
const getPaymentMethods = async (req, res) => {
  try {
    // Return only active payment methods for public endpoint
    const activeMethods = paymentMethods.filter(method => method.is_active);
    res.json({
      success: true,
      data: activeMethods
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching payment methods',
      error: error.message
    });
  }
};

const getAllPaymentMethods = async (req, res) => {
  try {
    // Return all payment methods for admin
    res.json({
      success: true,
      data: paymentMethods
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching payment methods',
      error: error.message
    });
  }
};

const createPaymentMethod = async (req, res) => {
  try {
    const { name, type, details, qr_code_url, instructions } = req.body;

    if (!name || !type || !details) {
      return res.status(400).json({
        success: false,
        message: 'Name, type, and details are required'
      });
    }

    const newMethod = {
      id: paymentMethodIdCounter++,
      name,
      type,
      details,
      qr_code_url: qr_code_url || null,
      instructions: instructions || '',
      is_active: true,
      created_at: new Date().toISOString()
    };

    paymentMethods.push(newMethod);

    res.status(201).json({
      success: true,
      message: 'Payment method created successfully',
      data: newMethod
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating payment method',
      error: error.message
    });
  }
};

const updatePaymentMethod = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, type, details, qr_code_url, instructions, is_active } = req.body;

    const methodIndex = paymentMethods.findIndex(m => m.id === parseInt(id));

    if (methodIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found'
      });
    }

    // Update fields if provided
    if (name) paymentMethods[methodIndex].name = name;
    if (type) paymentMethods[methodIndex].type = type;
    if (details) paymentMethods[methodIndex].details = details;
    if (qr_code_url !== undefined) paymentMethods[methodIndex].qr_code_url = qr_code_url;
    if (instructions !== undefined) paymentMethods[methodIndex].instructions = instructions;
    if (is_active !== undefined) paymentMethods[methodIndex].is_active = is_active;

    res.json({
      success: true,
      message: 'Payment method updated successfully',
      data: paymentMethods[methodIndex]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating payment method',
      error: error.message
    });
  }
};

const deletePaymentMethod = async (req, res) => {
  try {
    const { id } = req.params;

    const methodIndex = paymentMethods.findIndex(m => m.id === parseInt(id));

    if (methodIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found'
      });
    }

    // Soft delete by setting is_active to false
    paymentMethods[methodIndex].is_active = false;

    res.json({
      success: true,
      message: 'Payment method deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting payment method',
      error: error.message
    });
  }
};

const togglePaymentMethodActive = async (req, res) => {
  try {
    const { id } = req.params;

    const methodIndex = paymentMethods.findIndex(m => m.id === parseInt(id));

    if (methodIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Payment method not found'
      });
    }

    paymentMethods[methodIndex].is_active = !paymentMethods[methodIndex].is_active;

    res.json({
      success: true,
      message: `Payment method ${paymentMethods[methodIndex].is_active ? 'activated' : 'deactivated'} successfully`,
      data: paymentMethods[methodIndex]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error toggling payment method status',
      error: error.message
    });
  }
};

// Payment Requests Management
const getUserPayments = async (req, res) => {
  try {
    const { userId } = req.params;

    const userPayments = paymentRequests.filter(p => p.user_id === userId);

    res.json({
      success: true,
      data: userPayments
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching user payments',
      error: error.message
    });
  }
};

const createPaymentRequest = async (req, res) => {
  try {
    const {
      user_id,
      package_id,
      package_name,
      amount,
      payment_method_id,
      transaction_id,
      user_name,
      proof_image_url,
      user_email
    } = req.body;

    // Validate required fields (removed proof_image_url, added user_name)
    if (!user_id || !package_id || !amount || !payment_method_id || !transaction_id) {
      return res.status(400).json({
        success: false,
        message: 'user_id, package_id, amount, payment_method_id, and transaction_id are required'
      });
    }

    // Find payment method name
    const paymentMethod = paymentMethods.find(m => m.id === parseInt(payment_method_id));
    const payment_method_name = paymentMethod ? paymentMethod.name : 'Unknown';

    const newRequest = {
      id: paymentRequestIdCounter++,
      user_id,
      package_id: parseInt(package_id),
      package_name: package_name || 'Unknown Package',
      amount: parseFloat(amount),
      payment_method_id: parseInt(payment_method_id),
      payment_method_name,
      transaction_id,
      user_name: user_name || 'Unknown User',
      proof_image_url: proof_image_url || null,
      status: 'pending',
      rejection_reason: null,
      created_at: new Date().toISOString(),
      approved_at: null,
      approved_by: null,
      user_email: user_email || ''
    };

    paymentRequests.push(newRequest);

    res.status(201).json({
      success: true,
      message: 'Payment request submitted successfully. Please wait for admin approval.',
      data: newRequest
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating payment request',
      error: error.message
    });
  }
};

const getPendingPayments = async (req, res) => {
  try {
    const { status } = req.query;

    let filteredPayments = paymentRequests;

    if (status) {
      filteredPayments = paymentRequests.filter(p => p.status === status);
    }

    // Sort by created_at desc
    filteredPayments.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    res.json({
      success: true,
      data: filteredPayments
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching pending payments',
      error: error.message
    });
  }
};

const approvePayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { admin_name } = req.body;

    const paymentIndex = paymentRequests.findIndex(p => p.id === parseInt(id));

    if (paymentIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Payment request not found'
      });
    }

    if (paymentRequests[paymentIndex].status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Payment request is not pending'
      });
    }

    paymentRequests[paymentIndex].status = 'approved';
    paymentRequests[paymentIndex].approved_at = new Date().toISOString();
    paymentRequests[paymentIndex].approved_by = admin_name || 'admin';
    paymentRequests[paymentIndex].rejection_reason = null;

    // Here you would typically:
    // 1. Activate user's premium subscription
    // 2. Send notification to user
    // 3. Update user's subscription end date

    res.json({
      success: true,
      message: 'Payment approved successfully. User premium activated.',
      data: paymentRequests[paymentIndex]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error approving payment',
      error: error.message
    });
  }
};

const rejectPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { rejection_reason, admin_name } = req.body;

    if (!rejection_reason) {
      return res.status(400).json({
        success: false,
        message: 'Rejection reason is required'
      });
    }

    const paymentIndex = paymentRequests.findIndex(p => p.id === parseInt(id));

    if (paymentIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Payment request not found'
      });
    }

    if (paymentRequests[paymentIndex].status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Payment request is not pending'
      });
    }

    paymentRequests[paymentIndex].status = 'rejected';
    paymentRequests[paymentIndex].rejection_reason = rejection_reason;
    paymentRequests[paymentIndex].approved_at = new Date().toISOString();
    paymentRequests[paymentIndex].approved_by = admin_name || 'admin';

    // Here you would typically:
    // 1. Send notification to user with rejection reason
    // 2. Log the rejection

    res.json({
      success: true,
      message: 'Payment rejected successfully',
      data: paymentRequests[paymentIndex]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error rejecting payment',
      error: error.message
    });
  }
};

// Get payment statistics
const getPaymentStats = async (req, res) => {
  try {
    const stats = {
      total_requests: paymentRequests.length,
      pending: paymentRequests.filter(p => p.status === 'pending').length,
      approved: paymentRequests.filter(p => p.status === 'approved').length,
      rejected: paymentRequests.filter(p => p.status === 'rejected').length,
      total_amount_approved: paymentRequests
        .filter(p => p.status === 'approved')
        .reduce((sum, p) => sum + p.amount, 0)
    };

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching payment statistics',
      error: error.message
    });
  }
};

module.exports = {
  // Razorpay methods
  createPaymentSubscription,
  handleWebhook,
  cancelUserSubscription,

  // Manual payment methods - Payment Methods
  getPaymentMethods,
  getAllPaymentMethods,
  createPaymentMethod,
  updatePaymentMethod,
  deletePaymentMethod,
  togglePaymentMethodActive,

  // Manual payment methods - Payment Requests
  getUserPayments,
  createPaymentRequest,
  getPendingPayments,
  approvePayment,
  rejectPayment,
  getPaymentStats
};
