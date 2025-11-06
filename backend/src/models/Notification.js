const { pool } = require('../config/database');

class Notification {
  // Create notification record
  static async create(title, body, target, action, screen) {
    try {
      const result = await pool.query(
        `INSERT INTO notifications (title, body, target, action, screen)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [title, body, target, action, screen]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error creating notification:', error);
      throw error;
    }
  }

  // Update notification stats after sending
  static async updateStats(notificationId, sentCount, deliveredCount = 0) {
    try {
      const result = await pool.query(
        `UPDATE notifications
         SET sent_count = $1, delivered_count = $2, sent_at = CURRENT_TIMESTAMP
         WHERE id = $3
         RETURNING *`,
        [sentCount, deliveredCount, notificationId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error updating notification stats:', error);
      throw error;
    }
  }

  // Increment opened count
  static async incrementOpened(notificationId) {
    try {
      const result = await pool.query(
        `UPDATE notifications
         SET opened_count = opened_count + 1
         WHERE id = $1
         RETURNING *`,
        [notificationId]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error incrementing opened count:', error);
      throw error;
    }
  }

  // Get notification history
  static async getHistory(page = 1, limit = 20) {
    try {
      const offset = (page - 1) * limit;

      const [notifications, count] = await Promise.all([
        pool.query(
          `SELECT * FROM notifications
           ORDER BY created_at DESC
           LIMIT $1 OFFSET $2`,
          [limit, offset]
        ),
        pool.query('SELECT COUNT(*) FROM notifications')
      ]);

      return {
        notifications: notifications.rows,
        total: parseInt(count.rows[0].count),
        page,
        limit,
        totalPages: Math.ceil(count.rows[0].count / limit)
      };
    } catch (error) {
      console.error('Error getting notification history:', error);
      throw error;
    }
  }

  // Get notification by ID
  static async findById(id) {
    try {
      const result = await pool.query(
        'SELECT * FROM notifications WHERE id = $1',
        [id]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error finding notification:', error);
      throw error;
    }
  }

  // Get statistics
  static async getStatistics() {
    try {
      const [total, today, thisWeek] = await Promise.all([
        pool.query('SELECT COUNT(*), SUM(sent_count), SUM(delivered_count), SUM(opened_count) FROM notifications'),
        pool.query('SELECT COUNT(*), SUM(sent_count) FROM notifications WHERE DATE(created_at) = CURRENT_DATE'),
        pool.query('SELECT COUNT(*) FROM notifications WHERE created_at >= CURRENT_DATE - INTERVAL \'7 days\'')
      ]);

      return {
        totalNotifications: parseInt(total.rows[0].count),
        totalSent: parseInt(total.rows[0].sum || 0),
        totalDelivered: parseInt(total.rows[0].sum || 0),
        totalOpened: parseInt(total.rows[0].sum || 0),
        sentToday: parseInt(today.rows[0].sum || 0),
        thisWeek: parseInt(thisWeek.rows[0].count)
      };
    } catch (error) {
      console.error('Error getting notification statistics:', error);
      throw error;
    }
  }
}

module.exports = Notification;
