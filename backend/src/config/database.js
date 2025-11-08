const { Pool } = require('pg');

// Create PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? {
    rejectUnauthorized: false
  } : false
});

// Test connection
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected database error:', err);
  process.exit(-1);
});

// Query helper function
const query = async (text, params) => {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log('Executed query', { text, duration, rows: res.rowCount });
    return res;
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
};

// Initialize database tables
const initDatabase = async () => {
  try {
    // Users table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(36) PRIMARY KEY,
        email VARCHAR(255),
        fcm_token TEXT,
        is_premium BOOLEAN DEFAULT false,
        subscription_id VARCHAR(255),
        expiry_date TIMESTAMP,
        device_info TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create index on email
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    `);

    // Results table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS results (
        id SERIAL PRIMARY KEY,
        game VARCHAR(50) NOT NULL,
        date DATE NOT NULL,
        fr INTEGER,
        sr INTEGER,
        declared_time TIME,
        is_auto BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(game, date)
      );
    `);

    // Create index on game and date
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_results_game_date ON results(game, date DESC);
    `);

    // Predictions table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS predictions (
        id SERIAL PRIMARY KEY,
        game VARCHAR(50) NOT NULL,
        date DATE NOT NULL,
        fr_numbers INTEGER[],
        sr_numbers INTEGER[],
        analysis TEXT,
        confidence INTEGER,
        posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(game, date)
      );
    `);

    // Dream interpretations table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS dream_interpretations (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(36) REFERENCES users(id),
        dream_text TEXT,
        detected_language VARCHAR(10),
        symbols TEXT[],
        numbers INTEGER[],
        analysis TEXT,
        confidence INTEGER,
        target_game VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Notifications table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        body TEXT NOT NULL,
        target VARCHAR(50) NOT NULL,
        action VARCHAR(50),
        screen VARCHAR(50),
        sent_count INTEGER DEFAULT 0,
        delivered_count INTEGER DEFAULT 0,
        opened_count INTEGER DEFAULT 0,
        sent_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Payments table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(36) REFERENCES users(id),
        subscription_id VARCHAR(255),
        payment_id VARCHAR(255),
        order_id VARCHAR(255),
        amount INTEGER NOT NULL,
        currency VARCHAR(3) DEFAULT 'INR',
        status VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Games table (dynamic game management)
    await pool.query(`
      CREATE TABLE IF NOT EXISTS games (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) UNIQUE NOT NULL,
        display_name VARCHAR(100) NOT NULL,
        region VARCHAR(50),
        scrape_url VARCHAR(255),
        is_active BOOLEAN DEFAULT true,
        scrape_enabled BOOLEAN DEFAULT false,
        fr_time TIME,
        sr_time TIME,
        display_order INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Insert default games if not exists
    await pool.query(`
      INSERT INTO games (name, display_name, region, scrape_url, is_active, scrape_enabled, display_order)
      VALUES
        ('shillong', 'Shillong Teer', 'Meghalaya', 'shillong-teer', true, true, 1),
        ('khanapara', 'Khanapara Teer', 'Assam', 'khanapara-teer', true, true, 2),
        ('juwai', 'Juwai Teer', 'Meghalaya', 'juwai-teer', true, true, 3),
        ('shillong-morning', 'Shillong Morning Teer', 'Meghalaya', 'shillong-morning', true, true, 4),
        ('juwai-morning', 'Juwai Morning Teer', 'Meghalaya', 'juwai-morning', true, true, 5),
        ('khanapara-morning', 'Khanapara Morning Teer', 'Assam', 'khanapara-morning', true, true, 6)
      ON CONFLICT (name) DO NOTHING;
    `);

    // Forum posts tables
    await pool.query(`
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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(post_id, user_id)
      );

      CREATE INDEX IF NOT EXISTS idx_likes_post ON forum_likes(post_id);
      CREATE INDEX IF NOT EXISTS idx_likes_user ON forum_likes(user_id);
    `);

    // Prediction results tracking table
    await pool.query(`
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
    `);

    // Referral tables
    await pool.query(`
      CREATE TABLE IF NOT EXISTS referrals (
        id SERIAL PRIMARY KEY,
        referrer_id VARCHAR(255) NOT NULL,
        referred_id VARCHAR(255) NOT NULL,
        referral_code VARCHAR(20) NOT NULL,
        reward_days INTEGER DEFAULT 5,
        is_claimed BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        claimed_at TIMESTAMP,
        FOREIGN KEY (referrer_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (referred_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(referred_id)
      );

      CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id);
      CREATE INDEX IF NOT EXISTS idx_referrals_code ON referrals(referral_code);

      CREATE TABLE IF NOT EXISTS referral_codes (
        id SERIAL PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL UNIQUE,
        code VARCHAR(20) NOT NULL UNIQUE,
        total_referrals INTEGER DEFAULT 0,
        total_rewards_days INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );

      CREATE INDEX IF NOT EXISTS idx_referral_codes_user ON referral_codes(user_id);
      CREATE INDEX IF NOT EXISTS idx_referral_codes_code ON referral_codes(code);
    `);

    // App Config Table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS app_config (
        id SERIAL PRIMARY KEY,
        config_data JSONB NOT NULL,
        is_active BOOLEAN DEFAULT true,
        updated_by VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log('✅ Database tables initialized successfully');
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    throw error;
  }
};

module.exports = {
  pool,
  query,
  initDatabase
};
