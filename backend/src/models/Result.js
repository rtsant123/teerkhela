const { pool } = require('../config/database');

class Result {
  // Save or update result
  static async upsert(game, date, fr, sr, declaredTime, isAuto = true) {
    try {
      const result = await pool.query(
        `INSERT INTO results (game, date, fr, sr, declared_time, is_auto)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (game, date)
         DO UPDATE SET
           fr = COALESCE(EXCLUDED.fr, results.fr),
           sr = COALESCE(EXCLUDED.sr, results.sr),
           declared_time = COALESCE(EXCLUDED.declared_time, results.declared_time),
           is_auto = EXCLUDED.is_auto
         RETURNING *`,
        [game, date, fr, sr, declaredTime, isAuto]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error upserting result:', error);
      throw error;
    }
  }

  // Get today's results for all games
  static async getTodayResults() {
    try {
      const today = new Date().toISOString().split('T')[0];
      const result = await pool.query(
        'SELECT * FROM results WHERE date = $1 ORDER BY game',
        [today]
      );

      // Format into object with game as key
      const results = {};
      result.rows.forEach(row => {
        results[row.game] = {
          game: row.game,
          date: row.date,
          fr: row.fr,
          sr: row.sr,
          declaredTime: row.declared_time,
          isAuto: row.is_auto
        };
      });

      return results;
    } catch (error) {
      console.error('Error getting today results:', error);
      throw error;
    }
  }

  // Get result history for a game
  static async getHistory(game, days = 7) {
    try {
      const result = await pool.query(
        `SELECT * FROM results
         WHERE game = $1
         AND date >= CURRENT_DATE - INTERVAL '${days} days'
         ORDER BY date DESC`,
        [game]
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting result history:', error);
      throw error;
    }
  }

  // Get specific result by game and date
  static async getByGameAndDate(game, date) {
    try {
      const result = await pool.query(
        'SELECT * FROM results WHERE game = $1 AND date = $2',
        [game, date]
      );
      return result.rows[0];
    } catch (error) {
      console.error('Error getting result:', error);
      throw error;
    }
  }

  // Get common numbers (hot/cold) for a game
  static async getCommonNumbers(game, days = 30) {
    try {
      const result = await pool.query(
        `SELECT fr, sr FROM results
         WHERE game = $1
         AND date >= CURRENT_DATE - INTERVAL '${days} days'
         AND fr IS NOT NULL
         AND sr IS NOT NULL
         ORDER BY date DESC`,
        [game]
      );

      // Count frequency of each number
      const frequency = {};
      result.rows.forEach(row => {
        if (row.fr !== null) {
          frequency[row.fr] = (frequency[row.fr] || 0) + 1;
        }
        if (row.sr !== null) {
          frequency[row.sr] = (frequency[row.sr] || 0) + 1;
        }
      });

      // Sort by frequency
      const sorted = Object.entries(frequency)
        .map(([num, count]) => ({ number: parseInt(num), count }))
        .sort((a, b) => b.count - a.count);

      const hotNumbers = sorted.slice(0, 10);
      const coldNumbers = sorted.slice(-10).reverse();

      // Find common pairs
      const pairs = {};
      result.rows.forEach(row => {
        if (row.fr !== null && row.sr !== null) {
          const pairKey = `${row.fr}-${row.sr}`;
          pairs[pairKey] = (pairs[pairKey] || 0) + 1;
        }
      });

      const commonPairs = Object.entries(pairs)
        .map(([pair, count]) => ({ pair, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 5);

      return {
        hotNumbers,
        coldNumbers,
        commonPairs,
        totalResults: result.rows.length
      };
    } catch (error) {
      console.error('Error getting common numbers:', error);
      throw error;
    }
  }

  // Get day-wise analysis (which day has most wins)
  static async getDayWiseAnalysis(game, days = 30) {
    try {
      const result = await pool.query(
        `SELECT
           EXTRACT(DOW FROM date) as day_of_week,
           COUNT(*) as count,
           AVG(fr) as avg_fr,
           AVG(sr) as avg_sr
         FROM results
         WHERE game = $1
         AND date >= CURRENT_DATE - INTERVAL '${days} days'
         AND fr IS NOT NULL
         GROUP BY day_of_week
         ORDER BY day_of_week`,
        [game]
      );

      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

      return result.rows.map(row => ({
        day: dayNames[row.day_of_week],
        count: parseInt(row.count),
        avgFr: parseFloat(row.avg_fr).toFixed(2),
        avgSr: parseFloat(row.avg_sr).toFixed(2)
      }));
    } catch (error) {
      console.error('Error getting day-wise analysis:', error);
      throw error;
    }
  }

  // Delete old results (cleanup)
  static async deleteOldResults(daysToKeep = 90) {
    try {
      const result = await pool.query(
        `DELETE FROM results
         WHERE date < CURRENT_DATE - INTERVAL '${daysToKeep} days'`,
      );
      console.log(`Deleted ${result.rowCount} old results`);
      return result.rowCount;
    } catch (error) {
      console.error('Error deleting old results:', error);
      throw error;
    }
  }
}

module.exports = Result;
