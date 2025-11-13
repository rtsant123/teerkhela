const Razorpay = require('razorpay');
const crypto = require('crypto');

// Initialize Razorpay instance
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET
});

// Store for orders (in production, use database)
let orders = [];
let orderIdCounter = 1;

// Create Razorpay Order
const createOrder = async (req, res) => {
  try {
    const { amount, user_id, package_id, package_name } = req.body;

    // Validate required fields
    if (!amount || !user_id || !package_id) {
      return res.status(400).json({
        success: false,
        message: 'amount, user_id, and package_id are required'
      });
    }

    // Amount should be in paise (multiply by 100)
    const amountInPaise = Math.round(parseFloat(amount) * 100);

    // Create Razorpay order
    const options = {
      amount: amountInPaise,
      currency: 'INR',
      receipt: `rcpt_${Date.now()}`,
      notes: {
        user_id: user_id.toString(),
        package_id: package_id.toString(),
        package_name: package_name || 'Unknown Package'
      }
    };

    const razorpayOrder = await razorpay.orders.create(options);

    // Store order in memory
    const order = {
      id: orderIdCounter++,
      razorpay_order_id: razorpayOrder.id,
      user_id,
      package_id,
      package_name: package_name || 'Unknown Package',
      amount: parseFloat(amount),
      currency: 'INR',
      status: 'created',
      created_at: new Date().toISOString(),
      razorpay_response: razorpayOrder
    };

    orders.push(order);

    res.status(200).json({
      success: true,
      message: 'Order created successfully',
      data: {
        order_id: razorpayOrder.id,
        amount: razorpayOrder.amount,
        currency: razorpayOrder.currency,
        key_id: process.env.RAZORPAY_KEY_ID
      }
    });
  } catch (error) {
    console.error('Razorpay order creation error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating Razorpay order',
      error: error.message
    });
  }
};

// Verify Payment Signature
const verifyPayment = async (req, res) => {
  try {
    const {
      razorpay_order_id,
      razorpay_payment_id,
      razorpay_signature,
      user_id,
      user_name,
      user_email
    } = req.body;

    // Validate required fields
    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        success: false,
        message: 'razorpay_order_id, razorpay_payment_id, and razorpay_signature are required'
      });
    }

    // Verify signature
    const body = razorpay_order_id + '|' + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body.toString())
      .digest('hex');

    const isAuthentic = expectedSignature === razorpay_signature;

    if (!isAuthentic) {
      return res.status(400).json({
        success: false,
        message: 'Invalid payment signature'
      });
    }

    // Find order
    const order = orders.find(o => o.razorpay_order_id === razorpay_order_id);

    if (order) {
      // Update order status
      order.status = 'paid';
      order.razorpay_payment_id = razorpay_payment_id;
      order.razorpay_signature = razorpay_signature;
      order.paid_at = new Date().toISOString();
      order.user_name = user_name || 'Unknown User';
      order.user_email = user_email || '';
    }

    // Fetch payment details from Razorpay
    let paymentDetails = null;
    try {
      paymentDetails = await razorpay.payments.fetch(razorpay_payment_id);
    } catch (error) {
      console.error('Error fetching payment details:', error);
    }

    res.status(200).json({
      success: true,
      message: 'Payment verified successfully',
      data: {
        order_id: razorpay_order_id,
        payment_id: razorpay_payment_id,
        status: 'success',
        payment_details: paymentDetails
      }
    });
  } catch (error) {
    console.error('Payment verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Error verifying payment',
      error: error.message
    });
  }
};

// Get payment details
const getPaymentDetails = async (req, res) => {
  try {
    const { payment_id } = req.params;

    if (!payment_id) {
      return res.status(400).json({
        success: false,
        message: 'payment_id is required'
      });
    }

    const payment = await razorpay.payments.fetch(payment_id);

    res.status(200).json({
      success: true,
      data: payment
    });
  } catch (error) {
    console.error('Error fetching payment details:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching payment details',
      error: error.message
    });
  }
};

// Get all orders (for admin)
const getAllOrders = (req, res) => {
  try {
    res.status(200).json({
      success: true,
      data: orders.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching orders',
      error: error.message
    });
  }
};

module.exports = {
  createOrder,
  verifyPayment,
  getPaymentDetails,
  getAllOrders
};
