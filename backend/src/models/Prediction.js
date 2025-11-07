const { pool } = require('../config/database');
const Result = require('./Result');
const Game = require('./Game');

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

  // ==================== AUTO-GENERATION LOGIC ====================

  // Generate predictions for a specific game and date
  static async generateForGame(game, targetDate) {
    try {
      console.log(`Generating prediction for ${game} on ${targetDate}`);

      // Get past 30 days of results
      const endDate = new Date(targetDate);
      const startDate = new Date(endDate);
      startDate.setDate(startDate.getDate() - 30);

      const results = await Result.getByGameAndDateRange(
        game,
        startDate.toISOString().split('T')[0],
        endDate.toISOString().split('T')[0]
      );

      if (results.length < 5) {
        console.log(`Not enough data for ${game} (only ${results.length} results)`);
        return null;
      }

      // Analyze patterns
      const patterns = this.analyzePatterns(results);

      // Generate 6 FR predictions
      const frPredictions = this.generateNumbers(patterns.fr, 6, 0, 99);

      // Generate 6 SR predictions
      const srPredictions = this.generateNumbers(patterns.sr, 6, 0, 99);

      // Calculate confidence based on pattern strength
      const confidence = this.calculateConfidence(patterns);

      // Generate analysis text
      const analysis = this.generateAnalysis(patterns, results.length);

      // Save prediction
      await this.upsert(
        game,
        targetDate,
        frPredictions,
        srPredictions,
        analysis,
        confidence
      );

      console.log(`✓ Generated prediction for ${game}: FR [${frPredictions}], SR [${srPredictions}]`);

      return {
        game,
        date: targetDate,
        fr: frPredictions,
        sr: srPredictions,
        analysis,
        confidence
      };
    } catch (error) {
      console.error(`Error generating prediction for ${game}:`, error);
      throw error;
    }
  }

  // Generate predictions for all active games
  static async generateForAllGames(targetDate) {
    try {
      console.log(`\n🔮 Starting prediction generation for ${targetDate}`);

      const games = await Game.getAll();
      const activeGames = games.filter(g => g.is_active);

      if (activeGames.length === 0) {
        console.log('No active games found');
        return [];
      }

      const predictions = [];
      for (const game of activeGames) {
        try {
          const prediction = await this.generateForGame(game.name, targetDate);
          if (prediction) {
            predictions.push(prediction);
          }
        } catch (error) {
          console.error(`Failed to generate prediction for ${game.name}:`, error);
        }
      }

      console.log(`\n✅ Generated ${predictions.length} predictions successfully\n`);
      return predictions;
    } catch (error) {
      console.error('Error generating predictions for all games:', error);
      throw error;
    }
  }

  // Analyze patterns in historical results
  static analyzePatterns(results) {
    const frFrequency = {};
    const srFrequency = {};
    const frByDay = {};
    const srByDay = {};

    // Count frequency and day-wise patterns
    results.forEach(result => {
      if (result.fr !== null) {
        frFrequency[result.fr] = (frFrequency[result.fr] || 0) + 1;

        const day = new Date(result.date).getDay(); // 0=Sunday, 6=Saturday
        if (!frByDay[day]) frByDay[day] = {};
        frByDay[day][result.fr] = (frByDay[day][result.fr] || 0) + 1;
      }

      if (result.sr !== null) {
        srFrequency[result.sr] = (srFrequency[result.sr] || 0) + 1;

        const day = new Date(result.date).getDay();
        if (!srByDay[day]) srByDay[day] = {};
        srByDay[day][result.sr] = (srByDay[day][result.sr] || 0) + 1;
      }
    });

    // Sort by frequency
    const frSorted = Object.entries(frFrequency)
      .sort((a, b) => b[1] - a[1])
      .map(([num, count]) => ({ number: parseInt(num), count }));

    const srSorted = Object.entries(srFrequency)
      .sort((a, b) => b[1] - a[1])
      .map(([num, count]) => ({ number: parseInt(num), count }));

    // Calculate formulas
    const houseNumbers = this.calculateFromFormula(results, 'house');
    const endingNumbers = this.calculateFromFormula(results, 'ending');

    // Detect even/odd trends
    const frEvenCount = results.filter(r => r.fr !== null && r.fr % 2 === 0).length;
    const frOddCount = results.filter(r => r.fr !== null && r.fr % 2 === 1).length;
    const srEvenCount = results.filter(r => r.sr !== null && r.sr % 2 === 0).length;
    const srOddCount = results.filter(r => r.sr !== null && r.sr % 2 === 1).length;

    return {
      fr: {
        frequency: frSorted,
        hot: frSorted.slice(0, 10),
        cold: frSorted.slice(-10),
        byDay: frByDay,
        evenOddTrend: frEvenCount > frOddCount ? 'even' : 'odd',
        evenOddRatio: (frEvenCount / (frEvenCount + frOddCount)).toFixed(2)
      },
      sr: {
        frequency: srSorted,
        hot: srSorted.slice(0, 10),
        cold: srSorted.slice(-10),
        byDay: srByDay,
        evenOddTrend: srEvenCount > srOddCount ? 'even' : 'odd',
        evenOddRatio: (srEvenCount / (srEvenCount + srOddCount)).toFixed(2)
      },
      formulas: {
        house: houseNumbers,
        ending: endingNumbers
      }
    };
  }

  // Calculate numbers using formulas
  static calculateFromFormula(results, type) {
    const numbers = {};

    results.forEach(result => {
      let calculatedNumber = null;

      if (type === 'house' && result.fr !== null) {
        // House: Sum of FR digits (e.g., FR=45 -> 4+5=9)
        const digits = result.fr.toString().split('');
        calculatedNumber = digits.reduce((sum, d) => sum + parseInt(d), 0);
        if (calculatedNumber >= 10) {
          // If sum is 10+, add digits again (e.g., 15 -> 1+5=6)
          const sumDigits = calculatedNumber.toString().split('');
          calculatedNumber = sumDigits.reduce((sum, d) => sum + parseInt(d), 0);
        }
      } else if (type === 'ending' && result.sr !== null) {
        // Ending: Last digit of SR (e.g., SR=67 -> 7)
        calculatedNumber = result.sr % 10;
      }

      if (calculatedNumber !== null) {
        numbers[calculatedNumber] = (numbers[calculatedNumber] || 0) + 1;
      }
    });

    return Object.entries(numbers)
      .sort((a, b) => b[1] - a[1])
      .map(([num, count]) => ({ number: parseInt(num), count }));
  }

  // Generate prediction numbers using weighted algorithm
  static generateNumbers(patterns, count, min, max) {
    const predictions = [];
    const { frequency, hot, formulas } = patterns;

    // Strategy: Combine hot numbers + some variety
    const hotNumbers = hot.slice(0, 8).map(h => h.number);

    // Add top hot numbers
    predictions.push(...hotNumbers.slice(0, Math.min(4, count)));

    // Add numbers with some randomness (weighted by frequency)
    while (predictions.length < count) {
      const randomIndex = Math.floor(Math.random() * Math.min(20, frequency.length));
      const number = frequency[randomIndex]?.number;

      if (number !== undefined && !predictions.includes(number) && number >= min && number <= max) {
        predictions.push(number);
      }
    }

    // Ensure we have exactly 'count' predictions
    while (predictions.length < count) {
      const randomNum = Math.floor(Math.random() * (max - min + 1)) + min;
      if (!predictions.includes(randomNum)) {
        predictions.push(randomNum);
      }
    }

    return predictions.slice(0, count);
  }

  // Calculate confidence score (0-100)
  static calculateConfidence(patterns) {
    // Higher confidence if:
    // 1. Strong hot number patterns (top numbers appear frequently)
    // 2. Clear even/odd trends
    // 3. Consistent day-wise patterns

    const frTopFrequency = patterns.fr.hot[0]?.count || 0;
    const srTopFrequency = patterns.sr.hot[0]?.count || 0;
    const totalResults = patterns.fr.frequency.reduce((sum, f) => sum + f.count, 0);

    const frStrength = (frTopFrequency / totalResults) * 100;
    const srStrength = (srTopFrequency / totalResults) * 100;

    const avgStrength = (frStrength + srStrength) / 2;

    // Base confidence: 60-85 based on pattern strength
    const confidence = Math.min(85, Math.max(60, 60 + avgStrength * 2));

    return Math.round(confidence);
  }

  // Generate human-readable analysis
  static generateAnalysis(patterns, dataPoints) {
    const frHot = patterns.fr.hot.slice(0, 5).map(h => h.number).join(', ');
    const srHot = patterns.sr.hot.slice(0, 5).map(h => h.number).join(', ');

    let analysis = `Based on ${dataPoints} days of analysis:\n\n`;
    analysis += `🔥 FR Hot Numbers: ${frHot}\n`;
    analysis += `🔥 SR Hot Numbers: ${srHot}\n\n`;

    analysis += `📊 Trends:\n`;
    analysis += `• FR shows ${patterns.fr.evenOddTrend} preference (${(patterns.fr.evenOddRatio * 100).toFixed(0)}%)\n`;
    analysis += `• SR shows ${patterns.sr.evenOddTrend} preference (${(patterns.sr.evenOddRatio * 100).toFixed(0)}%)\n`;

    return analysis;
  }
}

module.exports = Prediction;
