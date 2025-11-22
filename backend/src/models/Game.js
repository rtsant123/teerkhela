const { pool } = require('../config/database');

class Game {
  // Get all games
  static async getAll(includeInactive = false) {
    try {
      const query = includeInactive
        ? 'SELECT * FROM games ORDER BY display_order ASC, name ASC'
        : 'SELECT * FROM games WHERE is_active = true ORDER BY display_order ASC, name ASC';

      const result = await pool.query(query);
      return result.rows;
    } catch (error) {
      console.error('Error getting all games:', error);
      throw error;
    }
  }

  // Get games for scraping
  static async getActiveScrapableGames() {
    try {
      const result = await pool.query(
        'SELECT * FROM games WHERE is_active = true AND scrape_enabled = true ORDER BY display_order ASC'
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting scrapable games:', error);
      throw error;
    }
  }

  // Get single game by name
  static async getByName(name) {
    try {
      const result = await pool.query(
        'SELECT * FROM games WHERE name = $1',
        [name]
      );
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error getting game by name:', error);
      throw error;
    }
  }

  // Get single game by id
  static async getById(id) {
    try {
      const result = await pool.query(
        'SELECT * FROM games WHERE id = $1',
        [id]
      );
      return result.rows[0] || null;
    } catch (error) {
      console.error('Error getting game by id:', error);
      throw error;
    }
  }

  // Create new game
  static async create(gameData) {
    try {
      const {
        name,
        display_name,
        region,
        scrape_url,
        is_active = true,
        scrape_enabled = false,
        fr_time,
        sr_time,
        display_order = 0
      } = gameData;

      const result = await pool.query(
        `INSERT INTO games (name, display_name, region, scrape_url, is_active, scrape_enabled, fr_time, sr_time, display_order)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
         RETURNING *`,
        [name, display_name, region, scrape_url, is_active, scrape_enabled, fr_time, sr_time, display_order]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error creating game:', error);
      throw error;
    }
  }

  // Update game
  static async update(id, gameData) {
    try {
      const {
        display_name,
        region,
        scrape_url,
        is_active,
        scrape_enabled,
        fr_time,
        sr_time,
        display_order
      } = gameData;

      const result = await pool.query(
        `UPDATE games
         SET display_name = COALESCE($1, display_name),
             region = COALESCE($2, region),
             scrape_url = COALESCE($3, scrape_url),
             is_active = COALESCE($4, is_active),
             scrape_enabled = COALESCE($5, scrape_enabled),
             fr_time = COALESCE($6, fr_time),
             sr_time = COALESCE($7, sr_time),
             display_order = COALESCE($8, display_order),
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $9
         RETURNING *`,
        [display_name, region, scrape_url, is_active, scrape_enabled, fr_time, sr_time, display_order, id]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error updating game:', error);
      throw error;
    }
  }

  // Delete game (soft delete - set is_active to false)
  static async delete(id) {
    try {
      const result = await pool.query(
        'UPDATE games SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
        [id]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error deleting game:', error);
      throw error;
    }
  }

  // Hard delete game (permanently remove)
  static async hardDelete(id) {
    try {
      const result = await pool.query(
        'DELETE FROM games WHERE id = $1 RETURNING *',
        [id]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error hard deleting game:', error);
      throw error;
    }
  }

  // Hard delete ALL games (cleanup)
  static async hardDeleteAll() {
    try {
      const result = await pool.query('DELETE FROM games RETURNING *');
      return result.rows;
    } catch (error) {
      console.error('Error deleting all games:', error);
      throw error;
    }
  }

  // Toggle game active status
  static async toggleActive(id) {
    try {
      const result = await pool.query(
        'UPDATE games SET is_active = NOT is_active, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
        [id]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error toggling game active status:', error);
      throw error;
    }
  }

  // Toggle scraping enabled
  static async toggleScraping(id) {
    try {
      const result = await pool.query(
        'UPDATE games SET scrape_enabled = NOT scrape_enabled, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
        [id]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error toggling game scraping:', error);
      throw error;
    }
  }

  // Get game statistics
  static async getStats(gameName) {
    try {
      const result = await pool.query(
        `SELECT
          COUNT(*) as total_results,
          COUNT(CASE WHEN fr IS NOT NULL THEN 1 END) as fr_count,
          COUNT(CASE WHEN sr IS NOT NULL THEN 1 END) as sr_count,
          MAX(date) as last_result_date
         FROM results
         WHERE game = $1`,
        [gameName]
      );

      return result.rows[0];
    } catch (error) {
      console.error('Error getting game stats:', error);
      throw error;
    }
  }
}

module.exports = Game;
