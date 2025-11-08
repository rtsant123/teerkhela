const pool = require('../config/database');

class PredictionResult {
  // Create prediction_results table
  static async createTable() {
    const query = `
      CREATE TABLE IF NOT EXISTS prediction_results (
        id SERIAL PRIMARY KEY,
        game VARCHAR(50) NOT NULL,
        date DATE NOT NULL,
        prediction_fr INTEGER[] NOT NULL,
        prediction_sr INTEGER[] NOT NULL,
        actual_fr INTEGER,
        actual_sr INTEGER,
        fr_hit BOOLEAN,
        sr_hit BOOLEAN,
        confidence INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        verified_at TIMESTAMP,
        UNIQUE(game, date)
      );

      CREATE INDEX IF NOT EXISTS idx_prediction_results_game ON prediction_results(game);
      CREATE INDEX IF NOT EXISTS idx_prediction_results_date ON prediction_results(date DESC);
      CREATE INDEX IF NOT EXISTS idx_prediction_results_verified ON prediction_results(verified_at DESC);
    `;

    try {
      await pool.query(query);
      console.log('✅ Prediction results table created successfully');
    } catch (error) {
      console.error('❌ Error creating prediction_results table:', error);
      throw error;
    }
  }

  // Save prediction for tracking
  static async savePrediction(game, date, predictionFR, predictionSR, confidence) {
    const query = `
      INSERT INTO prediction_results (game, date, prediction_fr, prediction_sr, confidence)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (game, date)
      DO UPDATE SET
        prediction_fr = $3,
        prediction_sr = $4,
        confidence = $5
      RETURNING *
    `;

    try {
      const result = await pool.query(query, [game, date, predictionFR, predictionSR, confidence]);
      return result.rows[0];
    } catch (error) {
      console.error('Error saving prediction:', error);
      throw error;
    }
  }

  // Verify prediction against actual result
  static async verifyPrediction(game, date, actualFR, actualSR) {
    // First get the prediction
    const getPredQuery = `
      SELECT * FROM prediction_results
      WHERE game = $1 AND date = $2
    `;

    try {
      const predResult = await pool.query(getPredQuery, [game, date]);

      if (predResult.rows.length === 0) {
        console.log(`No prediction found for ${game} on ${date}`);
        return null;
      }

      const prediction = predResult.rows[0];

      // Check if predicted numbers match actual
      const frHit = prediction.prediction_fr.includes(actualFR);
      const srHit = prediction.prediction_sr.includes(actualSR);

      // Update with actual results and hit status
      const updateQuery = `
        UPDATE prediction_results
        SET
          actual_fr = $1,
          actual_sr = $2,
          fr_hit = $3,
          sr_hit = $4,
          verified_at = CURRENT_TIMESTAMP
        WHERE game = $5 AND date = $6
        RETURNING *
      `;

      const result = await pool.query(updateQuery, [
        actualFR,
        actualSR,
        frHit,
        srHit,
        game,
        date
      ]);

      console.log(`✅ Prediction verified for ${game} on ${date}: FR=${frHit ? '✅' : '❌'}, SR=${srHit ? '✅' : '❌'}`);

      return result.rows[0];
    } catch (error) {
      console.error('Error verifying prediction:', error);
      throw error;
    }
  }

  // Get accuracy statistics for a game
  static async getAccuracy(game, days = 30) {
    const query = `
      SELECT
        COUNT(*) FILTER (WHERE verified_at IS NOT NULL) as total_predictions,
        COUNT(*) FILTER (WHERE fr_hit = true) as fr_hits,
        COUNT(*) FILTER (WHERE sr_hit = true) as sr_hits,
        COUNT(*) FILTER (WHERE fr_hit = true AND sr_hit = true) as both_hits,
        ROUND(
          (COUNT(*) FILTER (WHERE fr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as fr_accuracy,
        ROUND(
          (COUNT(*) FILTER (WHERE sr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as sr_accuracy,
        ROUND(
          (COUNT(*) FILTER (WHERE fr_hit = true OR sr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as overall_accuracy
      FROM prediction_results
      WHERE game = $1
        AND date >= CURRENT_DATE - INTERVAL '${days} days'
        AND verified_at IS NOT NULL
    `;

    try {
      const result = await pool.query(query, [game]);
      return result.rows[0];
    } catch (error) {
      console.error('Error getting accuracy:', error);
      throw error;
    }
  }

  // Get overall accuracy (all games combined)
  static async getOverallAccuracy(days = 30) {
    const query = `
      SELECT
        COUNT(*) FILTER (WHERE verified_at IS NOT NULL) as total_predictions,
        COUNT(*) FILTER (WHERE fr_hit = true) as fr_hits,
        COUNT(*) FILTER (WHERE sr_hit = true) as sr_hits,
        COUNT(*) FILTER (WHERE fr_hit = true AND sr_hit = true) as both_hits,
        ROUND(
          (COUNT(*) FILTER (WHERE fr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as fr_accuracy,
        ROUND(
          (COUNT(*) FILTER (WHERE sr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as sr_accuracy,
        ROUND(
          (COUNT(*) FILTER (WHERE fr_hit = true OR sr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as overall_accuracy
      FROM prediction_results
      WHERE date >= CURRENT_DATE - INTERVAL '${days} days'
        AND verified_at IS NOT NULL
    `;

    try {
      const result = await pool.query(query);
      return result.rows[0];
    } catch (error) {
      console.error('Error getting overall accuracy:', error);
      throw error;
    }
  }

  // Get recent predictions with results (last N days)
  static async getRecentPredictions(game = null, limit = 10) {
    let query = `
      SELECT
        game,
        date,
        prediction_fr,
        prediction_sr,
        actual_fr,
        actual_sr,
        fr_hit,
        sr_hit,
        confidence,
        verified_at
      FROM prediction_results
      WHERE verified_at IS NOT NULL
    `;

    const params = [];
    if (game) {
      params.push(game);
      query += ` AND game = $1`;
    }

    query += ` ORDER BY date DESC LIMIT $${params.length + 1}`;
    params.push(limit);

    try {
      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      console.error('Error getting recent predictions:', error);
      throw error;
    }
  }

  // Get accuracy trend (day by day)
  static async getAccuracyTrend(game = null, days = 7) {
    let query = `
      SELECT
        date,
        game,
        fr_hit,
        sr_hit,
        confidence
      FROM prediction_results
      WHERE verified_at IS NOT NULL
        AND date >= CURRENT_DATE - INTERVAL '${days} days'
    `;

    const params = [];
    if (game) {
      params.push(game);
      query += ` AND game = $1`;
    }

    query += ` ORDER BY date DESC`;

    try {
      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      console.error('Error getting accuracy trend:', error);
      throw error;
    }
  }

  // Get best performing games
  static async getBestGames(days = 30) {
    const query = `
      SELECT
        game,
        COUNT(*) FILTER (WHERE verified_at IS NOT NULL) as total_predictions,
        COUNT(*) FILTER (WHERE fr_hit = true OR sr_hit = true) as hits,
        ROUND(
          (COUNT(*) FILTER (WHERE fr_hit = true OR sr_hit = true)::DECIMAL /
           NULLIF(COUNT(*) FILTER (WHERE verified_at IS NOT NULL), 0)) * 100,
          1
        ) as accuracy
      FROM prediction_results
      WHERE date >= CURRENT_DATE - INTERVAL '${days} days'
        AND verified_at IS NOT NULL
      GROUP BY game
      HAVING COUNT(*) FILTER (WHERE verified_at IS NOT NULL) >= 5
      ORDER BY accuracy DESC
    `;

    try {
      const result = await pool.query(query);
      return result.rows;
    } catch (error) {
      console.error('Error getting best games:', error);
      throw error;
    }
  }
}

module.exports = PredictionResult;
