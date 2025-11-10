const predictionService = require('../services/predictionService');
const dreamService = require('../services/dreamService');
const Result = require('../models/Result');

// Get AI predictions (premium only)
const getPredictions = async (req, res) => {
  try {
    const predictions = await predictionService.getTodayPredictions();

    // Check if predictions exist
    if (Object.keys(predictions).length === 0) {
      return res.json({
        success: true,
        message: 'Predictions not yet available. Please check back at 6 AM.',
        data: {}
      });
    }

    res.json({
      success: true,
      data: predictions,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error getting predictions:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching predictions'
    });
  }
};

// Dream interpretation (premium only)
const interpretDream = async (req, res) => {
  try {
    const { userId, dream, language = 'auto', targetGame = 'shillong' } = req.body;

    if (!dream) {
      return res.status(400).json({
        success: false,
        message: 'Dream text is required'
      });
    }

    const result = await dreamService.interpretDream(dream, language, targetGame, userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('Error interpreting dream:', error);
    res.status(500).json({
      success: false,
      message: 'Error interpreting dream'
    });
  }
};

// Get dream history (premium only)
const getDreamHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10 } = req.query;

    const history = await dreamService.getUserDreamHistory(userId, parseInt(limit));

    res.json({
      success: true,
      data: history
    });
  } catch (error) {
    console.error('Error getting dream history:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching dream history'
    });
  }
};

// Get common numbers (premium gets advanced features)
const getCommonNumbers = async (req, res) => {
  try {
    const { game } = req.params;
    const { userId } = req.query;

    // Premium gets 30 days + patterns, free gets 7 days basic
    const days = req.isPremium ? 30 : 7;

    const commonNumbers = await Result.getCommonNumbers(game, days);

    let dayWiseAnalysis = null;
    if (req.isPremium) {
      dayWiseAnalysis = await Result.getDayWiseAnalysis(game, days);
    }

    res.json({
      success: true,
      game,
      days,
      isPremium: req.isPremium || false,
      data: {
        ...commonNumbers,
        dayWiseAnalysis
      }
    });
  } catch (error) {
    console.error('Error getting common numbers:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching common numbers'
    });
  }
};

// Calculate formula (premium only)
const calculateFormula = async (req, res) => {
  try {
    const { game, formulaType, previousResults } = req.body;

    if (!game || !formulaType || !previousResults || !Array.isArray(previousResults)) {
      return res.status(400).json({
        success: false,
        message: 'game, formulaType, and previousResults array are required'
      });
    }

    let predictedNumbers = [];
    let calculation = '';
    let explanation = '';

    // Implement different formula types
    switch (formulaType) {
      case 'house':
        // House formula: sum of digits
        if (previousResults.length > 0 && previousResults[0].fr) {
          const fr = previousResults[0].fr;
          const sum = Math.floor(fr / 10) + (fr % 10);
          const house = sum % 10;

          // Generate numbers in that house
          for (let i = 0; i < 10; i++) {
            predictedNumbers.push(house + (i * 10));
          }
          predictedNumbers = predictedNumbers.filter(n => n < 100).slice(0, 6);

          calculation = `House of ${fr} = ${Math.floor(fr / 10)} + ${fr % 10} = ${sum}, House ${house}`;
          explanation = `Based on house formula, numbers ending in ${house} have high probability.`;
        }
        break;

      case 'ending':
        // Ending formula: last digit pattern
        if (previousResults.length >= 3) {
          const lastDigits = previousResults.slice(0, 3).map(r => r.fr % 10);
          const avgEnding = Math.round(lastDigits.reduce((a, b) => a + b, 0) / lastDigits.length);

          // Generate numbers with similar ending
          for (let i = 0; i < 10; i++) {
            predictedNumbers.push((i * 10) + avgEnding);
          }
          predictedNumbers = predictedNumbers.filter(n => n < 100).slice(0, 6);

          calculation = `Last 3 endings: ${lastDigits.join(', ')}, Average: ${avgEnding}`;
          explanation = `Numbers ending in ${avgEnding} based on recent pattern.`;
        }
        break;

      case 'sum':
        // Sum formula: FR + SR pattern
        if (previousResults.length > 0 && previousResults[0].fr && previousResults[0].sr) {
          const sum = previousResults[0].fr + previousResults[0].sr;
          const mod = sum % 100;

          // Generate numbers around the sum
          predictedNumbers = [
            mod,
            (mod + 5) % 100,
            (mod + 10) % 100,
            (mod - 5 + 100) % 100,
            (mod + 15) % 100,
            (mod - 10 + 100) % 100
          ];

          calculation = `FR ${previousResults[0].fr} + SR ${previousResults[0].sr} = ${sum}, Mod 100 = ${mod}`;
          explanation = `Numbers around ${mod} based on FR+SR sum pattern.`;
        }
        break;

      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid formula type. Use: house, ending, or sum'
        });
    }

    res.json({
      success: true,
      data: {
        formulaType,
        calculation,
        predictedNumbers,
        explanation
      }
    });
  } catch (error) {
    console.error('Error calculating formula:', error);
    res.status(500).json({
      success: false,
      message: 'Error calculating formula'
    });
  }
};

// AI Common Numbers - Premium Feature (10 numbers daily)
const getAICommonNumbers = async (req, res) => {
  try {
    const { game = 'shillong' } = req.params;
    const predictions = await predictionService.getTodayPredictions();

    // Get today's date
    const today = new Date().toISOString().split('T')[0];

    // If no predictions for today, return message
    if (!predictions[game]) {
      return res.json({
        success: true,
        message: 'AI predictions will be available at 6 AM daily',
        data: {
          game,
          date: today,
          numbers: [],
          confidence: 0
        }
      });
    }

    const prediction = predictions[game];

    res.json({
      success: true,
      data: {
        game,
        date: today,
        fr_numbers: prediction.fr || [],
        sr_numbers: prediction.sr || [],
        analysis: prediction.analysis,
        confidence: prediction.confidence,
        type: 'common'
      }
    });
  } catch (error) {
    console.error('Error getting AI common numbers:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching AI common numbers'
    });
  }
};

// AI Lucky Numbers - Premium Feature (10 numbers daily)
const getAILuckyNumbers = async (req, res) => {
  try {
    const { game = 'shillong' } = req.params;
    const today = new Date().toISOString().split('T')[0];

    // Get past results for analysis
    const pastResults = await Result.getHistory(game, 30);

    if (pastResults.length < 7) {
      return res.json({
        success: true,
        message: 'Not enough data for lucky numbers analysis',
        data: {
          game,
          date: today,
          numbers: [],
          confidence: 0
        }
      });
    }

    // Generate lucky numbers using different strategy than common
    const luckyFR = generateLuckyNumbers(pastResults, 'fr');
    const luckySR = generateLuckyNumbers(pastResults, 'sr');

    res.json({
      success: true,
      data: {
        game,
        date: today,
        fr_numbers: luckyFR,
        sr_numbers: luckySR,
        analysis: 'Lucky numbers based on astrological patterns and date numerology combined with historical data',
        confidence: 75,
        type: 'lucky'
      }
    });
  } catch (error) {
    console.error('Error getting AI lucky numbers:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching AI lucky numbers'
    });
  }
};

// AI Hit Numbers - Premium Feature (shows what actually hit)
const getAIHitNumbers = async (req, res) => {
  try {
    const { game = 'shillong' } = req.params;
    const { days = 7 } = req.query;

    // Get past results
    const pastResults = await Result.getHistory(game, parseInt(days));

    if (pastResults.length === 0) {
      return res.json({
        success: true,
        message: 'No historical data available',
        data: {
          game,
          hit_numbers_fr: [],
          hit_numbers_sr: [],
          hot_count: 0
        }
      });
    }

    // Count frequency of each number
    const frFreq = {};
    const srFreq = {};

    pastResults.forEach(result => {
      if (result.fr !== null) {
        frFreq[result.fr] = (frFreq[result.fr] || 0) + 1;
      }
      if (result.sr !== null) {
        srFreq[result.sr] = (srFreq[result.sr] || 0) + 1;
      }
    });

    // Get top 10 hit numbers
    const hitFR = Object.entries(frFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([num, count]) => ({ number: parseInt(num), count }));

    const hitSR = Object.entries(srFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([num, count]) => ({ number: parseInt(num), count }));

    res.json({
      success: true,
      data: {
        game,
        date: new Date().toISOString().split('T')[0],
        fr_numbers: hitFR,
        sr_numbers: hitSR,
        days: parseInt(days),
        total_results: pastResults.length,
        analysis: `These numbers appeared most frequently in the last ${days} days of actual results`,
        confidence: 85,
        type: 'hit'
      }
    });
  } catch (error) {
    console.error('Error getting AI hit numbers:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching AI hit numbers'
    });
  }
};

// Helper function to generate lucky numbers
function generateLuckyNumbers(pastResults, type) {
  const numbers = [];
  const today = new Date();

  // Strategy: Use date numerology + hot numbers + random picks
  const dateSum = today.getDate() + (today.getMonth() + 1) + (today.getFullYear() % 100);
  const luckyBase = dateSum % 10;

  // Add numbers based on lucky base
  for (let i = 0; i < 10; i++) {
    const num = (luckyBase + i * 11) % 100;
    if (!numbers.includes(num)) {
      numbers.push(num);
    }
  }

  // Fill remaining with most frequent from past
  const freq = {};
  pastResults.forEach(r => {
    const val = type === 'fr' ? r.fr : r.sr;
    if (val !== null) {
      freq[val] = (freq[val] || 0) + 1;
    }
  });

  const hotNums = Object.entries(freq)
    .sort((a, b) => b[1] - a[1])
    .map(([n]) => parseInt(n));

  for (const num of hotNums) {
    if (numbers.length >= 10) break;
    if (!numbers.includes(num)) {
      numbers.push(num);
    }
  }

  // Ensure exactly 10 numbers
  while (numbers.length < 10) {
    const random = Math.floor(Math.random() * 100);
    if (!numbers.includes(random)) {
      numbers.push(random);
    }
  }

  return numbers.slice(0, 10);
}

module.exports = {
  getPredictions,
  interpretDream,
  getDreamHistory,
  getCommonNumbers,
  calculateFormula,
  getAICommonNumbers,
  getAILuckyNumbers,
  getAIHitNumbers
};
