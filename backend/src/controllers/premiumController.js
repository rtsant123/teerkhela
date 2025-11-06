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

module.exports = {
  getPredictions,
  interpretDream,
  getDreamHistory,
  getCommonNumbers,
  calculateFormula
};
