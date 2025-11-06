const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Admin authentication middleware
const adminAuth = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (decoded.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin only.'
      });
    }

    req.admin = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }
};

// Check if user is premium
const checkPremium = async (req, res, next) => {
  try {
    const userId = req.query.userId || req.body.userId;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required'
      });
    }

    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Check if premium and not expired
    const isPremium = user.is_premium && user.expiry_date && new Date(user.expiry_date) > new Date();

    if (!isPremium) {
      return res.status(403).json({
        success: false,
        message: 'Premium subscription required',
        premiumRequired: true
      });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Premium check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error checking premium status'
    });
  }
};

// Optional premium check (doesn't block, just adds user info)
const optionalPremiumCheck = async (req, res, next) => {
  try {
    const userId = req.query.userId || req.body.userId;

    if (userId) {
      const user = await User.findById(userId);
      if (user) {
        const isPremium = user.is_premium && user.expiry_date && new Date(user.expiry_date) > new Date();
        req.user = user;
        req.isPremium = isPremium;
      }
    }

    next();
  } catch (error) {
    console.error('Optional premium check error:', error);
    next(); // Continue anyway
  }
};

module.exports = {
  adminAuth,
  checkPremium,
  optionalPremiumCheck
};
