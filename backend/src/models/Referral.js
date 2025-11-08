const pool = require('../config/database');

class Referral {
  // Create referrals table
  static async createTable() {
    const query = `
      CREATE TABLE IF NOT EXISTS referrals (
        id SERIAL PRIMARY KEY,
        referrer_id VARCHAR(255) NOT NULL,
        referred_id VARCHAR(255) NOT NULL,
        referral_code VARCHAR(20) NOT NULL,
        reward_days INTEGER DEFAULT 5,
        is_claimed BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        claimed_at TIMESTAMP,
        FOREIGN KEY (referrer_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (referred_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(referred_id)
      );

      CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id);
      CREATE INDEX IF NOT EXISTS idx_referrals_code ON referrals(referral_code);

      CREATE TABLE IF NOT EXISTS referral_codes (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL UNIQUE,
        code VARCHAR(20) NOT NULL UNIQUE,
        total_referrals INTEGER DEFAULT 0,
        total_rewards_days INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );

      CREATE INDEX IF NOT EXISTS idx_referral_codes_user ON referral_codes(user_id);
      CREATE INDEX IF NOT EXISTS idx_referral_codes_code ON referral_codes(code);
    `;

    try {
      await pool.query(query);
      console.log('✅ Referrals tables created successfully');
    } catch (error) {
      console.error('❌ Error creating referrals table:', error);
      throw error;
    }
  }

  // Generate unique referral code for user
  static async generateCode(userId) {
    // Generate random 8-character code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code;
    let exists = true;

    while (exists) {
      code = '';
      for (let i = 0; i < 8; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      // Check if code already exists
      const checkQuery = `SELECT EXISTS(SELECT 1 FROM referral_codes WHERE code = $1)`;
      const result = await pool.query(checkQuery, [code]);
      exists = result.rows[0].exists;
    }

    // Insert code
    const insertQuery = `
      INSERT INTO referral_codes (user_id, code)
      VALUES ($1, $2)
      ON CONFLICT (user_id) DO UPDATE SET code = $2
      RETURNING *
    `;

    try {
      const result = await pool.query(insertQuery, [userId, code]);
      return result.rows[0];
    } catch (error) {
      console.error('Error generating referral code:', error);
      throw error;
    }
  }

  // Get user's referral code
  static async getCode(userId) {
    const query = `SELECT * FROM referral_codes WHERE user_id = $1`;

    try {
      const result = await pool.query(query, [userId]);

      if (result.rows.length === 0) {
        // Generate new code if doesn't exist
        return await this.generateCode(userId);
      }

      return result.rows[0];
    } catch (error) {
      console.error('Error getting referral code:', error);
      throw error;
    }
  }

  // Apply referral code (when new user signs up with a code)
  static async applyCode(newUserId, referralCode) {
    // Find the referrer
    const findQuery = `SELECT * FROM referral_codes WHERE code = $1`;

    try {
      const codeResult = await pool.query(findQuery, [referralCode.toUpperCase()]);

      if (codeResult.rows.length === 0) {
        throw new Error('Invalid referral code');
      }

      const referrerCode = codeResult.rows[0];
      const referrerId = referrerCode.user_id;

      // Can't refer yourself
      if (referrerId === newUserId) {
        throw new Error('Cannot use your own referral code');
      }

      // Check if user already used a referral code
      const checkQuery = `SELECT EXISTS(SELECT 1 FROM referrals WHERE referred_id = $1)`;
      const checkResult = await pool.query(checkQuery, [newUserId]);

      if (checkResult.rows[0].exists) {
        throw new Error('You have already used a referral code');
      }

      // Create referral record
      const insertQuery = `
        INSERT INTO referrals (referrer_id, referred_id, referral_code, reward_days)
        VALUES ($1, $2, $3, $4)
        RETURNING *
      `;

      const referralResult = await pool.query(insertQuery, [referrerId, newUserId, referralCode.toUpperCase(), 5]);

      // Update referrer's code stats
      const updateQuery = `
        UPDATE referral_codes
        SET total_referrals = total_referrals + 1,
            total_rewards_days = total_rewards_days + 5
        WHERE user_id = $1
      `;

      await pool.query(updateQuery, [referrerId]);

      return referralResult.rows[0];
    } catch (error) {
      console.error('Error applying referral code:', error);
      throw error;
    }
  }

  // Claim referral rewards (add days to premium)
  static async claimRewards(userId) {
    const User = require('./User');

    // Get all unclaimed referrals
    const getQuery = `
      SELECT * FROM referrals
      WHERE referrer_id = $1 AND is_claimed = false
    `;

    try {
      const result = await pool.query(getQuery, [userId]);
      const unclaimedReferrals = result.rows;

      if (unclaimedReferrals.length === 0) {
        return { rewardDays: 0, referralsCount: 0 };
      }

      // Calculate total reward days
      const totalRewardDays = unclaimedReferrals.reduce((sum, ref) => sum + ref.reward_days, 0);

      // Extend user's premium
      const user = await User.getById(userId);
      let expiryDate;

      if (user.is_premium && user.expiry_date) {
        // Extend existing premium
        expiryDate = new Date(user.expiry_date);
        expiryDate.setDate(expiryDate.getDate() + totalRewardDays);
      } else {
        // Give new premium
        expiryDate = new Date();
        expiryDate.setDate(expiryDate.getDate() + totalRewardDays);
      }

      await User.updatePremium(userId, expiryDate);

      // Mark referrals as claimed
      const updateQuery = `
        UPDATE referrals
        SET is_claimed = true, claimed_at = CURRENT_TIMESTAMP
        WHERE referrer_id = $1 AND is_claimed = false
      `;

      await pool.query(updateQuery, [userId]);

      return {
        rewardDays: totalRewardDays,
        referralsCount: unclaimedReferrals.length,
        newExpiryDate: expiryDate
      };
    } catch (error) {
      console.error('Error claiming rewards:', error);
      throw error;
    }
  }

  // Get referral stats for user
  static async getStats(userId) {
    const query = `
      SELECT
        rc.code,
        rc.total_referrals,
        rc.total_rewards_days,
        COUNT(r.id) FILTER (WHERE r.is_claimed = false) as unclaimed_count,
        COALESCE(SUM(r.reward_days) FILTER (WHERE r.is_claimed = false), 0) as unclaimed_days
      FROM referral_codes rc
      LEFT JOIN referrals r ON rc.user_id = r.referrer_id
      WHERE rc.user_id = $1
      GROUP BY rc.code, rc.total_referrals, rc.total_rewards_days
    `;

    try {
      const result = await pool.query(query, [userId]);

      if (result.rows.length === 0) {
        // Generate code if doesn't exist
        const newCode = await this.generateCode(userId);
        return {
          code: newCode.code,
          total_referrals: 0,
          total_rewards_days: 0,
          unclaimed_count: 0,
          unclaimed_days: 0
        };
      }

      return result.rows[0];
    } catch (error) {
      console.error('Error getting referral stats:', error);
      throw error;
    }
  }

  // Get referral leaderboard
  static async getLeaderboard(limit = 10) {
    const query = `
      SELECT
        rc.user_id,
        rc.code,
        rc.total_referrals,
        rc.total_rewards_days
      FROM referral_codes rc
      WHERE rc.total_referrals > 0
      ORDER BY rc.total_referrals DESC
      LIMIT $1
    `;

    try {
      const result = await pool.query(query, [limit]);
      return result.rows;
    } catch (error) {
      console.error('Error getting leaderboard:', error);
      throw error;
    }
  }
}

module.exports = Referral;
