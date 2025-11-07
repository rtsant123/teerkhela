const axios = require('axios');
const cheerio = require('cheerio');
const Result = require('../models/Result');
const Game = require('../models/Game');

class ScraperService {
  constructor() {
    this.baseUrl = process.env.TEER_RESULTS_URL || 'https://teerresults.com';
    this.cache = new Map();
    this.cacheExpiry = 5 * 60 * 1000; // 5 minutes
  }

  // Scrape results from teerresults.com
  async scrapeResults() {
    try {
      console.log('🔍 Starting to scrape Teer results...');

      const today = new Date().toISOString().split('T')[0];
      const results = {};

      // Get all active games with scraping enabled from database
      const games = await Game.getActiveScrapableGames();

      console.log(`Found ${games.length} games to scrape`);

      // Scrape each game
      for (const game of games) {
        try {
          const result = await this.scrapeGame(game.scrape_url, game.name);
          if (result) {
            results[game.name] = result;
            // Save to database
            await Result.upsert(
              game.name,
              today,
              result.fr,
              result.sr,
              result.declaredTime,
              true
            );
          }
        } catch (error) {
          console.error(`Error scraping ${game.name}:`, error.message);
        }
      }

      console.log(`✅ Scraped results for ${Object.keys(results).length} games`);
      return results;
    } catch (error) {
      console.error('❌ Error in scrapeResults:', error);
      throw error;
    }
  }

  // Scrape individual game
  async scrapeGame(gameUrl, gameName) {
    try {
      const url = `${this.baseUrl}/${gameUrl}`;
      const response = await axios.get(url, {
        timeout: 10000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
      });

      const $ = cheerio.load(response.data);

      // Different scraping strategies based on website structure
      // This is a generic approach - adjust selectors based on actual website
      let fr = null;
      let sr = null;
      let declaredTime = null;

      // Try to find FR (First Round)
      const frElement = $('.result-fr, .first-round, [data-result="fr"]').first().text();
      if (frElement) {
        fr = this.extractNumber(frElement);
      }

      // Try to find SR (Second Round)
      const srElement = $('.result-sr, .second-round, [data-result="sr"]').first().text();
      if (srElement) {
        sr = this.extractNumber(srElement);
      }

      // Try to find declared time
      const timeElement = $('.result-time, .declared-time, time').first().text();
      if (timeElement) {
        declaredTime = this.extractTime(timeElement);
      }

      // If no results found, return null
      if (fr === null && sr === null) {
        console.log(`No results found for ${gameName} yet`);
        return null;
      }

      return {
        game: gameName,
        fr,
        sr,
        declaredTime
      };
    } catch (error) {
      console.error(`Error scraping ${gameName}:`, error.message);
      return null;
    }
  }

  // Fetch from WordPress API (for Bhutan and Assam games)
  async fetchWordPressResults() {
    try {
      const wpUrl = process.env.WORDPRESS_API_URL;
      if (!wpUrl) {
        console.log('WordPress API URL not configured');
        return {};
      }

      const response = await axios.get(`${wpUrl}/teer-results`, {
        timeout: 10000
      });

      const results = {};
      const today = new Date().toISOString().split('T')[0];

      // Assuming WordPress returns array of result objects
      if (response.data && Array.isArray(response.data)) {
        for (const item of response.data) {
          const game = item.game || item.title?.toLowerCase().replace(/\s+/g, '-');
          if (game && (game.includes('bhutan') || game.includes('assam'))) {
            results[game] = {
              game: game,
              fr: item.fr || item.first_round,
              sr: item.sr || item.second_round,
              declaredTime: item.time
            };

            // Save to database
            await Result.upsert(
              game,
              today,
              results[game].fr,
              results[game].sr,
              results[game].declaredTime,
              true
            );
          }
        }
      }

      console.log(`✅ Fetched WordPress results for ${Object.keys(results).length} games`);
      return results;
    } catch (error) {
      console.error('Error fetching WordPress results:', error.message);
      return {};
    }
  }

  // Get all current results (from cache or database)
  async getAllResults() {
    try {
      // Check cache first
      const cacheKey = 'all_results';
      if (this.cache.has(cacheKey)) {
        const cached = this.cache.get(cacheKey);
        if (Date.now() - cached.timestamp < this.cacheExpiry) {
          return cached.data;
        }
      }

      // Get from database
      const results = await Result.getTodayResults();

      // Cache the results
      this.cache.set(cacheKey, {
        data: results,
        timestamp: Date.now()
      });

      return results;
    } catch (error) {
      console.error('Error getting all results:', error);
      throw error;
    }
  }

  // Extract number from text
  extractNumber(text) {
    if (!text) return null;
    const match = text.match(/\d+/);
    return match ? parseInt(match[0]) : null;
  }

  // Extract time from text
  extractTime(text) {
    if (!text) return null;
    const match = text.match(/(\d{1,2}):(\d{2})\s*(AM|PM)?/i);
    if (match) {
      return match[0];
    }
    return text.trim();
  }

  // Clear cache
  clearCache() {
    this.cache.clear();
  }

  // Manual entry (for admin to add results)
  async manualEntry(game, date, fr, sr, declaredTime) {
    try {
      await Result.upsert(game, date, fr, sr, declaredTime, false);
      this.clearCache(); // Clear cache when manual entry
      console.log(`✅ Manual entry saved for ${game} on ${date}`);
      return { success: true };
    } catch (error) {
      console.error('Error in manual entry:', error);
      throw error;
    }
  }
}

module.exports = new ScraperService();
