const { pool } = require('../config/database');

class AppConfig {
  /**
   * Get app configuration
   * Controls features, promotions, pricing, etc.
   */
  static async getConfig() {
    try {
      const query = `
        SELECT * FROM app_config
        WHERE is_active = true
        ORDER BY created_at DESC
        LIMIT 1
      `;
      const result = await pool.query(query);

      if (result.rows.length === 0) {
        // Return default config
        return this.getDefaultConfig();
      }

      return result.rows[0];
    } catch (error) {
      console.error('Error getting app config:', error);
      throw error;
    }
  }

  /**
   * Update app configuration
   */
  static async updateConfig(config) {
    try {
      // Deactivate all previous configs
      await pool.query('UPDATE app_config SET is_active = false');

      // Insert new config
      const query = `
        INSERT INTO app_config (
          config_data,
          is_active,
          updated_by
        ) VALUES ($1, true, $2)
        RETURNING *
      `;

      const result = await pool.query(query, [
        JSON.stringify(config),
        config.updatedBy || 'admin'
      ]);

      return result.rows[0];
    } catch (error) {
      console.error('Error updating app config:', error);
      throw error;
    }
  }

  /**
   * Default configuration
   */
  static getDefaultConfig() {
    return {
      // Pricing (3 Flexible Models)
      pricing: {
        weekly: {
          enabled: true,
          name: 'Weekly Plan',
          price: 49,
          originalPrice: 99,
          discount: 50,
          duration: 'weekly',
          durationDays: 7,
          razorpayPlanId: '', // Set in Razorpay dashboard
          features: [
            '10-number AI predictions',
            '7-day result history',
            'Dream AI (5/day)',
            'Common numbers analysis',
            'Community forum access',
            'Accuracy stats dashboard'
          ],
          badge: '🔥 Popular',
          highlightColor: '#F59E0B'
        },
        monthly: {
          enabled: true,
          name: 'Monthly Plan',
          price: 99,
          originalPrice: 199,
          discount: 50,
          duration: 'monthly',
          durationDays: 30,
          razorpayPlanId: '',
          features: [
            'Everything in Weekly',
            '30-day result history',
            'Dream AI (15/day)',
            'Advanced analytics',
            'Priority support',
            'Ad-free experience'
          ],
          badge: '⭐ Best Value',
          highlightColor: '#10B981'
        },
        yearly: {
          enabled: true,
          name: 'Yearly Plan',
          price: 999,
          originalPrice: 2499,
          discount: 60,
          duration: 'yearly',
          durationDays: 365,
          razorpayPlanId: '',
          features: [
            'Everything in Monthly',
            'Unlimited Dream AI',
            '1-year result history',
            'Early access to features',
            'VIP badge 👑',
            'Exclusive community',
            'Personal support'
          ],
          badge: '💎 Save ₹1,500',
          highlightColor: '#9333EA'
        }
      },

      // Promotions & FOMO Tactics
      promotions: {
        banner: {
          enabled: true,
          text: '🔥 LIMITED TIME: 50% OFF All Plans! Only 24 hours left!',
          type: 'success', // success, warning, info
          link: '/subscribe',
          countdown: true, // Show countdown timer
          countdownHours: 24
        },
        popup: {
          enabled: true,
          title: '⚡ Special Offer Just For You!',
          message: '95 users upgraded in last 24 hours. Don\'t miss out!',
          buttonText: 'Claim 50% Discount',
          showAfterSeconds: 10,
          showAgainAfterHours: 6 // Show popup again after 6 hours
        },
        floatingBadge: {
          enabled: true,
          text: '🎯 89% Accuracy Today!',
          position: 'top' // top, bottom
        },
        urgencyMessages: [
          '⏰ Offer ends in {hours} hours',
          '🔥 {count} people viewing this offer',
          '✅ {count} users upgraded today',
          '💎 Only {slots} premium slots left'
        ],
        socialProof: {
          enabled: true,
          messages: [
            'Raj from Mumbai just upgraded to Premium',
            'Priya from Delhi won ₹5,000 using predictions',
            'Amit from Kolkata got 3 hits in a row!'
          ],
          intervalSeconds: 30
        },
        referralBonus: {
          enabled: true,
          daysPerReferral: 5,
          maxReferrals: 50,
          bonusMessage: '🎁 Get 5 FREE days for each friend!'
        }
      },

      // Features Control
      features: {
        predictions: {
          enabled: true,
          freePreview: true, // Show blurred preview to free users
          numbersCount: 10,
          confidenceBoost: 5, // Add +5% to displayed confidence
          showLiveAccuracy: true // Show "Live Accuracy: 87%" badge
        },
        dreamAI: {
          enabled: true,
          freeLimit: 0, // Free users: 0 uses/day
          weeklyLimit: 5,
          monthlyLimit: 15,
          yearlyLimit: -1, // Unlimited
          varietyMode: true, // Generate varied predictions
          minDifferentNumbers: 3, // At least 3 different numbers
          personalizedMode: true // Use dream keywords for variation
        },
        forum: {
          enabled: true,
          freeCanPost: false, // Only premium can post
          freeCanView: true,
          showPopularBadge: true, // Show "🔥 Trending" on popular posts
          highlightHitPredictions: true // Highlight posts with successful predictions
        },
        commonNumbers: {
          enabled: true,
          requiresPremium: true,
          showHotColdIndicator: true, // Visual hot/cold indicators
          addVariety: true // Mix historical data with randomness
        },
        accuracyStats: {
          enabled: true,
          requiresPremium: false,
          displayMode: 'boosted', // 'real', 'boosted', 'custom'
          boostPercentage: 8, // Show +8% higher accuracy
          minimumAccuracy: 65, // Never show below 65%
          showTrending: true // Show "📈 Accuracy improving!"
        },
        referralProgram: {
          enabled: true,
          requiresPremium: false,
          showLeaderboard: true,
          topReferrersCount: 10
        }
      },

      // User Flow Control
      userFlow: {
        onboarding: {
          enabled: true,
          screens: ['welcome', 'predictions', 'premium']
        },
        forceUpdate: {
          enabled: false,
          minVersion: '1.0.0',
          message: 'Please update to the latest version'
        },
        maintenance: {
          enabled: false,
          message: 'App is under maintenance. We\'ll be back soon!',
          estimatedTime: '2 hours'
        }
      },

      // Games Control
      games: {
        shillong: { enabled: true, order: 1 },
        khanapara: { enabled: true, order: 2 },
        juwai: { enabled: true, order: 3 },
        'shillong-morning': { enabled: true, order: 4 },
        'khanapara-morning': { enabled: true, order: 5 },
        'juwai-morning': { enabled: true, order: 6 }
      },

      // Notifications
      notifications: {
        resultsUpdate: true,
        newPredictions: true,
        promotions: true,
        referralRewards: true
      },

      // App Behavior
      behavior: {
        showAds: {
          freeUsers: true,
          premiumUsers: false
        },
        subscriptionPrompt: {
          enabled: true,
          showAfterActions: 3, // Show after 3 actions
          actions: ['view_prediction', 'use_dream_ai', 'view_forum']
        }
      }
    };
  }
}

module.exports = AppConfig;
