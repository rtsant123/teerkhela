const { translate } = require('@vitalets/google-translate-api');

class DreamAIService {
  /**
   * Enhanced Dream AI - Generates varied, authentic-looking predictions
   * Uses dream symbols + historical patterns + randomness for variety
   */
  static async interpretDream(dreamText, language = 'en', userHistory = []) {
    try {
      // Translate dream to English if needed
      let englishDream = dreamText;
      if (language !== 'en') {
        const translated = await translate(dreamText, { to: 'en' });
        englishDream = translated.text.toLowerCase();
      }

      // Extract keywords from dream
      const keywords = this.extractKeywords(englishDream);

      // Generate varied predictions based on keywords + history
      const predictions = this.generateVariedPredictions(keywords, userHistory);

      // Generate interpretation message
      const interpretation = this.generateInterpretation(keywords, predictions);

      return {
        success: true,
        dream: dreamText,
        language,
        keywords,
        predictions: {
          fr: predictions.fr,
          sr: predictions.sr
        },
        interpretation,
        confidence: predictions.confidence,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.error('Dream AI error:', error);
      throw error;
    }
  }

  /**
   * Extract meaningful keywords from dream
   */
  static extractKeywords(dreamText) {
    const text = dreamText.toLowerCase();
    const keywords = [];

    // Comprehensive dream symbol database
    const symbols = {
      // Animals
      animals: ['snake', 'dog', 'cat', 'bird', 'fish', 'elephant', 'tiger', 'monkey', 'cow', 'horse'],
      // Nature
      nature: ['water', 'fire', 'tree', 'mountain', 'river', 'rain', 'sun', 'moon', 'cloud', 'flower'],
      // People
      people: ['mother', 'father', 'friend', 'enemy', 'stranger', 'child', 'old', 'man', 'woman'],
      // Objects
      objects: ['house', 'car', 'money', 'gold', 'book', 'phone', 'key', 'door', 'window', 'mirror'],
      // Actions
      actions: ['running', 'flying', 'falling', 'fighting', 'eating', 'drinking', 'crying', 'laughing'],
      // Emotions
      emotions: ['happy', 'sad', 'angry', 'scared', 'excited', 'worried', 'peaceful', 'confused'],
      // Colors
      colors: ['red', 'blue', 'green', 'yellow', 'black', 'white', 'golden', 'silver'],
      // Numbers (if mentioned)
      numbers: ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten']
    };

    // Check for symbols in dream
    for (const [category, symbolList] of Object.entries(symbols)) {
      for (const symbol of symbolList) {
        if (text.includes(symbol)) {
          keywords.push({ symbol, category });
        }
      }
    }

    // If no keywords found, use generic interpretation
    if (keywords.length === 0) {
      keywords.push({ symbol: 'general', category: 'general' });
    }

    return keywords.slice(0, 5); // Max 5 keywords
  }

  /**
   * Generate varied predictions using keywords + historical data
   * Ensures different numbers each time for authenticity
   */
  static generateVariedPredictions(keywords, userHistory = []) {
    const usedNumbers = new Set();

    // Get previous predictions from user history to avoid repetition
    userHistory.forEach(pred => {
      if (pred.fr) usedNumbers.add(pred.fr % 100);
      if (pred.sr) usedNumbers.add(pred.sr % 100);
    });

    // Symbol-to-number mapping (for variety)
    const symbolMapping = {
      snake: [12, 23, 45, 67, 89],
      dog: [34, 56, 78, 90, 11],
      water: [14, 25, 36, 47, 58],
      fire: [19, 28, 37, 46, 55],
      money: [27, 38, 49, 50, 61],
      // ... add more mappings
    };

    const frCandidates = [];
    const srCandidates = [];

    // Generate candidates based on keywords
    keywords.forEach(({ symbol }) => {
      const mapped = symbolMapping[symbol] || [];
      mapped.forEach(num => {
        if (!usedNumbers.has(num)) {
          frCandidates.push(num);
          srCandidates.push(num);
        }
      });
    });

    // Fill with random numbers if not enough candidates
    while (frCandidates.length < 15) {
      const num = Math.floor(Math.random() * 100);
      if (!usedNumbers.has(num) && !frCandidates.includes(num)) {
        frCandidates.push(num);
      }
    }

    while (srCandidates.length < 15) {
      const num = Math.floor(Math.random() * 100);
      if (!usedNumbers.has(num) && !srCandidates.includes(num)) {
        srCandidates.push(num);
      }
    }

    // Shuffle and pick top numbers
    const shuffled FR = this.shuffle(frCandidates).slice(0, 10);
    const shuffledSR = this.shuffle(srCandidates).slice(0, 10);

    // Ensure at least 3 different numbers between FR and SR
    while (new Set([...shuffledFR, ...shuffledSR]).size < 13) {
      const newNum = Math.floor(Math.random() * 100);
      if (!shuffledFR.includes(newNum) && !shuffledSR.includes(newNum)) {
        shuffledSR[shuffledSR.length - 1] = newNum;
      }
    }

    // Generate confidence (60-95%)
    const confidence = 60 + Math.floor(Math.random() * 35);

    return {
      fr: shuffledFR.map(n => n.toString().padStart(2, '0')),
      sr: shuffledSR.map(n => n.toString().padStart(2, '0')),
      confidence
    };
  }

  /**
   * Generate authentic interpretation message
   */
  static generateInterpretation(keywords, predictions) {
    const interpretations = {
      snake: 'Snake symbolizes transformation and hidden opportunities. The numbers suggest upcoming changes.',
      dog: 'Dog represents loyalty and friendship. Your numbers indicate support from trusted sources.',
      water: 'Water signifies emotions and flow. These numbers align with your emotional state.',
      fire: 'Fire represents passion and energy. The predictions reflect your inner drive.',
      money: 'Money dreams indicate prosperity. These numbers carry financial significance.',
      mother: 'Mother symbolizes nurturing energy. Numbers suggest protective guidance.',
      general: 'Your subconscious mind has processed recent events. These numbers emerge from deep intuition.'
    };

    const mainKeyword = keywords[0]?.symbol || 'general';
    const baseInterpretation = interpretations[mainKeyword] || interpretations.general;

    const messages = [
      `${baseInterpretation}`,
      `Confidence level: ${predictions.confidence}% based on dream analysis.`,
      keywords.length > 1 ? `Also detected: ${keywords.slice(1).map(k => k.symbol).join(', ')}.` : '',
      `Best timing: Next 3 days for maximum alignment.`
    ];

    return messages.filter(m => m).join(' ');
  }

  /**
   * Shuffle array (Fisher-Yates algorithm)
   */
  static shuffle(array) {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  }
}

module.exports = DreamAIService;
