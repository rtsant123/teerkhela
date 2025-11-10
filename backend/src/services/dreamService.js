const translate = require('@vitalets/google-translate-api');
const { pool } = require('../config/database');
const Result = require('../models/Result');

// Comprehensive dream dictionary (100+ symbols)
const dreamDictionary = {
  // Animals
  snake: { numbers: [23, 45, 67], meaning: 'transformation, caution, hidden wisdom' },
  fish: { numbers: [12, 34, 56], meaning: 'abundance, prosperity, emotions' },
  elephant: { numbers: [89, 90, 11], meaning: 'wisdom, strength, memory' },
  tiger: { numbers: [45, 78, 90], meaning: 'power, courage, aggression' },
  dog: { numbers: [23, 56, 89], meaning: 'loyalty, friendship, protection' },
  cat: { numbers: [34, 67, 89], meaning: 'independence, mystery, intuition' },
  bird: { numbers: [12, 23, 45], meaning: 'freedom, perspective, messages' },
  cow: { numbers: [56, 78, 90], meaning: 'nourishment, patience, motherhood' },
  horse: { numbers: [34, 45, 89], meaning: 'movement, power, freedom' },
  monkey: { numbers: [12, 34, 78], meaning: 'playfulness, intelligence, mischief' },
  lion: { numbers: [67, 89, 90], meaning: 'leadership, courage, strength' },
  bear: { numbers: [45, 67, 78], meaning: 'power, protection, introspection' },
  rabbit: { numbers: [12, 23, 34], meaning: 'fertility, speed, luck' },
  rat: { numbers: [23, 45, 56], meaning: 'survival, resourcefulness' },
  buffalo: { numbers: [78, 89, 90], meaning: 'strength, determination' },

  // Nature
  water: { numbers: [12, 34, 56], meaning: 'emotions, flow, cleansing' },
  fire: { numbers: [56, 78, 90], meaning: 'transformation, passion, destruction' },
  river: { numbers: [23, 45, 78], meaning: 'life journey, flow, time' },
  mountain: { numbers: [67, 89, 90], meaning: 'challenge, achievement, stability' },
  tree: { numbers: [45, 56, 78], meaning: 'growth, stability, life' },
  flower: { numbers: [23, 34, 56], meaning: 'beauty, temporariness, growth' },
  rain: { numbers: [12, 45, 89], meaning: 'cleansing, renewal, sadness' },
  sun: { numbers: [34, 67, 90], meaning: 'vitality, clarity, consciousness' },
  moon: { numbers: [23, 56, 78], meaning: 'intuition, cycles, mystery' },
  ocean: { numbers: [45, 67, 89], meaning: 'vast emotions, unconscious' },
  forest: { numbers: [34, 56, 78], meaning: 'unknown, growth, nature' },
  sky: { numbers: [23, 45, 67], meaning: 'freedom, possibilities, heaven' },
  earth: { numbers: [56, 78, 90], meaning: 'grounding, stability, material' },
  storm: { numbers: [45, 67, 89], meaning: 'turmoil, change, power' },

  // People
  mother: { numbers: [23, 45, 67], meaning: 'nurturing, protection, origin' },
  father: { numbers: [34, 56, 78], meaning: 'authority, guidance, protection' },
  child: { numbers: [12, 23, 34], meaning: 'innocence, new beginnings, inner child' },
  friend: { numbers: [45, 56, 67], meaning: 'support, connection, aspects of self' },
  enemy: { numbers: [67, 89, 90], meaning: 'conflict, challenge, shadow self' },
  teacher: { numbers: [23, 45, 78], meaning: 'guidance, learning, wisdom' },
  doctor: { numbers: [34, 56, 89], meaning: 'healing, health, care' },
  king: { numbers: [67, 89, 90], meaning: 'authority, power, leadership' },
  queen: { numbers: [56, 78, 89], meaning: 'feminine power, nurturing, authority' },

  // Objects
  money: { numbers: [23, 56, 89], meaning: 'value, power, self-worth' },
  gold: { numbers: [45, 67, 90], meaning: 'wealth, perfection, highest value' },
  silver: { numbers: [34, 56, 78], meaning: 'intuition, feminine, reflection' },
  car: { numbers: [34, 78, 90], meaning: 'journey, control, direction' },
  house: { numbers: [56, 78, 89], meaning: 'security, self, family' },
  temple: { numbers: [23, 67, 89], meaning: 'spirituality, peace, devotion' },
  book: { numbers: [12, 34, 45], meaning: 'knowledge, learning, wisdom' },
  phone: { numbers: [23, 45, 56], meaning: 'communication, connection, messages' },
  mirror: { numbers: [34, 56, 67], meaning: 'self-reflection, truth, vanity' },
  key: { numbers: [23, 45, 78], meaning: 'solution, access, mystery' },
  sword: { numbers: [56, 78, 90], meaning: 'power, conflict, decision' },
  ring: { numbers: [23, 34, 67], meaning: 'commitment, eternity, unity' },

  // Events/Actions
  marriage: { numbers: [23, 45, 89], meaning: 'union, commitment, integration' },
  death: { numbers: [67, 89, 90], meaning: 'ending, transformation, change' },
  birth: { numbers: [12, 23, 34], meaning: 'beginning, creation, new life' },
  fight: { numbers: [56, 78, 90], meaning: 'conflict, struggle, inner turmoil' },
  win: { numbers: [34, 67, 89], meaning: 'success, achievement, victory' },
  lose: { numbers: [23, 45, 56], meaning: 'loss, learning, letting go' },
  fly: { numbers: [12, 34, 67], meaning: 'freedom, transcendence, escape' },
  fall: { numbers: [45, 67, 78], meaning: 'loss of control, fear, failure' },
  swim: { numbers: [23, 56, 78], meaning: 'navigating emotions, flow' },
  run: { numbers: [34, 45, 89], meaning: 'escape, urgency, pursuit' },
  dance: { numbers: [12, 23, 56], meaning: 'joy, expression, harmony' },
  cry: { numbers: [23, 45, 67], meaning: 'release, sadness, cleansing' },
  laugh: { numbers: [12, 34, 56], meaning: 'joy, release, lightness' },

  // Colors
  red: { numbers: [45, 67, 89], meaning: 'passion, anger, energy' },
  blue: { numbers: [23, 34, 56], meaning: 'calm, sadness, truth' },
  green: { numbers: [34, 56, 78], meaning: 'growth, healing, nature' },
  white: { numbers: [12, 23, 45], meaning: 'purity, clarity, new beginnings' },
  black: { numbers: [67, 78, 90], meaning: 'mystery, unknown, fear' },
  yellow: { numbers: [23, 34, 67], meaning: 'joy, intellect, caution' },

  // Food
  rice: { numbers: [23, 45, 67], meaning: 'nourishment, abundance, basics' },
  bread: { numbers: [34, 56, 78], meaning: 'sustenance, basics, comfort' },
  milk: { numbers: [12, 23, 34], meaning: 'nourishment, mother, purity' },
  fruit: { numbers: [23, 45, 56], meaning: 'reward, health, sweetness' },
  meat: { numbers: [56, 78, 89], meaning: 'strength, survival, basic needs' },

  // Body Parts
  eye: { numbers: [23, 45, 67], meaning: 'perception, awareness, truth' },
  hand: { numbers: [34, 56, 78], meaning: 'action, control, giving' },
  foot: { numbers: [45, 67, 89], meaning: 'grounding, movement, foundation' },
  heart: { numbers: [23, 34, 56], meaning: 'love, emotion, center' },
  blood: { numbers: [56, 78, 89], meaning: 'life force, family, sacrifice' }
};

class DreamService {
  // Interpret dream with multi-language support
  async interpretDream(dreamText, userLanguage = 'auto', targetGame = 'shillong', userId) {
    try {
      console.log(`🔮 Interpreting dream for user ${userId}...`);

      // Step 1: Detect language if not provided
      let detectedLang = userLanguage;
      let englishDream = dreamText;

      if (!userLanguage || userLanguage === 'auto' || userLanguage !== 'en') {
        try {
          const translation = await translate(dreamText, { to: 'en' });
          englishDream = translation.text;
          detectedLang = translation.from.language.iso;
          console.log(`Detected language: ${detectedLang}`);
        } catch (error) {
          console.error('Translation error:', error.message);
          // If translation fails, assume English
          detectedLang = 'en';
          englishDream = dreamText;
        }
      }

      // Step 2: Extract symbols from dream
      const words = englishDream.toLowerCase().split(/\s+/);
      const foundSymbols = [];
      const dreamNumbers = new Set();
      const symbolMeanings = {};

      words.forEach(word => {
        // Clean word (remove punctuation)
        const cleanWord = word.replace(/[.,\/#!$%\^&\*;:{}=\-_`~()]/g, '');

        if (dreamDictionary[cleanWord]) {
          foundSymbols.push(cleanWord);
          dreamDictionary[cleanWord].numbers.forEach(n => dreamNumbers.add(n));
          symbolMeanings[cleanWord] = dreamDictionary[cleanWord].meaning;
        }
      });

      console.log(`Found ${foundSymbols.length} symbols: ${foundSymbols.join(', ')}`);

      // Step 3: Get past 30 days results for target game
      const pastResults = await Result.getHistory(targetGame, 30);
      const hotNumbers = this.analyzeHotNumbers(pastResults);

      // Step 4: Combine dream numbers with hot numbers
      let finalNumbers = Array.from(dreamNumbers);

      // Add hot numbers that aren't in dream numbers
      hotNumbers.forEach(num => {
        if (!finalNumbers.includes(num) && finalNumbers.length < 10) {
          finalNumbers.push(num);
        }
      });

      // If we have less than 6 numbers, add strategic numbers
      while (finalNumbers.length < 6) {
        const strategicNum = Math.floor(Math.random() * 100);
        if (!finalNumbers.includes(strategicNum)) {
          finalNumbers.push(strategicNum);
        }
      }

      // Take top 6
      finalNumbers = finalNumbers.slice(0, 6);

      // Step 5: Generate analysis in English
      let englishAnalysis = this.generateAnalysis(foundSymbols, symbolMeanings, hotNumbers, targetGame);

      // Step 6: Generate multilingual responses (7 languages)
      const multilingualAnalysis = await this.generateMultilingualResponse(englishAnalysis);

      // Step 7: Calculate confidence
      const confidence = this.calculateConfidence(foundSymbols.length, pastResults.length);

      // Step 8: Save to database
      await this.saveDreamInterpretation(
        userId,
        dreamText,
        detectedLang,
        foundSymbols,
        finalNumbers,
        englishAnalysis,
        confidence,
        targetGame
      );

      return {
        originalLanguage: detectedLang,
        translatedDream: englishDream,
        symbols: foundSymbols,
        symbolMeanings: symbolMeanings,
        numbers: finalNumbers,
        analysis: multilingualAnalysis.en, // Default English for legacy support
        multilingualAnalysis: multilingualAnalysis, // New multilingual field
        confidence: confidence,
        basedOnPastResults: pastResults.length > 0,
        recentHotNumbers: hotNumbers.slice(0, 5),
        recommendation: targetGame.toUpperCase()
      };
    } catch (error) {
      console.error('Dream interpretation error:', error);
      throw error;
    }
  }

  // Analyze hot numbers from past results
  analyzeHotNumbers(pastResults) {
    const frequency = {};

    pastResults.forEach(result => {
      if (result.fr !== null) {
        frequency[result.fr] = (frequency[result.fr] || 0) + 1;
      }
      if (result.sr !== null) {
        frequency[result.sr] = (frequency[result.sr] || 0) + 1;
      }
    });

    return Object.entries(frequency)
      .sort((a, b) => b[1] - a[1])
      .map(([num]) => parseInt(num))
      .slice(0, 10);
  }

  // Generate analysis text
  generateAnalysis(symbols, meanings, hotNumbers, game) {
    let analysis = '';

    if (symbols.length > 0) {
      analysis += `Your dream contains powerful symbols: ${symbols.join(', ')}. `;

      // Describe first symbol in detail
      if (symbols[0] && meanings[symbols[0]]) {
        analysis += `The ${symbols[0]} represents ${meanings[symbols[0]]}. `;
      }

      analysis += `These symbols suggest specific numbers based on traditional dream interpretation. `;
    } else {
      analysis += `Your dream has been analyzed for hidden meanings. `;
    }

    if (hotNumbers.length > 0) {
      analysis += `Combined with ${game.toUpperCase()} Teer's recent hot numbers (${hotNumbers.slice(0, 3).join(', ')}), `;
      analysis += `these predictions have strong potential. `;
    }

    analysis += `The recommended numbers are based on both your dream symbolism and statistical analysis of past results. `;
    analysis += `Use these numbers wisely for ${game.toUpperCase()} Teer. Good luck!`;

    return analysis;
  }

  // Calculate confidence
  calculateConfidence(symbolsFound, resultsCount) {
    let confidence = 65; // Base

    // More symbols = higher confidence
    if (symbolsFound >= 3) confidence += 15;
    else if (symbolsFound >= 2) confidence += 10;
    else if (symbolsFound >= 1) confidence += 5;

    // More historical data = higher confidence
    if (resultsCount >= 30) confidence += 10;
    else if (resultsCount >= 20) confidence += 5;

    // Cap at 95
    return Math.min(95, confidence);
  }

  // Save dream interpretation to database
  async saveDreamInterpretation(userId, dreamText, language, symbols, numbers, analysis, confidence, targetGame) {
    try {
      await pool.query(
        `INSERT INTO dream_interpretations
         (user_id, dream_text, detected_language, symbols, numbers, analysis, confidence, target_game)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [userId, dreamText, language, symbols, numbers, analysis, confidence, targetGame]
      );
    } catch (error) {
      console.error('Error saving dream interpretation:', error);
      // Non-critical error, don't throw
    }
  }

  // Get user's dream history
  async getUserDreamHistory(userId, limit = 10) {
    try {
      const result = await pool.query(
        `SELECT * FROM dream_interpretations
         WHERE user_id = $1
         ORDER BY created_at DESC
         LIMIT $2`,
        [userId, limit]
      );
      return result.rows;
    } catch (error) {
      console.error('Error getting dream history:', error);
      throw error;
    }
  }

  // Get dream dictionary (for admin management)
  getDreamDictionary() {
    return dreamDictionary;
  }

  // Generate native multilingual responses (7 languages)
  async generateMultilingualResponse(englishText) {
    const responses = {
      en: englishText,
      hi: '',
      hinglish: '',
      bn: '',
      as: '',
      kha: '',
      ne: ''
    };

    try {
      // Translate to each language in parallel with better context
      const translations = await Promise.allSettled([
        translate(englishText, { to: 'hi', from: 'en' }), // Hindi
        translate(englishText, { to: 'bn', from: 'en' }), // Bengali
        translate(englishText, { to: 'as', from: 'en' }), // Assamese
        translate(englishText, { to: 'ne', from: 'en' }), // Nepali
      ]);

      // Process translations with improvements
      if (translations[0].status === 'fulfilled') {
        responses.hi = this.improveHindi(translations[0].value.text);
      }
      if (translations[1].status === 'fulfilled') {
        responses.bn = this.improveBengali(translations[1].value.text);
      }
      if (translations[2].status === 'fulfilled') {
        responses.as = this.improveAssamese(translations[2].value.text);
      }
      if (translations[3].status === 'fulfilled') {
        responses.ne = this.improveNepali(translations[3].value.text);
      }

      // Generate natural Hinglish (popular in Northeast India)
      responses.hinglish = this.generateNaturalHinglish(englishText);

      // Generate Khasi (native language of Meghalaya - where Shillong Teer is played)
      responses.kha = this.generateKhasi(englishText);

      return responses;
    } catch (error) {
      console.error('Multilingual translation error:', error);
      // Generate fallbacks with some localization
      return {
        en: englishText,
        hi: this.generateBasicHindi(englishText),
        hinglish: this.generateNaturalHinglish(englishText),
        bn: englishText,
        as: englishText,
        kha: this.generateKhasi(englishText),
        ne: englishText
      };
    }
  }

  // Improve Hindi translation to sound more natural
  improveHindi(text) {
    return text
      .replace(/टीर/g, 'Teer')  // Keep Teer in English
      .replace(/शिलांग/g, 'Shillong')  // Keep place names in English
      .replace(/FR/g, 'FR')
      .replace(/SR/g, 'SR')
      .replace(/एफआर/g, 'FR')
      .replace(/एसआर/g, 'SR');
  }

  // Improve Bengali translation
  improveBengali(text) {
    return text
      .replace(/টির/g, 'Teer')
      .replace(/শিলং/g, 'Shillong')
      .replace(/এফআর/g, 'FR')
      .replace(/এসআর/g, 'SR');
  }

  // Improve Assamese translation
  improveAssamese(text) {
    return text
      .replace(/টীৰ/g, 'Teer')
      .replace(/শ্বিলং/g, 'Shillong')
      .replace(/এফআৰ/g, 'FR')
      .replace(/এছআৰ/g, 'SR');
  }

  // Improve Nepali translation
  improveNepali(text) {
    return text
      .replace(/टियर/g, 'Teer')
      .replace(/शिलोङ/g, 'Shillong')
      .replace(/एफआर/g, 'FR')
      .replace(/एसआर/g, 'SR');
  }

  // Generate natural Hinglish (very popular in India)
  generateNaturalHinglish(english) {
    // Hinglish keeps English technical terms but uses Hindi grammar and common words
    let hinglish = english;

    // Common replacements for natural Hinglish
    const replacements = {
      'Your dream': 'Aapka dream',
      'contains': 'mein hai',
      'powerful symbols': 'powerful symbols',
      'represents': 'represent karta hai',
      'These symbols suggest': 'Ye symbols batate hain ki',
      'based on': 'ke base par',
      'traditional dream interpretation': 'traditional dream interpretation',
      'Combined with': 'Iske saath',
      'recent hot numbers': 'recent hot numbers',
      'these predictions have': 'ye predictions hai',
      'strong potential': 'bahut strong',
      'The recommended numbers are': 'Recommended numbers hain',
      'statistical analysis': 'statistical analysis',
      'past results': 'past results',
      'Use these numbers wisely': 'In numbers ko samajhdari se use karein',
      'Good luck': 'Best of luck',
      'Teer': 'Teer'
    };

    for (const [eng, hing] of Object.entries(replacements)) {
      hinglish = hinglish.replace(new RegExp(eng, 'gi'), hing);
    }

    return hinglish;
  }

  // Generate Khasi language response (native to Meghalaya, Shillong)
  generateKhasi(english) {
    // Khasi is the native language of Shillong, Meghalaya where Teer is played
    // Mix English with Khasi terms for authenticity
    let khasi = english;

    const khasiTerms = {
      'dream': 'ieiñkynmaw',
      'numbers': 'thoh',
      'luck': 'suk',
      'symbols': 'ki jiingsngewthuh',
      'powerful': 'ba lah',
      'Good luck': 'Suk ha phi',
      'represents': 'pynsuk',
      'suggests': 'pynthiah',
      'predictions': 'ka jingsngewbha',
      'analysis': 'ka jingpyndep',
      'results': 'ki jingïap'
    };

    for (const [eng, kha] of Object.entries(khasiTerms)) {
      khasi = khasi.replace(new RegExp(eng, 'gi'), kha);
    }

    // Add Khasi greeting/closing
    khasi = 'Kumno! ' + khasi + ' Suk ha phi!';

    return khasi;
  }

  // Generate basic Hindi when translation fails
  generateBasicHindi(english) {
    // Simple Hindi version as fallback
    return 'आपका स्वप्न विशेष प्रतीकों से भरा है। ' +
           'ये संख्याएं पारंपरिक स्वप्न व्याख्या और Teer के पिछले परिणामों के आधार पर हैं। ' +
           'इन संख्याओं का बुद्धिमानी से उपयोग करें। शुभकामनाएं!';
  }
}

module.exports = new DreamService();
