# How to Use the New StoreKit Configuration File

## What I Created

I've created `WhatTheBug.storekit` with the correct product configuration for your app:

### Products Configured:

1. **Single Bug Unlock** (One-time purchase)
   - Product ID: `com.whatthebug.unlock.once`
   - Type: Non-Consumable
   - Price: €2.99
   - Description: "Unlock full analysis report for one bug"

2. **WhatTheBug Pro Monthly** (Subscription)
   - Product ID: `com.whatthebug.pro.monthly`
   - Type: Auto-Renewable Subscription
   - Duration: 1 Month
   - Price: €4.99
   - Description: "Unlimited bug identifications with full analysis reports"
   - Subscription Group: "WhatTheBug Pro"

## How to Add It to Your Xcode Project

### Step 1: Add the File to Xcode

1. In Xcode, right-click on your project in the Project Navigator
2. Select **Add Files to "Bug"...**
3. Navigate to where you saved `WhatTheBug.storekit`
4. Make sure **"Copy items if needed"** is checked
5. Click **Add**

**OR** if the file is already in your project folder:

1. Just drag `WhatTheBug.storekit` from Finder into your Xcode project
2. Make sure it's added to your app target

### Step 2: Activate the StoreKit Configuration

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme...** (or press Cmd+<)
2. Select **Run** in the left sidebar
3. Click the **Options** tab
4. Under **StoreKit Configuration**, click the dropdown
5. Select **WhatTheBug.storekit**
6. Click **Close**

### Step 3: Remove Old Configuration (if exists)

If you have an old StoreKit configuration file (like one with MonaPro products):

1. Find it in your Project Navigator
2. Right-click it
3. Select **Delete**
4. Choose **Move to Trash**

### Step 4: Clean and Rebuild

1. **Clean Build Folder**: Product → Clean Build Folder (Cmd+Shift+K)
2. **Delete the app** from your simulator/device
3. **Build and Run** (Cmd+R)

## Verify It's Working

After following the steps above:

1. Run your app
2. Go to the **Profile** tab
3. Tap **Subscribe**
4. You should now see:
   - **"Single Bug Unlock"** for €2.99
   - **"WhatTheBug Pro Monthly"** for €4.99/mo
   - NO mention of "MonaPro"

## Testing Purchases

With this StoreKit Configuration active:

1. You can test purchases without a real Apple ID
2. All transactions happen locally
3. You can use the **Transaction Manager** in Xcode to view/manage test transactions

### Open Transaction Manager

While running your app in debug:
1. Go to **Debug** → **StoreKit** → **Manage Transactions**
2. You'll see all test purchases here
3. You can:
   - View transaction details
   - Approve/decline pending transactions
   - Refund purchases
   - Speed up/slow down subscription renewals
   - Test subscription expiration

## Optional: Add a Yearly Subscription

If you want to add a yearly subscription option, I can update the configuration file. Just let me know and I'll add:

- **WhatTheBug Pro Yearly**
- Product ID: `com.whatthebug.pro.yearly`
- Price: €39.99/year
- Same benefits as monthly but better value

Then you'd also need to update:
1. `Configuration.swift` to include the yearly product ID
2. `PaywallView.swift` to show the yearly option (if desired)

## Troubleshooting

### "Cannot connect to App Store"
- Make sure StoreKit Configuration is selected in scheme settings
- Clean build folder and rebuild

### Still seeing old product names
- Delete the app completely from simulator/device
- Clean build folder
- Verify correct `.storekit` file is selected in scheme
- Restart Xcode if needed

### Products not loading in app
- Check that product IDs in `Configuration.swift` match the `.storekit` file exactly
- Verify StoreKit Configuration is active in scheme
- Check console for StoreKit errors

### "No products available"
- The `PurchaseManager` might be loading products before StoreKit config is ready
- Try waiting a few seconds after app launch
- Check console output for product loading errors

## Important Notes

1. **This is for testing only**: When you submit to App Store, you'll need to configure these same products in App Store Connect

2. **Product IDs must match**: The product IDs in this file must exactly match:
   - `Configuration.swift` (✅ already correct)
   - App Store Connect products (when you create them)

3. **Prices are in EUR**: You can change prices by:
   - Clicking on each product in the `.storekit` file
   - Updating the price in the inspector panel

4. **Family Sharing**: Currently set to `false` for both products. You can enable this in App Store Connect if desired.

## Next Steps

1. ✅ Add `WhatTheBug.storekit` to your Xcode project
2. ✅ Select it in your scheme settings
3. ✅ Clean and rebuild
4. ✅ Test the purchases
5. 🔄 Later: Create matching products in App Store Connect for production

Let me know if you need any help with these steps!
