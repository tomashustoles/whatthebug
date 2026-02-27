# App Store Connect Setup Guide - Products & Subscriptions

## Complete Setup for TestFlight & App Store Submission

---

## Part 1: Initial App Store Connect Setup

### Prerequisites
- [ ] Apple Developer Program membership ($99/year)
- [ ] App ID created in Certificates, Identifiers & Profiles
- [ ] Bundle ID matches your Xcode project

### Create Your App Listing

1. **Go to App Store Connect:**
   - https://appstoreconnect.apple.com
   - Sign in with your Apple Developer account

2. **Create New App:**
   - Click **My Apps**
   - Click **+** → **New App**
   - Fill in:
     - **Platform:** iOS
     - **Name:** WhatTheBug (or your app name)
     - **Primary Language:** English
     - **Bundle ID:** Select your app's bundle ID
     - **SKU:** Unique identifier (e.g., `whatthebug-001`)
     - **User Access:** Full Access
   - Click **Create**

---

## Part 2: Create In-App Purchases

### Setup One-Time Purchase (Non-Consumable)

1. **Navigate to In-App Purchases:**
   ```
   My Apps → [Your App] → Features → In-App Purchases → Click (+) or "Create"
   ```

2. **Select Type:**
   - Choose **Non-Consumable**
   - Click **Create**

3. **Fill Product Information:**

   **Reference Name:** `Unlock Single Bug Report`
   - This is internal only, users won't see it
   
   **Product ID:** `com.whatthebug.unlock.once`
   - ⚠️ **CRITICAL:** Must EXACTLY match `Configuration.swift`
   - Cannot be changed after creation
   - Must be unique across all your apps
   
   **Review Notes (Optional):**
   ```
   This non-consumable purchase unlocks the full bug identification report for a single analysis.
   ```

4. **Pricing and Availability:**
   - Click **Add Pricing**
   - Select **Manual Prices**
   - Choose **€2.99** (or select from price tier)
   - Select all territories or specific countries
   - Click **Next** → **Save**

5. **App Store Localization:**
   - Click **Add Localization**
   - **Language:** English (U.S.)
   
   **Display Name:** `Unlock This Bug`
   - Shows in purchase UI
   
   **Description:**
   ```
   Get complete information about this bug including habitat, life stage, how to locate it, and elimination methods.
   ```
   
   - Click **Save**

6. **App Store Promotion (Optional but Recommended):**
   - **Promotional Image:** Upload 1024x1024 image
   - Consider showing a preview of unlocked content

7. **Review Information:**
   - **Screenshot:** Upload screenshot showing the purchase flow
   - **Review Notes:**
   ```
   To test: Take or select a bug photo, wait for analysis, scroll to paywall section, select "THIS BUG" option, tap "Unlock Now".
   ```

8. **Click Save**

---

### Setup Auto-Renewable Subscription

1. **Navigate to Subscriptions:**
   ```
   My Apps → [Your App] → Features → Subscriptions → Click (+) or "Create"
   ```

2. **Create Subscription Group First:**
   - Click **Create Subscription Group** (if first subscription)
   - **Reference Name:** `Pro Features`
   - Click **Create**

3. **Add Subscription to Group:**
   - Inside your "Pro Features" group
   - Click **Create Subscription** or **+**

4. **Fill Subscription Information:**

   **Reference Name:** `Pro Monthly Subscription`
   - Internal use only
   
   **Product ID:** `com.whatthebug.pro.monthly`
   - ⚠️ **CRITICAL:** Must EXACTLY match `Configuration.swift`
   - Cannot be changed after creation
   
   **Subscription Duration:** `1 Month`
   
   **Review Notes (Optional):**
   ```
   Monthly subscription providing unlimited bug identifications with full reports.
   ```

5. **Subscription Pricing:**
   - Click **Add Subscription Price**
   - **Starting Price:** €4.99/month
   - **Select Territories:** All or specific countries
   - Click **Next** → **Save**

6. **Subscription Localization:**
   - Click **Add Localization**
   - **Language:** English (U.S.)
   
   **Display Name:** `WhatTheBug Pro`
   
   **Description:**
   ```
   Unlimited bug identifications with full reports including habitat information, life stages, location tips, and elimination methods. Subscribe and unlock all features.
   ```
   
   **Benefits (one per line):**
   ```
   Unlimited bug identifications
   Full detailed reports
   Habitat and life stage information
   How to locate and eliminate bugs
   Priority support
   ```
   
   - Click **Save**

7. **Subscription Group Display Name:**
   - Back in Subscription Group settings
   - Click **App Store Localization**
   - **Language:** English (U.S.)
   - **Subscription Group Display Name:** `Pro Features`
   - Click **Save**

8. **Review Information for Subscription:**
   - **Screenshot:** Upload screenshot of subscription purchase flow
   - **Review Notes:**
   ```
   To test: Take a bug photo, tap "ALL BUGS" option in paywall, tap "Unlock Now". Subscription provides unlimited access to all bug reports.
   ```

---

## Part 3: Submit Products for Review

### Before Submitting

**Check Your Products:**
- [ ] Product IDs match Configuration.swift EXACTLY
- [ ] Prices are set for all desired territories
- [ ] Display names and descriptions are clear
- [ ] Screenshots uploaded (if required)
- [ ] Review notes added

### Submit One-Time Purchase

1. Go to your non-consumable product
2. Ensure all fields are filled
3. Click **Submit for Review** button (top right)
4. In the modal:
   - Confirm information is correct
   - Click **Submit**

### Submit Subscription

1. Go to your subscription
2. Ensure all fields are filled
3. **Important:** Also review Subscription Group settings
4. Click **Submit for Review** (top right)
5. Click **Submit**

### Review Timeline

- ⏱️ **Typical Review Time:** 24-48 hours
- 🔄 **Can be rejected if:** Missing info, unclear description, no screenshots
- ✅ **Once approved:** Available for testing immediately

**Note:** You can test in local StoreKit Configuration before products are approved!

---

## Part 4: Create Sandbox Test Account

### Why You Need This
- Local StoreKit Configuration doesn't require it
- TestFlight testing DOES require it
- Can't use your real Apple ID for testing

### Create Sandbox Tester

1. **Go to App Store Connect:**
   - Users and Access (top menu)
   - Click **Sandbox** tab
   - Click **Testers** (left sidebar)

2. **Add New Sandbox Tester:**
   - Click **+** button
   - Fill in:
   
   **First Name:** `Test`
   
   **Last Name:** `User` (or anything)
   
   **Email:** 
   - Must be unique
   - Can be fake BUT must be unique in Apple's system
   - Format: `testuser+whatthebug@yourdomain.com`
   - Or use: `whatthebug.tester@gmail.com` (if available)
   
   **Password:** Create strong password (save it!)
   
   **Confirm Password:** Same password
   
   **Country/Region:** Your testing country
   
   **App Store Territory:** Same as region

3. **Click Save**

4. **Create Multiple Testers (Optional):**
   - Different regions for price testing
   - Different subscription states
   - Example:
     - `testuser+us@domain.com` (United States)
     - `testuser+eu@domain.com` (Germany/EU)
     - `testuser+uk@domain.com` (United Kingdom)

---

## Part 5: TestFlight Setup & Testing

### Upload Build to TestFlight

1. **In Xcode:**
   ```
   Product → Archive
   → Wait for archive to complete
   → Distribute App
   → App Store Connect
   → Upload
   → Sign and upload
   ```

2. **Wait for Processing:**
   - Takes 5-30 minutes
   - You'll get email when ready

### Configure TestFlight

1. **In App Store Connect:**
   ```
   My Apps → [Your App] → TestFlight tab
   ```

2. **Select Your Build:**
   - Click on the build number (e.g., 1.0 (1))

3. **Provide Export Compliance:**
   - "Does your app use encryption?" → Usually **NO** for most apps
   - If NO, click **No** → **Start Internal Testing**

4. **Add Internal Testers:**
   - Click **Internal Testing** (left sidebar)
   - Click **+ Add** next to testers
   - Add yourself and team members
   - They'll receive email with TestFlight invite

5. **External Testing (Optional):**
   - More public
   - Requires App Review
   - Can have up to 10,000 testers

### Test In TestFlight

1. **On Test Device:**
   - Install TestFlight app from App Store
   - Open email invite
   - Install your app from TestFlight

2. **Sign Out of Real App Store:**
   - Settings → [Your Name] → Media & Purchases → Sign Out
   - OR: Settings → App Store → Sign Out

3. **Launch Your App:**
   - Take a bug photo
   - Go to paywall
   - Tap "Unlock Now"

4. **When Purchase Sheet Appears:**
   - **DO NOT use your real Apple ID**
   - Look for **"Sign in with Apple ID"** button
   - Enter your **Sandbox Tester** credentials:
     - Email: `testuser+whatthebug@yourdomain.com`
     - Password: Your sandbox password
   - **Environment:** Should say "Sandbox" (blue badge)

5. **Complete Purchase:**
   - Tap Buy/Subscribe
   - May ask for password again
   - **No real money charged!**
   - Purchase completes

6. **Verify:**
   - Content unlocks
   - Pro badge appears
   - Test restore purchases
   - Delete and reinstall app, restore should work

### TestFlight Testing Checklist

- [ ] Build uploaded and processed
- [ ] Sandbox account created
- [ ] Signed out of real App Store on device
- [ ] TestFlight app installed
- [ ] App installed from TestFlight
- [ ] One-time purchase works
- [ ] Subscription purchase works
- [ ] Restore purchases works
- [ ] Content unlocks properly
- [ ] No crashes or errors

---

## Part 6: App Store Submission

### Final Preparations

1. **Ensure Products Are Approved:**
   - Check both products show "Ready to Submit" or "Approved"
   - If "Waiting for Review", wait for approval

2. **App Store Listing:**
   ```
   My Apps → [Your App] → App Store tab
   ```

3. **Fill Required Information:**

   **App Information:**
   - Name
   - Subtitle (optional but recommended)
   - Category: Utilities or Education
   - Age Rating: Complete questionnaire

   **Pricing and Availability:**
   - Price: Free (app is free, purchases are separate)
   - Availability: All countries or select specific

   **App Privacy:**
   - Click **Manage** on App Privacy
   - **Privacy Policy URL:** (you must have one!)
   - Click through privacy questionnaire
   - For bug ID app:
     - Do you collect data? **YES** (user content - photos)
     - Photos: Collected for app functionality
     - Not used for tracking
     - Not linked to user identity

4. **Prepare App Store Assets:**

   **Screenshots (Required):**
   - 6.7" display (iPhone 15 Pro Max): 1290 x 2796 pixels
   - 5.5" display (iPhone 8 Plus): 1242 x 2208 pixels
   - Take screenshots showing:
     1. Camera/main screen
     2. Analysis results with free content
     3. Paywall with purchase options
     4. Unlocked premium content
     5. Pro badge/features

   **App Preview Videos (Optional but Recommended):**
   - Show app in action
   - Max 30 seconds
   - Show camera → analysis → paywall → unlock

   **App Icon:**
   - 1024 x 1024 pixels
   - No alpha channel
   - No rounded corners (Apple adds them)

5. **Version Information:**

   **What's New in This Version:**
   ```
   Initial release of WhatTheBug - your AI-powered insect identification assistant!
   
   Features:
   • Instant bug identification using your camera
   • Detailed information about pest status and danger levels
   • Unlock full reports with habitat, life stage, and elimination tips
   • Pro subscription for unlimited identifications
   
   Start identifying bugs today!
   ```

   **Description:**
   ```
   Ever wondered what bug is crawling around your house? WhatTheBug uses advanced AI to instantly identify insects from your camera.
   
   FREE FEATURES:
   • Instant bug identification
   • Common and scientific names
   • Pest status
   • Danger level assessment
   
   PREMIUM FEATURES:
   • Detailed habitat information
   • Life stage identification
   • How to locate the bug
   • Safe elimination methods
   • Unlimited identifications with Pro subscription
   
   Simply take a photo and let WhatTheBug do the rest. Perfect for homeowners, gardeners, students, and nature enthusiasts.
   
   Choose from:
   • One-time unlock per bug (€2.99)
   • Pro subscription for unlimited access (€4.99/month)
   
   Your privacy matters: All analysis happens securely, and we never store your photos without permission.
   ```

   **Keywords:**
   ```
   bug,insect,identification,pest,nature,garden,spider,beetle,fly,mosquito
   ```

   **Support URL:** Your website or support page

   **Marketing URL (Optional):** Your marketing page

6. **App Review Information:**

   **Contact Information:**
   - First Name
   - Last Name
   - Phone Number
   - Email Address

   **Demo Account (If App Has Login):**
   - Not needed for this app

   **Notes:**
   ```
   WhatTheBug is an AI-powered insect identification app.
   
   TESTING THE PURCHASE FLOW:
   1. Take or select a bug photo
   2. Wait for AI analysis (2-5 seconds)
   3. Scroll down to see paywall section
   4. Tap "THIS BUG" option (one-time purchase)
   5. Tap "Unlock Now" to test purchase
   
   OR:
   
   4. Tap "ALL BUGS" option (subscription)
   5. Tap "Unlock Now" to test subscription
   
   Both purchases unlock premium content including habitat, life stage, location tips, and elimination methods.
   
   The "Restore Purchases" button allows users to restore previous purchases.
   
   OpenAI API Key is required for bug identification (included in build).
   ```

7. **Attach Build:**
   - Select your TestFlight build from dropdown
   - Must be the build you tested

8. **Export Compliance:**
   - Complete if not done in TestFlight

### Submit for Review

1. **Final Checks:**
   - [ ] All required fields filled
   - [ ] Screenshots uploaded
   - [ ] Build selected
   - [ ] Products approved and ready
   - [ ] Privacy policy URL added
   - [ ] Review notes detailed

2. **Click "Add for Review"** (top right)

3. **Review Summary:**
   - Check everything is correct
   - Click **Submit for Review**

4. **Wait for Review:**
   - Status changes to "Waiting for Review"
   - Then "In Review" (usually 24-48 hours)
   - Then "Pending Developer Release" or "Ready for Sale"

---

## Part 7: During App Review

### What Apple Tests

- [ ] App launches and works as described
- [ ] Purchase flows work properly
- [ ] Content unlocks after purchase
- [ ] Restore purchases works
- [ ] No crashes
- [ ] Privacy policy is accurate
- [ ] App follows App Store Review Guidelines

### Common Rejection Reasons

1. **Missing Restore Button:**
   - ✅ You have this! ("Restore Purchases" link)

2. **Unclear Purchase Value:**
   - ✅ Your paywall clearly shows what's unlocked

3. **Privacy Policy Missing/Incomplete:**
   - ⚠️ Make sure you have one!

4. **App Crashes:**
   - ⚠️ Test thoroughly before submission

5. **Subscriptions Not Clear:**
   - ✅ Your UI shows price clearly
   - ✅ Shows it's a subscription
   - ✅ Shows "Managed by App Store. Cancel anytime."

### If Rejected

1. Read rejection reason carefully
2. Fix the issue
3. Upload new build (if code change needed)
4. Or update metadata (if description issue)
5. Click "Submit for Review" again

---

## Part 8: After Approval

### When Approved

1. **Status:** "Pending Developer Release" or "Ready for Sale"

2. **If "Pending Developer Release":**
   - You control when it goes live
   - Click **Release This Version**
   - App goes live in 1-24 hours

3. **If "Ready for Sale":**
   - App is already live!
   - Check App Store to verify

### Monitor Your App

1. **Analytics:**
   - App Store Connect → Analytics
   - See downloads, crashes, purchases

2. **Sales and Trends:**
   - App Store Connect → Sales and Trends
   - See revenue from purchases

3. **Customer Reviews:**
   - App Store Connect → Ratings and Reviews
   - Respond to user feedback

4. **Subscription Analytics:**
   - App Store Connect → Features → Subscriptions
   - See subscribers, renewals, churn rate

---

## Quick Reference: Product IDs

**CRITICAL:** These must match EXACTLY:

### In Configuration.swift:
```swift
static let oneTimePurchaseProductID = "com.whatthebug.unlock.once"
static let subscriptionProductID = "com.whatthebug.pro.monthly"
```

### In App Store Connect:
- Non-Consumable Product ID: `com.whatthebug.unlock.once`
- Subscription Product ID: `com.whatthebug.pro.monthly`

**If they don't match:** Products won't load! ⚠️

---

## Troubleshooting

### "Products not loading in TestFlight"

1. Check Product IDs match exactly
2. Ensure products are approved
3. Try:
   ```
   Editor → Clear Test Account Purchase History (in Xcode)
   ```
4. Delete app, reinstall from TestFlight
5. Check console logs for errors

### "Sandbox account not working"

1. Ensure signed out of real App Store
2. Try different sandbox account
3. Reset sandbox account:
   - Delete from App Store Connect
   - Create new one
   - Try again

### "Purchase completes but content doesn't unlock"

1. Check console logs for transaction errors
2. Verify `isPro` is updating
3. Ensure `@Published` properties are triggering view updates
4. Check `updatePurchasedProducts()` is being called

### "Restore doesn't work in TestFlight"

1. Ensure you purchased first
2. Can't restore what doesn't exist
3. Try same sandbox account that made purchase
4. Check transaction listener is running

---

## Timeline Summary

| Step | Time Required |
|------|---------------|
| Create app listing | 15 minutes |
| Create products | 30 minutes |
| Submit products for review | 24-48 hours |
| Create sandbox tester | 5 minutes |
| Upload to TestFlight | 30 minutes + processing |
| TestFlight testing | 1-2 hours |
| Prepare App Store listing | 2-3 hours |
| Submit for review | 24-48 hours |
| **Total** | **3-5 days** |

---

## Checklist: Complete Setup

### App Store Connect Products
- [ ] App created in My Apps
- [ ] Non-consumable product created
- [ ] Product ID: `com.whatthebug.unlock.once`
- [ ] Price: €2.99 set
- [ ] Localization added with display name & description
- [ ] Screenshots uploaded
- [ ] Submitted for review
- [ ] Subscription group created: "Pro Features"
- [ ] Subscription created
- [ ] Product ID: `com.whatthebug.pro.monthly`
- [ ] Price: €4.99/month set
- [ ] Duration: 1 Month
- [ ] Localization added
- [ ] Benefits listed
- [ ] Submitted for review

### TestFlight
- [ ] Sandbox tester account created
- [ ] Build uploaded to TestFlight
- [ ] Export compliance completed
- [ ] Internal testers added
- [ ] Tested one-time purchase
- [ ] Tested subscription
- [ ] Tested restore purchases
- [ ] Verified no crashes

### App Store Submission
- [ ] Products approved
- [ ] App Store listing complete
- [ ] Screenshots uploaded (all required sizes)
- [ ] Description written
- [ ] Keywords added
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] Age rating completed
- [ ] Review notes detailed
- [ ] Build selected
- [ ] Submitted for review

---

## Support Resources

**App Store Connect:**
- https://appstoreconnect.apple.com

**Developer Documentation:**
- https://developer.apple.com/in-app-purchase/

**App Store Review Guidelines:**
- https://developer.apple.com/app-store/review/guidelines/

**StoreKit Documentation:**
- https://developer.apple.com/documentation/storekit

**Contact Apple:**
- https://developer.apple.com/contact/

---

You're now ready to test in TestFlight and submit to the App Store! 🚀
