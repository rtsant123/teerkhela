# Backend: Google Play Purchase Verification

## OVERVIEW
Your Railway backend needs to verify Google Play purchases to prevent fraud and activate premium subscriptions.

## STEP 1: Get Google Play Service Account

### A. Go to Google Play Console
1. Open: https://play.google.com/console
2. Select your app "Teer Khela"
3. Navigate to: **Setup → API access**

### B. Create Service Account
1. Click "Create new service account"
2. This will redirect you to Google Cloud Console
3. Click "Create Service Account"
4. Service account name: `teerkhela-billing`
5. Description: "Verifies Google Play purchases"
6. Click "Create and Continue"
7. Grant role: **Pub/Sub Admin** (required for notifications)
8. Click "Continue" → "Done"

### C. Generate JSON Key
1. Back in Google Cloud Console
2. Find your service account in the list
3. Click on it → Click "Keys" tab
4. Click "Add Key" → "Create new key"
5. Choose "JSON" format
6. Click "Create"
7. **SAVE THIS FILE SECURELY** - This is your credentials

### D. Enable API Access
1. Back to Play Console → API access
2. Find your service account in the list
3. Click "Grant access"
4. Permissions needed:
   - ✅ View financial data
   - ✅ Manage orders and subscriptions
5. Click "Save changes"

## STEP 2: Install Required Packages

Add to your Railway backend `package.json`:

```bash
npm install googleapis
npm install google-auth-library
```

## STEP 3: Add Environment Variables

Add to Railway environment variables:

```
GOOGLE_APPLICATION_CREDENTIALS=./google-play-credentials.json
GOOGLE_PLAY_PACKAGE_NAME=com.teerkhela.app
```

Upload the JSON credentials file to Railway.

## STEP 4: Create Verification Endpoint

Create new file: `routes/googlePlayVerification.js`

```javascript
const express = require('express');
const router = express.Router();
const { google } = require('googleapis');
const pool = require('../db');

// Initialize Google Play Developer API
const androidPublisher = google.androidpublisher({
  version: 'v3',
  auth: new google.auth.GoogleAuth({
    keyFile: process.env.GOOGLE_APPLICATION_CREDENTIALS,
    scopes: ['https://www.googleapis.com/auth/androidpublisher'],
  }),
});

const PACKAGE_NAME = process.env.GOOGLE_PLAY_PACKAGE_NAME || 'com.teerkhela.app';

/**
 * Verify Google Play subscription purchase
 * POST /api/subscriptions/verify-google-play
 *
 * Body: {
 *   purchase_token: string,
 *   product_id: string,
 *   device_id: string
 * }
 */
router.post('/verify-google-play', async (req, res) => {
  try {
    const { purchase_token, product_id, device_id } = req.body;

    // Validate request
    if (!purchase_token || !product_id || !device_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: purchase_token, product_id, device_id'
      });
    }

    console.log(`🔍 Verifying Google Play purchase for device: ${device_id}`);

    // Step 1: Verify purchase with Google Play
    let subscriptionData;
    try {
      const response = await androidPublisher.purchases.subscriptionsv2.get({
        packageName: PACKAGE_NAME,
        token: purchase_token,
      });

      subscriptionData = response.data;
      console.log('✅ Google Play verification successful:', subscriptionData);
    } catch (googleError) {
      console.error('❌ Google Play verification failed:', googleError.message);

      // Check if it's a "not found" error (invalid/expired token)
      if (googleError.code === 404) {
        return res.status(400).json({
          success: false,
          message: 'Invalid or expired purchase. Please try again.'
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Failed to verify purchase with Google Play'
      });
    }

    // Step 2: Check subscription status
    const subscriptionState = subscriptionData.subscriptionState;

    // Valid states: SUBSCRIPTION_STATE_ACTIVE, SUBSCRIPTION_STATE_PAUSED, SUBSCRIPTION_STATE_IN_GRACE_PERIOD
    const isActive = [
      'SUBSCRIPTION_STATE_ACTIVE',
      'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
      'SUBSCRIPTION_STATE_PAUSED'
    ].includes(subscriptionState);

    if (!isActive) {
      console.log(`❌ Subscription not active. State: ${subscriptionState}`);
      return res.status(400).json({
        success: false,
        message: 'Subscription is not active'
      });
    }

    // Step 3: Get expiry date
    const lineItems = subscriptionData.lineItems || [];
    if (lineItems.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No line items found in subscription'
      });
    }

    const expiryTime = lineItems[0].expiryTime;
    const expiryDate = new Date(expiryTime);

    // Step 4: Calculate plan duration
    let planDuration = 'monthly';
    switch (product_id) {
      case 'premium_monthly':
        planDuration = 'monthly';
        break;
      case 'premium_quarterly':
        planDuration = 'quarterly';
        break;
      case 'premium_annual':
        planDuration = 'annual';
        break;
    }

    // Step 5: Check if subscription already exists in database
    const existingSubscription = await pool.query(
      'SELECT * FROM subscriptions WHERE purchase_token = $1',
      [purchase_token]
    );

    let subscription;

    if (existingSubscription.rows.length > 0) {
      // Update existing subscription
      const updateResult = await pool.query(
        `UPDATE subscriptions
         SET status = 'active',
             expires_at = $1,
             updated_at = NOW()
         WHERE purchase_token = $2
         RETURNING *`,
        [expiryDate, purchase_token]
      );

      subscription = updateResult.rows[0];
      console.log('✅ Updated existing subscription:', subscription.id);
    } else {
      // Create new subscription
      const insertResult = await pool.query(
        `INSERT INTO subscriptions (
          device_id,
          plan_duration,
          status,
          payment_method,
          purchase_token,
          product_id,
          expires_at,
          created_at,
          updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
        RETURNING *`,
        [
          device_id,
          planDuration,
          'active',
          'google_play',
          purchase_token,
          product_id,
          expiryDate
        ]
      );

      subscription = insertResult.rows[0];
      console.log('✅ Created new subscription:', subscription.id);
    }

    // Step 6: Return success
    return res.status(200).json({
      success: true,
      message: 'Premium subscription activated successfully',
      subscription: {
        id: subscription.id,
        status: subscription.status,
        expires_at: subscription.expires_at,
        plan_duration: subscription.plan_duration
      }
    });

  } catch (error) {
    console.error('❌ Verification error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during verification'
    });
  }
});

/**
 * Handle Google Play Real-time Developer Notifications
 * POST /api/webhooks/google-play
 *
 * This endpoint receives automatic notifications from Google when:
 * - Subscription renewed
 * - Subscription cancelled
 * - Subscription expired
 * - Payment failed
 */
router.post('/webhooks/google-play', async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || !message.data) {
      return res.status(400).send('Invalid webhook payload');
    }

    // Decode base64 message
    const decodedData = Buffer.from(message.data, 'base64').toString('utf-8');
    const notification = JSON.parse(decodedData);

    console.log('📡 Received Google Play notification:', notification);

    const subscriptionNotification = notification.subscriptionNotification;
    if (!subscriptionNotification) {
      return res.status(200).send('OK'); // Not a subscription notification
    }

    const { purchaseToken, notificationType } = subscriptionNotification;

    // Handle different notification types
    switch (notificationType) {
      case 1: // SUBSCRIPTION_RECOVERED
        console.log('✅ Subscription recovered:', purchaseToken);
        await pool.query(
          `UPDATE subscriptions
           SET status = 'active', updated_at = NOW()
           WHERE purchase_token = $1`,
          [purchaseToken]
        );
        break;

      case 2: // SUBSCRIPTION_RENEWED
        console.log('✅ Subscription renewed:', purchaseToken);
        // Update expiry date by fetching from Google Play
        const response = await androidPublisher.purchases.subscriptionsv2.get({
          packageName: PACKAGE_NAME,
          token: purchaseToken,
        });
        const newExpiryTime = response.data.lineItems[0].expiryTime;
        await pool.query(
          `UPDATE subscriptions
           SET status = 'active', expires_at = $1, updated_at = NOW()
           WHERE purchase_token = $2`,
          [new Date(newExpiryTime), purchaseToken]
        );
        break;

      case 3: // SUBSCRIPTION_CANCELED
        console.log('❌ Subscription canceled:', purchaseToken);
        await pool.query(
          `UPDATE subscriptions
           SET status = 'canceled', updated_at = NOW()
           WHERE purchase_token = $1`,
          [purchaseToken]
        );
        break;

      case 13: // SUBSCRIPTION_EXPIRED
        console.log('❌ Subscription expired:', purchaseToken);
        await pool.query(
          `UPDATE subscriptions
           SET status = 'expired', updated_at = NOW()
           WHERE purchase_token = $1`,
          [purchaseToken]
        );
        break;

      default:
        console.log('ℹ️ Unhandled notification type:', notificationType);
    }

    // Always return 200 to acknowledge receipt
    return res.status(200).send('OK');

  } catch (error) {
    console.error('❌ Webhook error:', error);
    // Still return 200 to prevent Google from retrying
    return res.status(200).send('OK');
  }
});

module.exports = router;
```

## STEP 5: Update Main Server File

In your `server.js` or `index.js`:

```javascript
const googlePlayRoutes = require('./routes/googlePlayVerification');

// Add this route
app.use('/api/subscriptions', googlePlayRoutes);
app.use('/api/webhooks', googlePlayRoutes);
```

## STEP 6: Database Migration (if needed)

If your subscriptions table doesn't have these columns, add them:

```sql
-- Add columns for Google Play
ALTER TABLE subscriptions
ADD COLUMN IF NOT EXISTS purchase_token TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS product_id TEXT,
ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'razorpay';

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_purchase_token ON subscriptions(purchase_token);
CREATE INDEX IF NOT EXISTS idx_device_id ON subscriptions(device_id);
```

## STEP 7: Configure Webhook in Play Console

1. Go to Play Console → Monetization → Monetization setup
2. Click "Real-time developer notifications"
3. Enter webhook URL:
   ```
   https://teerkhela-production.up.railway.app/api/webhooks/google-play
   ```
4. Click "Send test notification" to verify
5. Check Railway logs for received notification

## STEP 8: Test the Flow

### Test Purchase Verification:

```bash
curl -X POST https://teerkhela-production.up.railway.app/api/subscriptions/verify-google-play \
  -H "Content-Type: application/json" \
  -d '{
    "purchase_token": "test_token_from_google",
    "product_id": "premium_monthly",
    "device_id": "test_device_123"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Premium subscription activated successfully",
  "subscription": {
    "id": 123,
    "status": "active",
    "expires_at": "2025-12-14T10:30:00.000Z",
    "plan_duration": "monthly"
  }
}
```

## TESTING NOTES:

1. **Test Accounts**: Add test emails in Play Console → License testing
2. **Test Subscriptions**: Auto-renew every 5 minutes for testing
3. **Sandbox Environment**: No real charges for test accounts
4. **Webhook Testing**: Use "Send test notification" in Play Console

## IMPORTANT SECURITY:

1. ✅ Never commit `google-play-credentials.json` to git
2. ✅ Store credentials in Railway environment variables
3. ✅ Add to `.gitignore`:
   ```
   google-play-credentials.json
   .env
   ```
4. ✅ Verify all purchase tokens with Google (don't trust client)
5. ✅ Use HTTPS for webhook endpoint (Railway provides this)

## COMMISSION BREAKDOWN:

For ₹99 monthly subscription:
- Google takes: ₹14.85 (15%)
- You receive: ₹84.15 (85%)

Google pays monthly via wire transfer to your bank account.

## TIMELINE:

1. ✅ Get service account credentials (30 mins)
2. ✅ Add code to backend (1 hour)
3. ✅ Deploy to Railway (10 mins)
4. ✅ Configure webhook (15 mins)
5. ✅ Test with test account (30 mins)

Total: ~2.5 hours

## HELP:

If you encounter issues:
- Check Railway logs: `railway logs`
- Verify credentials are uploaded
- Test with Play Console test notification
- Check database has required columns

Ready to implement this? Let me know if you need help with any step!
