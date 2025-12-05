const PromoCode = require('../models/PromoCode');

async function migrate() {
  try {
    console.log('Creating promo codes table...');
    await PromoCode.createTable();

    // Create test promo codes
    const promoCodes = [
      {
        code: 'TEST100',
        discount_percent: 100,
        max_uses: null,
        valid_until: null,
        description: 'Testing promo code - 100% discount (free premium)',
        created_by: 'system'
      },
      {
        code: 'SAVE50',
        discount_percent: 50,
        max_uses: null,
        valid_until: null,
        description: '50% discount on all plans',
        created_by: 'system'
      },
      {
        code: 'SAVE25',
        discount_percent: 25,
        max_uses: null,
        valid_until: null,
        description: '25% discount on all plans',
        created_by: 'system'
      },
      {
        code: 'WELCOME',
        discount_percent: 30,
        max_uses: null,
        valid_until: null,
        description: 'Welcome discount - 30% off',
        created_by: 'system'
      }
    ];

    for (const promoData of promoCodes) {
      try {
        await PromoCode.create(promoData);
        console.log(`✓ ${promoData.code} promo code created (${promoData.discount_percent}% discount)`);
      } catch (error) {
        if (error.code === '23505') {
          console.log(`✓ ${promoData.code} promo code already exists`);
        } else {
          throw error;
        }
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
