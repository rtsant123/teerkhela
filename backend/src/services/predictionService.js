const Result = require('../models/Result');
const Prediction = require('../models/Prediction');
const PredictionResult = require('../models/PredictionResult');

class PredictionService {
  constructor() {
    this.games = ['shillong', 'khanapara', 'juwai', 'shillong-morning', 'juwai-morning', 'khanapara-morning'];
  }

  // Generate predictions for all games
  async generateAllPredictions() {
    try {
      console.log('🤖 Generating AI predictions for all games...');
      const predictions = {};
      const today = new Date().toISOString().split('T')[0];

      for (const game of this.games) {
        try {
          const prediction = await this.generatePredictionForGame(game);
          if (prediction) {
            predictions[game] = prediction;

            // Save to database
            await Prediction.upsert(
              game,
              today,
              prediction.fr,
              prediction.sr,
              prediction.analysis,
              prediction.confidence
            );

            // Save to prediction_results for accuracy tracking
            await PredictionResult.savePrediction(
              game,
              today,
              prediction.fr,
              prediction.sr,
              prediction.confidence
            );
          }
        } catch (error) {
          console.error(`Error generating prediction for ${game}:`, error);
        }
      }

      console.log(`✅ Generated predictions for ${Object.keys(predictions).length} games`);
      return predictions;
    } catch (error) {
      console.error('❌ Error generating predictions:', error);
      throw error;
    }
  }

  // Generate prediction for single game
  async generatePredictionForGame(game) {
    try {
      // Get past 30 days results
      const pastResults = await Result.getHistory(game, 30);

      if (pastResults.length < 7) {
        console.log(`Not enough data for ${game}, need at least 7 days`);
        return null;
      }

      // Analyze patterns
      const analysis = this.analyzePatterns(pastResults);

      // Generate FR predictions
      const frPredictions = this.generateNumbers(analysis, 'fr');

      // Generate SR predictions
      const srPredictions = this.generateNumbers(analysis, 'sr');

      // Generate analysis text
      const analysisText = this.generateAnalysisText(game, analysis, pastResults);

      // Calculate confidence (based on pattern strength)
      const confidence = this.calculateConfidence(analysis);

      return {
        game,
        fr: frPredictions,
        sr: srPredictions,
        analysis: analysisText,
        confidence
      };
    } catch (error) {
      console.error(`Error generating prediction for ${game}:`, error);
      return null;
    }
  }

  // Analyze patterns in past results
  analyzePatterns(results) {
    const frequency = { fr: {}, sr: {} };
    const lastDigits = { fr: {}, sr: {} };
    const sumPatterns = [];
    const gaps = { fr: {}, sr: {} };
    const dayWise = {};

    results.forEach((result, index) => {
      // Frequency count
      if (result.fr !== null) {
        frequency.fr[result.fr] = (frequency.fr[result.fr] || 0) + 1;

        // Last digit frequency
        const frLastDigit = result.fr % 10;
        lastDigits.fr[frLastDigit] = (lastDigits.fr[frLastDigit] || 0) + 1;

        // Gap analysis (how long since last appearance)
        if (!gaps.fr[result.fr]) {
          gaps.fr[result.fr] = index;
        }
      }

      if (result.sr !== null) {
        frequency.sr[result.sr] = (frequency.sr[result.sr] || 0) + 1;

        const srLastDigit = result.sr % 10;
        lastDigits.sr[srLastDigit] = (lastDigits.sr[srLastDigit] || 0) + 1;

        if (!gaps.sr[result.sr]) {
          gaps.sr[result.sr] = index;
        }
      }

      // Sum pattern
      if (result.fr !== null && result.sr !== null) {
        sumPatterns.push(result.fr + result.sr);
      }

      // Day-wise pattern
      const date = new Date(result.date);
      const day = date.getDay();
      if (!dayWise[day]) {
        dayWise[day] = { fr: [], sr: [] };
      }
      if (result.fr !== null) dayWise[day].fr.push(result.fr);
      if (result.sr !== null) dayWise[day].sr.push(result.sr);
    });

    // Sort by frequency (hot numbers)
    const hotNumbersFR = Object.entries(frequency.fr)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([num]) => parseInt(num));

    const hotNumbersSR = Object.entries(frequency.sr)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([num]) => parseInt(num));

    // Cold numbers (appeared least or not appeared)
    const allNumbers = Array.from({ length: 100 }, (_, i) => i);
    const coldNumbersFR = allNumbers
      .filter(num => !frequency.fr[num] || frequency.fr[num] <= 1)
      .slice(0, 10);

    const coldNumbersSR = allNumbers
      .filter(num => !frequency.sr[num] || frequency.sr[num] <= 1)
      .slice(0, 10);

    // Most common last digits
    const hotLastDigitsFR = Object.entries(lastDigits.fr)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([digit]) => parseInt(digit));

    const hotLastDigitsSR = Object.entries(lastDigits.sr)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([digit]) => parseInt(digit));

    return {
      hotNumbers: { fr: hotNumbersFR, sr: hotNumbersSR },
      coldNumbers: { fr: coldNumbersFR, sr: coldNumbersSR },
      hotLastDigits: { fr: hotLastDigitsFR, sr: hotLastDigitsSR },
      frequency,
      sumPatterns,
      totalResults: results.length
    };
  }

  // Generate predicted numbers
  generateNumbers(analysis, type) {
    const predictions = [];
    const hotNumbers = analysis.hotNumbers[type];
    const coldNumbers = analysis.coldNumbers[type];
    const hotLastDigits = analysis.hotLastDigits[type];

    // Strategy: Mix hot numbers, pattern-based numbers, cold numbers, and strategic picks
    // Now generating 10 numbers for better variety

    // 1. Add top 3 hot numbers (most frequent)
    predictions.push(...hotNumbers.slice(0, 3));

    // 2. Add 3 numbers with hot last digits (pattern-based)
    for (const digit of hotLastDigits) {
      if (predictions.length >= 6) break;

      // Generate numbers ending in hot digits
      const candidates = Array.from({ length: 10 }, (_, i) => i * 10 + digit)
        .filter(num => num < 100 && !predictions.includes(num));

      if (candidates.length > 0) {
        const random = candidates[Math.floor(Math.random() * candidates.length)];
        predictions.push(random);
      }
    }

    // 3. Add 2 cold numbers (due for appearance - contrarian strategy)
    let coldAdded = 0;
    for (let i = 0; i < coldNumbers.length && coldAdded < 2; i++) {
      const coldNum = coldNumbers[i];
      if (!predictions.includes(coldNum)) {
        predictions.push(coldNum);
        coldAdded++;
      }
    }

    // 4. Add 2 medium-frequency numbers (balanced approach)
    const mediumNumbers = hotNumbers.slice(3, 7)
      .filter(num => !predictions.includes(num));
    predictions.push(...mediumNumbers.slice(0, 2));

    // 5. Fill remaining with strategic random numbers (variety)
    while (predictions.length < 10) {
      const num = Math.floor(Math.random() * 100);
      if (!predictions.includes(num)) {
        predictions.push(num);
      }
    }

    // Return exactly 10 unique numbers
    return predictions.slice(0, 10);
  }

  // Generate analysis text
  generateAnalysisText(game, analysis, pastResults) {
    const hotFR = analysis.hotNumbers.fr.slice(0, 3).join(', ');
    const hotSR = analysis.hotNumbers.sr.slice(0, 3).join(', ');

    const recent = pastResults.slice(0, 5);
    const recentFR = recent.map(r => r.fr).filter(n => n !== null);
    const recentSR = recent.map(r => r.sr).filter(n => n !== null);

    const gameName = game.split('-').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');

    let text = `📊 AI Analysis - ${gameName} Teer\n`;
    text += `Based on ${analysis.totalResults} days of historical data\n\n`;

    text += `🔥 HOT NUMBERS (Most Frequent):\n`;
    text += `FR: ${hotFR}\n`;
    text += `SR: ${hotSR}\n\n`;

    text += `📈 RECENT PATTERN (Last 5 Days):\n`;
    text += `FR: ${recentFR.join(', ')}\n`;
    text += `SR: ${recentSR.join(', ')}\n\n`;

    text += `🎯 10-NUMBER PREDICTION STRATEGY:\n`;
    text += `• 3 Hot Numbers (highest frequency)\n`;
    text += `• 3 Pattern-based (common endings)\n`;
    text += `• 2 Cold Numbers (due for appearance)\n`;
    text += `• 2 Medium picks (balanced approach)\n\n`;

    text += `💡 WHY 10 NUMBERS?\n`;
    text += `More numbers = better coverage! Any of these 10 numbers have high potential based on our AI analysis.\n\n`;

    text += `⚠️ IMPORTANT DISCLAIMER:\n`;
    text += `This is for entertainment only. Predictions are statistical estimates, not guarantees. Play responsibly and within your means.`;

    return text;
  }

  // Calculate confidence score
  calculateConfidence(analysis) {
    let confidence = 60; // Base confidence

    // More data = more confidence
    if (analysis.totalResults >= 30) confidence += 10;
    else if (analysis.totalResults >= 20) confidence += 5;

    // Strong patterns = more confidence
    const hotFRStrength = analysis.hotNumbers.fr[0] ?
      (analysis.frequency.fr[analysis.hotNumbers.fr[0]] / analysis.totalResults) * 100 : 0;

    if (hotFRStrength > 15) confidence += 10;
    else if (hotFRStrength > 10) confidence += 5;

    // Cap at 95%
    return Math.min(95, confidence);
  }

  // Get today's predictions
  async getTodayPredictions() {
    try {
      return await Prediction.getTodayPredictions();
    } catch (error) {
      console.error('Error getting today predictions:', error);
      throw error;
    }
  }

  // Manual override (for admin)
  async overridePrediction(game, date, frNumbers, srNumbers, analysis, confidence) {
    try {
      await Prediction.upsert(game, date, frNumbers, srNumbers, analysis, confidence);
      console.log(`✅ Prediction overridden for ${game} on ${date}`);
      return { success: true };
    } catch (error) {
      console.error('Error overriding prediction:', error);
      throw error;
    }
  }

  // Auto-verify predictions when results come in
  async verifyPredictionForResult(game, date, actualFR, actualSR) {
    try {
      if (actualFR === null || actualSR === null) {
        console.log(`Skipping verification for ${game} on ${date} - incomplete results`);
        return null;
      }

      const result = await PredictionResult.verifyPrediction(game, date, actualFR, actualSR);

      if (result) {
        console.log(`✅ Verified prediction for ${game} on ${date}: FR=${result.fr_hit ? 'HIT' : 'MISS'}, SR=${result.sr_hit ? 'HIT' : 'MISS'}`);
      }

      return result;
    } catch (error) {
      console.error('Error verifying prediction:', error);
      throw error;
    }
  }

  // Verify all unverified predictions
  async verifyAllPredictions() {
    try {
      console.log('🔍 Verifying all predictions against results...');
      let verified = 0;

      for (const game of this.games) {
        // Get last 30 days of results
        const results = await Result.getHistory(game, 30);

        for (const result of results) {
          if (result.fr !== null && result.sr !== null) {
            const dateStr = new Date(result.date).toISOString().split('T')[0];
            await this.verifyPredictionForResult(game, dateStr, result.fr, result.sr);
            verified++;
          }
        }
      }

      console.log(`✅ Verified ${verified} predictions`);
      return verified;
    } catch (error) {
      console.error('Error verifying all predictions:', error);
      throw error;
    }
  }
}

module.exports = new PredictionService();
