const db = require('../config/database');

class PromoCode {
  // Create promo codes table
  static async createTable() {
    const query = `
      CREATE TABLE IF NOT EXISTS promo_codes (
        id SERIAL PRIMARY KEY,
        code VARCHAR(50) UNIQUE NOT NULL,
        discount_percent INTEGER NOT NULL CHECK (discount_percent >= 0 AND discount_percent <= 100),
        max_uses INTEGER DEFAULT NULL,
        current_uses INTEGER DEFAULT 0,
        valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        valid_until TIMESTAMP DEFAULT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        description TEXT,
        created_by VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    try {
      await db.query(query);
      console.log('✓ Promo codes table created/verified');
    } catch (error) {
      console.error('Error creating promo codes table:', error);
      throw error;
    }
  }

  // Create promo code
  static async create(codeData) {
    const { code, discount_percent, max_uses, valid_until, description, created_by } = codeData;

    const query = `
      INSERT INTO promo_codes (code, discount_percent, max_uses, valid_until, description, created_by)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;

    const result = await db.query(query, [
      code.toUpperCase(),
      discount_percent,
      max_uses || null,
      valid_until || null,
      description || null,
      created_by || 'admin'
    ]);

    return result.rows[0];
  }

  // Validate and get promo code
  static async validateCode(code) {
    const query = `
      SELECT * FROM promo_codes
      WHERE UPPER(code) = UPPER($1)
      AND is_active = TRUE
      AND (valid_until IS NULL OR valid_until > CURRENT_TIMESTAMP)
      AND (max_uses IS NULL OR current_uses < max_uses)
    `;

    const result = await db.query(query, [code]);

    if (result.rows.length === 0) {
      return { valid: false, message: 'Invalid or expired promo code' };
    }

    return { valid: true, promoCode: result.rows[0] };
  }

  // Increment usage count
  static async incrementUsage(code) {
    const query = `
      UPDATE promo_codes
      SET current_uses = current_uses + 1,
          updated_at = CURRENT_TIMESTAMP
      WHERE UPPER(code) = UPPER($1)
      RETURNING *
    `;

    const result = await db.query(query, [code]);
    return result.rows[0];
  }

  // Get all promo codes
  static async getAll() {
    const query = `
      SELECT id, code, discount_percent, max_uses, current_uses,
             valid_from, valid_until, is_active, description, created_by, created_at
      FROM promo_codes
      ORDER BY created_at DESC
    `;

    const result = await db.query(query);
    return result.rows;
  }

  // Get by ID
  static async getById(id) {
    const query = 'SELECT * FROM promo_codes WHERE id = $1';
    const result = await db.query(query, [id]);
    return result.rows[0];
  }

  // Update promo code
  static async update(id, updates) {
    const { code, discount_percent, max_uses, valid_until, description, is_active } = updates;

    const query = `
      UPDATE promo_codes
      SET code = COALESCE($1, code),
          discount_percent = COALESCE($2, discount_percent),
          max_uses = COALESCE($3, max_uses),
          valid_until = COALESCE($4, valid_until),
          description = COALESCE($5, description),
          is_active = COALESCE($6, is_active),
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $7
      RETURNING *
    `;

    const result = await db.query(query, [
      code?.toUpperCase(),
      discount_percent,
      max_uses,
      valid_until,
      description,
      is_active,
      id
    ]);

    return result.rows[0];
  }

  // Delete promo code
  static async delete(id) {
    const query = 'DELETE FROM promo_codes WHERE id = $1 RETURNING *';
    const result = await db.query(query, [id]);
    return result.rows[0];
  }

  // Toggle active status
  static async toggleActive(id) {
    const query = `
      UPDATE promo_codes
      SET is_active = NOT is_active,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;

    const result = await db.query(query, [id]);
    return result.rows[0];
  }

  // Get usage stats
  static async getStats() {
    const query = `
      SELECT
        COUNT(*) as total_codes,
        COUNT(CASE WHEN is_active = TRUE THEN 1 END) as active_codes,
        SUM(current_uses) as total_uses,
        AVG(discount_percent) as avg_discount
      FROM promo_codes
    `;

    const result = await db.query(query);
    return result.rows[0];
  }
}

module.exports = PromoCode;
