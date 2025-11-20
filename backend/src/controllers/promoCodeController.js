const PromoCode = require('../models/PromoCode');

// Validate promo code (public endpoint for users)
exports.validatePromoCode = async (req, res) => {
  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({ error: 'Promo code is required' });
    }

    const validation = await PromoCode.validateCode(code);

    if (!validation.valid) {
      return res.status(404).json({ error: validation.message });
    }

    res.json({
      valid: true,
      code: validation.promoCode.code,
      discount_percent: validation.promoCode.discount_percent,
      description: validation.promoCode.description
    });
  } catch (error) {
    console.error('Error validating promo code:', error);
    res.status(500).json({ error: 'Failed to validate promo code' });
  }
};

// Get all promo codes (admin only)
exports.getAllPromoCodes = async (req, res) => {
  try {
    const promoCodes = await PromoCode.getAll();
    res.json(promoCodes);
  } catch (error) {
    console.error('Error fetching promo codes:', error);
    res.status(500).json({ error: 'Failed to fetch promo codes' });
  }
};

// Get promo code stats (admin only)
exports.getPromoCodeStats = async (req, res) => {
  try {
    const stats = await PromoCode.getStats();
    res.json(stats);
  } catch (error) {
    console.error('Error fetching promo code stats:', error);
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
};

// Create promo code (admin only)
exports.createPromoCode = async (req, res) => {
  try {
    const { code, discount_percent, max_uses, valid_until, description } = req.body;

    // Validation
    if (!code || !discount_percent) {
      return res.status(400).json({ error: 'Code and discount percent are required' });
    }

    if (discount_percent < 0 || discount_percent > 100) {
      return res.status(400).json({ error: 'Discount must be between 0 and 100' });
    }

    const promoCode = await PromoCode.create({
      code,
      discount_percent,
      max_uses,
      valid_until,
      description,
      created_by: req.adminUsername || 'admin'
    });

    res.status(201).json({
      message: 'Promo code created successfully',
      promoCode
    });
  } catch (error) {
    console.error('Error creating promo code:', error);

    if (error.code === '23505') { // Unique violation
      return res.status(409).json({ error: 'Promo code already exists' });
    }

    res.status(500).json({ error: 'Failed to create promo code' });
  }
};

// Update promo code (admin only)
exports.updatePromoCode = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const promoCode = await PromoCode.update(id, updates);

    if (!promoCode) {
      return res.status(404).json({ error: 'Promo code not found' });
    }

    res.json({
      message: 'Promo code updated successfully',
      promoCode
    });
  } catch (error) {
    console.error('Error updating promo code:', error);
    res.status(500).json({ error: 'Failed to update promo code' });
  }
};

// Delete promo code (admin only)
exports.deletePromoCode = async (req, res) => {
  try {
    const { id } = req.params;

    const promoCode = await PromoCode.delete(id);

    if (!promoCode) {
      return res.status(404).json({ error: 'Promo code not found' });
    }

    res.json({ message: 'Promo code deleted successfully' });
  } catch (error) {
    console.error('Error deleting promo code:', error);
    res.status(500).json({ error: 'Failed to delete promo code' });
  }
};

// Toggle promo code active status (admin only)
exports.togglePromoCode = async (req, res) => {
  try {
    const { id } = req.params;

    const promoCode = await PromoCode.toggleActive(id);

    if (!promoCode) {
      return res.status(404).json({ error: 'Promo code not found' });
    }

    res.json({
      message: `Promo code ${promoCode.is_active ? 'activated' : 'deactivated'} successfully`,
      promoCode
    });
  } catch (error) {
    console.error('Error toggling promo code:', error);
    res.status(500).json({ error: 'Failed to toggle promo code' });
  }
};
