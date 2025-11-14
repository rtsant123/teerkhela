# Play Console: Create Subscription Products

## STEP-BY-STEP GUIDE

### STEP 1: Access Play Console
1. Go to: https://play.google.com/console
2. Select your app: **Teer Khela**
3. Navigate to: **Monetize → Products → Subscriptions**

### STEP 2: Create Monthly Subscription

Click "Create subscription" and fill in:

**Base Settings:**
- Product ID: `premium_monthly` ⚠️ **MUST MATCH EXACTLY**
- Name: `Monthly Premium`
- Description: `Premium access with AI predictions, dream bot, and ad-free experience`

**Pricing:**
1. Click "Add base plan"
2. Base plan ID: `monthly-base`
3. Billing period: **1 month**
4. Renewal type: **Prepaid** (user pays upfront)
5. Auto-renewing: **Yes**

**Set Price:**
1. Click "Set prices"
2. Select "India" as primary country
3. Enter price: **₹99.00**
4. Google will auto-convert to other currencies
5. Click "Apply prices"

**Free Trial (Optional):**
1. Offer eligible users: **7 days free trial**
2. This helps with conversions!

**Activate:**
- Review all details
- Click "Activate" (bottom right)

---

### STEP 3: Create Quarterly Subscription

Click "Create subscription" again:

**Base Settings:**
- Product ID: `premium_quarterly` ⚠️ **MUST MATCH EXACTLY**
- Name: `Quarterly Premium`
- Description: `3 months of premium access - Save 12% compared to monthly!`

**Pricing:**
- Base plan ID: `quarterly-base`
- Billing period: **3 months**
- Renewal type: **Prepaid**
- Auto-renewing: **Yes**

**Set Price:**
- India: **₹249.00**
- Savings: ₹48 compared to 3x monthly (₹297)

**Free Trial:**
- 7 days free trial

**Activate:**
- Click "Activate"

---

### STEP 4: Create Annual Subscription

Click "Create subscription" again:

**Base Settings:**
- Product ID: `premium_annual` ⚠️ **MUST MATCH EXACTLY**
- Name: `Annual Premium`
- Description: `12 months of premium access - Best value! Save 15%`

**Pricing:**
- Base plan ID: `annual-base`
- Billing period: **12 months**
- Renewal type: **Prepaid**
- Auto-renewing: **Yes**

**Set Price:**
- India: **₹999.00**
- Savings: ₹189 compared to 12x monthly (₹1,188)

**Free Trial:**
- 7 days free trial

**Activate:**
- Click "Activate"

---

## STEP 5: Verify Products Created

After creating all 3 subscriptions, verify:

| Product ID | Price | Duration | Savings |
|-----------|-------|----------|---------|
| premium_monthly | ₹99 | 1 month | - |
| premium_quarterly | ₹249 | 3 months | 16% |
| premium_annual | ₹999 | 12 months | 16% |

All should show status: **Active** ✅

---

## STEP 6: Set Up Test Accounts

For testing without real charges:

1. Go to: **Setup → License testing**
2. Add test emails (max 100):
   ```
   your-email@gmail.com
   tester1@gmail.com
   tester2@gmail.com
   ```
3. Click "Save changes"

**Important:** These test accounts can:
- Make purchases for free
- Subscriptions auto-renew every 5 minutes (for testing)
- Access full app features

---

## STEP 7: Configure Real-time Notifications

1. Go to: **Monetization → Monetization setup**
2. Click "Real-time developer notifications"
3. Topic name: Create new topic or use existing
4. Enable notifications for:
   - ✅ Subscription purchased
   - ✅ Subscription renewed
   - ✅ Subscription canceled
   - ✅ Subscription expired
   - ✅ Subscription recovered

---

## WHAT HAPPENS AFTER ACTIVATION?

### For Users:
- See all 3 subscription options in your app
- Can choose monthly, quarterly, or annual
- Payment processed via Google Play
- Subscription auto-renews until canceled
- Can cancel anytime in Play Store

### For You:
- Google handles all billing
- Auto-renewal management
- Failed payment recovery
- Subscription management
- Monthly payouts to your bank

---

## PRICING COMPARISON

| Plan | Price | Per Month | You Receive* | Google Takes* |
|------|-------|-----------|--------------|---------------|
| Monthly | ₹99 | ₹99 | ₹84.15 | ₹14.85 (15%) |
| Quarterly | ₹249 | ₹83 | ₹211.65 | ₹37.35 (15%) |
| Annual | ₹999 | ₹83.25 | ₹849.15 | ₹149.85 (15%) |

*After Google's 15% commission for first $1M revenue

---

## SUBSCRIPTION FEATURES BREAKDOWN

**Monthly Premium (₹99/month):**
- All AI predictions unlocked
- Dream dictionary bot (unlimited)
- Lucky VIP numbers
- Formula calculator
- Ad-free experience
- Priority support

**Quarterly Premium (₹249/3 months):**
- All Monthly features
- Save ₹48 (16% off)
- Better value for regular users

**Annual Premium (₹999/year):**
- All Monthly features
- Save ₹189 (16% off)
- Best value
- Most popular choice

---

## TESTING CHECKLIST

Before going live:

1. ✅ All 3 products created and active
2. ✅ Test accounts configured
3. ✅ Build app and upload to Internal Testing
4. ✅ Download app from Play Store (not sideloaded APK)
5. ✅ Test purchase flow with test account
6. ✅ Verify premium features unlock
7. ✅ Test subscription cancellation
8. ✅ Check backend receives purchase token
9. ✅ Verify database entry created
10. ✅ Test "Restore Purchases" button

---

## COMMON ISSUES

**Products not showing in app:**
- Make sure all 3 products are "Active"
- Wait 2-3 hours for Google Play cache to update
- Clear Play Store cache on device
- Reinstall app from Play Store

**Test purchases not working:**
- Verify test account is added to License testing
- Download app from Play Store (not sideloaded)
- Must be signed release build (not debug)
- Check Play Console for error messages

**Backend verification failing:**
- Check service account has correct permissions
- Verify credentials file uploaded to Railway
- Check Railway logs for errors
- Test with "Send test notification" in Play Console

---

## REVENUE ESTIMATES

If you get 1000 subscribers:

| Scenario | Monthly Revenue | Annual Revenue |
|----------|----------------|----------------|
| All monthly (₹99) | ₹84,150 | ₹10,09,800 |
| All quarterly (₹249) | ₹70,550 | ₹8,46,600 |
| All annual (₹999) | ₹70,762 | ₹8,49,150 |
| Mixed (30% each tier) | ₹75,154 | ₹9,01,850 |

*After Google's 15% commission

---

## IMPORTANT REMINDERS

1. ⚠️ Product IDs CANNOT be changed once created
2. ⚠️ Test before launching to production
3. ⚠️ Users manage subscriptions in Play Store (not in your app)
4. ⚠️ Always verify purchases on backend (prevent fraud)
5. ⚠️ Respect grace periods for failed payments
6. ⚠️ Free trials count as active subscriptions

---

## NEXT STEPS AFTER SETUP

1. Create the 3 subscriptions in Play Console (30 mins)
2. Add test accounts (5 mins)
3. Update backend with verification code (1 hour)
4. Build signed APK/AAB
5. Upload to Internal Testing track
6. Test subscription flow (30 mins)
7. Upload to Production

**Total time: 2-3 hours**

Ready to get started? Follow each step carefully and you'll be live soon!
