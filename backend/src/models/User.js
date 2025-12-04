const { pool } = require('../config/database');

class User {
  // Create new user
  static async create(userId, fcmToken, deviceInfo) {
    try {
      const result = await pool.query(
        `INSERT INTO users (id, fcm_token, device_info)
         VALUES ($1, $2, $3)
         ON CONFLICT (id) DO UPDATE
         SET fcm_token = $2, device_info = $3, updated_at = CURRENT_TIMESTAMP
         RETURNING *`,
        [userId, fcmToken, deviceInfo]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error creating user:', error);
      throw error;
    }
  }

  // Get user by ID
  static async findById(userId) {
    try {
      const result = await pool.query(
        'SELECT * FROM users WHERE id = $1',
        [userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error finding user:', error);
      throw error;
    }
  }

  // Update user premium status
  static async updatePremiumStatus(userId, isPremium, expiryDate, subscriptionId) {
    try {
      const result = await pool.query(
        `UPDATE users
         SET is_premium = $1, expiry_date = $2, subscription_id = $3, updated_at = CURRENT_TIMESTAMP
         WHERE id = $4
         RETURNING *`,
        [isPremium, expiryDate, subscriptionId, userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error updating premium status:', error);
      throw error;
    }
  }

  // Update user subscription status
  static async updateSubscription(userId, subscriptionId, expiryDate, isPremium) {
    try {
      const result = await pool.query(
        `UPDATE users
         SET is_premium = $1, expiry_date = $2, subscription_id = $3, updated_at = CURRENT_TIMESTAMP
         WHERE id = $4
         RETURNING *`,
        [isPremium, expiryDate, subscriptionId, userId]
      );
      // If no user was updated, it means the user does not exist. Create the user.
      if (result.rows.length === 0) {
        return await pool.query(
            `INSERT INTO users (id, fcm_token, device_info, is_premium, expiry_date, subscription_id)
             VALUES ($1, null, null, $2, $3, $4)
             RETURNING *`,
            [userId, isPremium, expiryDate, subscriptionId]
        );
      }
      return result.rows[0];
    } catch (error) {
      console.error('Error updating subscription status:', error);
      throw error;
    }
  }

  // Update user email
  static async updateEmail(userId, email) {
    try {
      const result = await pool.query(
        `UPDATE users SET email = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *`,
        [email, userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error updating email:', error);
      throw error;
    }
  }

  // Update FCM token
  static async updateFcmToken(userId, fcmToken) {
    try {
      const result = await pool.query(
        `UPDATE users SET fcm_token = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *`,
        [fcmToken, userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error updating FCM token:', error);
      throw error;
    }
  }

  // Check if user is premium
  static async isPremium(userId) {
    try {
      const user = await this.findById(userId);
      if (!user) return false;

      // Check if premium and not expired
      if (user.is_premium && user.expiry_date) {
        const now = new Date();
        const expiry = new Date(user.expiry_date);
        return expiry > now;
      }

      return false;
    } catch (error) {
      console.error('Error checking premium status:', error);
      return false;
    }
  }

  // Get all premium users
  static async getAllPremiumUsers() {
    try {
      const result = await pool.query(
        `SELECT * FROM users
         WHERE is_premium = true
         AND expiry_date > CURRENT_TIMESTAMP
         AND fcm_token IS NOT NULL`
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting premium users:', error);
      throw error;
    }
  }

  // Get all users (for admin)
  static async getAll(page = 1, limit = 50, filter = 'all') {
    try {
      const offset = (page - 1) * limit;
      let query = 'SELECT * FROM users';
      let countQuery = 'SELECT COUNT(*) FROM users';

      if (filter === 'premium') {
        query += ' WHERE is_premium = true AND expiry_date > CURRENT_TIMESTAMP';
        countQuery += ' WHERE is_premium = true AND expiry_date > CURRENT_TIMESTAMP';
      } else if (filter === 'free') {
        query += ' WHERE is_premium = false OR expiry_date <= CURRENT_TIMESTAMP OR expiry_date IS NULL';
        countQuery += ' WHERE is_premium = false OR expiry_date <= CURRENT_TIMESTAMP OR expiry_date IS NULL';
      } else if (filter === 'expired') {
        query += ' WHERE is_premium = true AND expiry_date <= CURRENT_TIMESTAMP';
        countQuery += ' WHERE is_premium = true AND expiry_date <= CURRENT_TIMESTAMP';
      }

      query += ' ORDER BY created_at DESC LIMIT $1 OFFSET $2';

      const [users, count] = await Promise.all([
        pool.query(query, [limit, offset]),
        pool.query(countQuery)
      ]);

      return {
        users: users.rows,
        total: parseInt(count.rows[0].count),
        page,
        limit,
        totalPages: Math.ceil(count.rows[0].count / limit)
      };
    } catch (error) {
      console.error('Error getting all users:', error);
      throw error;
    }
  }

  // Extend premium days
  static async extendPremium(userId, days) {
    try {
      const user = await this.findById(userId);
      if (!user) throw new Error('User not found');

      let newExpiryDate;
      if (user.expiry_date && new Date(user.expiry_date) > new Date()) {
        // If still premium, add to existing expiry
        newExpiryDate = new Date(user.expiry_date);
        newExpiryDate.setDate(newExpiryDate.getDate() + days);
      } else {
        // If expired or never premium, start from now
        newExpiryDate = new Date();
        newExpiryDate.setDate(newExpiryDate.getDate() + days);
      }

      const result = await pool.query(
        `UPDATE users
         SET is_premium = true, expiry_date = $1, updated_at = CURRENT_TIMESTAMP
         WHERE id = $2
         RETURNING *`,
        [newExpiryDate, userId]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error extending premium:', error);
      throw error;
    }
  }

  // Deactivate premium
  static async deactivatePremium(userId) {
    try {
      const result = await pool.query(
        `UPDATE users
         SET is_premium = false, updated_at = CURRENT_TIMESTAMP
         WHERE id = $1
         RETURNING *`,
        [userId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error deactivating premium:', error);
      throw error;
    }
  }

  // Get user statistics (for admin dashboard)
  static async getStatistics() {
    try {
      const [totalUsers, premiumUsers, newToday, activeSubscriptions] = await Promise.all([
        pool.query('SELECT COUNT(*) FROM users'),
        pool.query('SELECT COUNT(*) FROM users WHERE is_premium = true AND expiry_date > CURRENT_TIMESTAMP'),
        pool.query('SELECT COUNT(*) FROM users WHERE DATE(created_at) = CURRENT_DATE'),
        pool.query('SELECT COUNT(*) FROM users WHERE is_premium = true AND expiry_date > CURRENT_TIMESTAMP AND subscription_id IS NOT NULL')
      ]);

      return {
        totalUsers: parseInt(totalUsers.rows[0].count),
        premiumUsers: parseInt(premiumUsers.rows[0].count),
        newToday: parseInt(newToday.rows[0].count),
        activeSubscriptions: parseInt(activeSubscriptions.rows[0].count)
      };
    } catch (error) {
      console.error('Error getting statistics:', error);
      throw error;
    }
  }

  // Delete user
  static async delete(userId) {
    try {
      await pool.query('DELETE FROM users WHERE id = $1', [userId]);
      return { success: true };
    } catch (error) {
      console.error('Error deleting user:', error);
      throw error;
    }
  }
}

module.exports = User;
