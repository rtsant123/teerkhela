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
