const PromoCode = require('../models/PromoCode');

async function migrate() {
  try {
    console.log('Creating promo codes table...');
    await PromoCode.createTable();

    // Create a test promo code with 100% discount for testing
    console.log('Creating TEST100 promo code for testing...');
    try {
      await PromoCode.create({
        code: 'TEST100',
        discount_percent: 100,
        max_uses: null, // Unlimited uses
        valid_until: null, // Never expires
        description: 'Testing promo code - 100% discount',
        created_by: 'system'
      });
      console.log('✓ TEST100 promo code created (100% discount, unlimited uses)');
    } catch (error) {
      if (error.code === '23505') { // Unique violation
        console.log('✓ TEST100 promo code already exists');
      } else {
        throw error;
      }
    }

    console.log('Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

migrate();
