const { pool } = require('../config/database');

class Payment {
  // Create payment record
  static async create(userId, subscriptionId, paymentId, orderId, amount, status) {
    try {
      const result = await pool.query(
        `INSERT INTO payments (user_id, subscription_id, payment_id, order_id, amount, status)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [userId, subscriptionId, paymentId, orderId, amount, status]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error creating payment:', error);
      throw error;
    }
  }

  // Get payment by ID
  static async findByPaymentId(paymentId) {
    try {
      const result = await pool.query(
        'SELECT * FROM payments WHERE payment_id = $1',
        [paymentId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error finding payment:', error);
      throw error;
    }
  }

  // Get all payments for a user
  static async getUserPayments(userId) {
    try {
      const result = await pool.query(
        'SELECT * FROM payments WHERE user_id = $1 ORDER BY created_at DESC',
        [userId]
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting user payments:', error);
      throw error;
    }
  }

  // Get payment statistics
  static async getStatistics() {
    try {
      const [totalRevenue, todayRevenue, thisMonthRevenue, totalPayments] = await Promise.all([
        pool.query('SELECT SUM(amount) FROM payments WHERE status = $1', ['success']),
        pool.query('SELECT SUM(amount) FROM payments WHERE status = $1 AND DATE(created_at) = CURRENT_DATE', ['success']),
        pool.query('SELECT SUM(amount) FROM payments WHERE status = $1 AND DATE_TRUNC(\'month\', created_at) = DATE_TRUNC(\'month\', CURRENT_DATE)', ['success']),
        pool.query('SELECT COUNT(*) FROM payments WHERE status = $1', ['success'])
      ]);

      return {
        totalRevenue: parseInt(totalRevenue.rows[0].sum || 0) / 100, // Convert paise to rupees
        todayRevenue: parseInt(todayRevenue.rows[0].sum || 0) / 100,
        thisMonthRevenue: parseInt(thisMonthRevenue.rows[0].sum || 0) / 100,
        totalPayments: parseInt(totalPayments.rows[0].count)
      };
    } catch (error) {
      console.error('Error getting payment statistics:', error);
      throw error;
    }
  }

  // Get recent payments (for admin)
  static async getRecent(limit = 20) {
    try {
      const result = await pool.query(
        `SELECT p.*, u.email
         FROM payments p
         LEFT JOIN users u ON p.user_id = u.id
         ORDER BY p.created_at DESC
         LIMIT $1`,
        [limit]
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting recent payments:', error);
      throw error;
    }
  }

  // Get revenue chart data (last 30 days)
  static async getRevenueChartData() {
    try {
      const result = await pool.query(
        `SELECT
           DATE(created_at) as date,
           SUM(amount) as revenue,
           COUNT(*) as count
         FROM payments
         WHERE status = 'success'
         AND created_at >= CURRENT_DATE - INTERVAL '30 days'
         GROUP BY DATE(created_at)
         ORDER BY date ASC`
      );

      return result.rows.map(row => ({
        date: row.date,
        revenue: parseInt(row.revenue) / 100,
        count: parseInt(row.count)
      }));
    } catch (error) {
      console.error('Error getting revenue chart data:', error);
      throw error;
    }
  }
}

module.exports = Payment;
