const pool = require('../config/database');

class ForumPost {
  // Create forum posts table
  static async createTable() {
    const query = `
      CREATE TABLE IF NOT EXISTS forum_posts (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        username VARCHAR(100) DEFAULT 'Anonymous',
        game VARCHAR(50) NOT NULL,
        prediction_type VARCHAR(10) NOT NULL CHECK (prediction_type IN ('FR', 'SR')),
        numbers INTEGER[] NOT NULL,
        confidence INTEGER DEFAULT 50 CHECK (confidence >= 0 AND confidence <= 100),
        description TEXT,
        likes INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      );

      CREATE INDEX IF NOT EXISTS idx_forum_game ON forum_posts(game);
      CREATE INDEX IF NOT EXISTS idx_forum_created ON forum_posts(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_forum_user ON forum_posts(user_id);

      CREATE TABLE IF NOT EXISTS forum_likes (
        id SERIAL PRIMARY KEY,
        post_id INTEGER NOT NULL,
        user_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (post_id) REFERENCES forum_posts(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
        UNIQUE(post_id, user_id)
      );

      CREATE INDEX IF NOT EXISTS idx_likes_post ON forum_likes(post_id);
      CREATE INDEX IF NOT EXISTS idx_likes_user ON forum_likes(user_id);
    `;

    try {
      await pool.query(query);
      console.log('✅ Forum posts tables created successfully');
    } catch (error) {
      console.error('❌ Error creating forum_posts table:', error);
      throw error;
    }
  }

  // Create new post
  static async create(userId, username, game, predictionType, numbers, confidence, description) {
    const query = `
      INSERT INTO forum_posts (user_id, username, game, prediction_type, numbers, confidence, description)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

    try {
      const result = await pool.query(query, [
        userId,
        username || 'Anonymous',
        game,
        predictionType,
        numbers,
        confidence || 50,
        description
      ]);
      return result.rows[0];
    } catch (error) {
      console.error('Error creating forum post:', error);
      throw error;
    }
  }

  // Get posts for a specific game
  static async getByGame(game, limit = 50) {
    const query = `
      SELECT
        fp.*,
        COALESCE(
          (SELECT COUNT(*) FROM forum_likes WHERE post_id = fp.id),
          0
        ) as likes
      FROM forum_posts fp
      WHERE fp.game = $1
      ORDER BY fp.created_at DESC
      LIMIT $2
    `;

    try {
      const result = await pool.query(query, [game, limit]);
      return result.rows;
    } catch (error) {
      console.error('Error getting forum posts by game:', error);
      throw error;
    }
  }

  // Get all posts (latest)
  static async getLatest(limit = 100) {
    const query = `
      SELECT
        fp.*,
        COALESCE(
          (SELECT COUNT(*) FROM forum_likes WHERE post_id = fp.id),
          0
        ) as likes
      FROM forum_posts fp
      ORDER BY fp.created_at DESC
      LIMIT $1
    `;

    try {
      const result = await pool.query(query, [limit]);
      return result.rows;
    } catch (error) {
      console.error('Error getting latest forum posts:', error);
      throw error;
    }
  }

  // Get posts by user
  static async getByUser(userId, limit = 50) {
    const query = `
      SELECT
        fp.*,
        COALESCE(
          (SELECT COUNT(*) FROM forum_likes WHERE post_id = fp.id),
          0
        ) as likes
      FROM forum_posts fp
      WHERE fp.user_id = $1
      ORDER BY fp.created_at DESC
      LIMIT $2
    `;

    try {
      const result = await pool.query(query, [userId, limit]);
      return result.rows;
    } catch (error) {
      console.error('Error getting user forum posts:', error);
      throw error;
    }
  }

  // Like a post
  static async like(postId, userId) {
    const query = `
      INSERT INTO forum_likes (post_id, user_id)
      VALUES ($1, $2)
      ON CONFLICT (post_id, user_id) DO NOTHING
      RETURNING *
    `;

    try {
      const result = await pool.query(query, [postId, userId]);
      return result.rows.length > 0;
    } catch (error) {
      console.error('Error liking post:', error);
      throw error;
    }
  }

  // Unlike a post
  static async unlike(postId, userId) {
    const query = `
      DELETE FROM forum_likes
      WHERE post_id = $1 AND user_id = $2
      RETURNING *
    `;

    try {
      const result = await pool.query(query, [postId, userId]);
      return result.rows.length > 0;
    } catch (error) {
      console.error('Error unliking post:', error);
      throw error;
    }
  }

  // Check if user liked a post
  static async hasLiked(postId, userId) {
    const query = `
      SELECT EXISTS(
        SELECT 1 FROM forum_likes
        WHERE post_id = $1 AND user_id = $2
      )
    `;

    try {
      const result = await pool.query(query, [postId, userId]);
      return result.rows[0].exists;
    } catch (error) {
      console.error('Error checking like status:', error);
      throw error;
    }
  }

  // Delete post (user can only delete their own)
  static async delete(postId, userId) {
    const query = `
      DELETE FROM forum_posts
      WHERE id = $1 AND user_id = $2
      RETURNING *
    `;

    try {
      const result = await pool.query(query, [postId, userId]);
      return result.rows.length > 0;
    } catch (error) {
      console.error('Error deleting post:', error);
      throw error;
    }
  }

  // Get community trends (most predicted numbers)
  static async getTrends(game, predictionType) {
    const query = `
      SELECT
        UNNEST(numbers) as number,
        COUNT(*) as bet_count
      FROM forum_posts
      WHERE game = $1
        AND prediction_type = $2
        AND created_at >= CURRENT_DATE
      GROUP BY number
      ORDER BY bet_count DESC
      LIMIT 10
    `;

    try {
      const result = await pool.query(query, [game, predictionType]);
      return result.rows;
    } catch (error) {
      console.error('Error getting community trends:', error);
      throw error;
    }
  }

  // Get hot predictions (most liked today)
  static async getHotPredictions(limit = 10) {
    const query = `
      SELECT
        fp.*,
        COALESCE(
          (SELECT COUNT(*) FROM forum_likes WHERE post_id = fp.id),
          0
        ) as likes
      FROM forum_posts fp
      WHERE fp.created_at >= CURRENT_DATE
      ORDER BY likes DESC, fp.created_at DESC
      LIMIT $1
    `;

    try {
      const result = await pool.query(query, [limit]);
      return result.rows;
    } catch (error) {
      console.error('Error getting hot predictions:', error);
      throw error;
    }
  }
}

module.exports = ForumPost;
