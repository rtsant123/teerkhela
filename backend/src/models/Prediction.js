const { pool } = require('../config/database');

class Prediction {
  // Save or update prediction
  static async upsert(game, date, frNumbers, srNumbers, analysis, confidence) {
    try {
      const result = await pool.query(
        `INSERT INTO predictions (game, date, fr_numbers, sr_numbers, analysis, confidence)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (game, date)
         DO UPDATE SET
           fr_numbers = EXCLUDED.fr_numbers,
           sr_numbers = EXCLUDED.sr_numbers,
           analysis = EXCLUDED.analysis,
           confidence = EXCLUDED.confidence,
           posted_at = CURRENT_TIMESTAMP
         RETURNING *`,
        [game, date, frNumbers, srNumbers, analysis, confidence]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error upserting prediction:', error);
      throw error;
    }
  }

  // Get today's predictions for all games
  static async getTodayPredictions() {
    try {
      const today = new Date().toISOString().split('T')[0];
      const result = await pool.query(
        'SELECT * FROM predictions WHERE date = $1 ORDER BY game',
        [today]
      );

      // Format into object with game as key
      const predictions = {};
      result.rows.forEach(row => {
        predictions[row.game] = {
          game: row.game,
          date: row.date,
          fr: row.fr_numbers,
          sr: row.sr_numbers,
          analysis: row.analysis,
          confidence: row.confidence,
          postedAt: row.posted_at
        };
      });

      return predictions;
    } catch (error) {
      console.error('Error getting today predictions:', error);
      throw error;
    }
  }

  // Get prediction for specific game and date
  static async getByGameAndDate(game, date) {
    try {
      const result = await pool.query(
        'SELECT * FROM predictions WHERE game = $1 AND date = $2',
        [game, date]
      );

      if (result.rows.length === 0) return null;

      const row = result.rows[0];
      return {
        game: row.game,
        date: row.date,
        fr: row.fr_numbers,
        sr: row.sr_numbers,
        analysis: row.analysis,
        confidence: row.confidence,
        postedAt: row.posted_at
      };
    } catch (error) {
      console.error('Error getting prediction:', error);
      throw error;
    }
  }

  // Get prediction history
  static async getHistory(game, days = 7) {
    try {
      const result = await pool.query(
        `SELECT * FROM predictions
         WHERE game = $1
         AND date >= CURRENT_DATE - INTERVAL '${days} days'
         ORDER BY date DESC`,
        [game]
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting prediction history:', error);
      throw error;
    }
  }

  // Delete old predictions
  static async deleteOldPredictions(daysToKeep = 30) {
    try {
      const result = await pool.query(
        `DELETE FROM predictions
         WHERE date < CURRENT_DATE - INTERVAL '${daysToKeep} days'`,
      );
      console.log(`Deleted ${result.rowCount} old predictions`);
      return result.rowCount;
    } catch (error) {
      console.error('Error deleting old predictions:', error);
      throw error;
    }
  }
}

module.exports = Prediction;
