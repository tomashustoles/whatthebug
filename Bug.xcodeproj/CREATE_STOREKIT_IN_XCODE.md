# How to Create StoreKit Configuration File in Xcode

## The Issue

You can't add the `.storekit` file I created because Xcode requires these files to be created directly within Xcode, not as external files.

## Solution: Create It in Xcode

Follow these steps to create a new StoreKit Configuration file with the correct products:

### Step 1: Create New StoreKit Configuration File

1. In Xcode, click **File** → **New** → **File...** (or press Cmd+N)
2. In the template chooser, search for "**storekit**" in the filter box
3. Select **StoreKit Configuration File**
4. Click **Next**
5. Name it: `WhatTheBug`
6. Make sure your app target is selected
7. Click **Create**

### Step 2: Remove Default Products

The file will open with some default products. Delete them all:

1. In the left sidebar, you'll see "In-App Purchases" and "Subscriptions"
2. Select any default products and press Delete (or right-click → Delete)
3. Clear everything so you start fresh

### Step 3: Add One-Time Purchase Product

1. Click the **+** button at the bottom left
2. Select **Add Non-Consumable In-App Purchase**
3. Configure it with these values:

**In the inspector panel on the right:**
- **Reference Name**: `Unlock Once`
- **Product ID**: `com.whatthebug.unlock.once`
- **Price**: `2.99` (or your preferred price)

**Under Localizations → Add Localization → English:**
- **Display Name**: `Single Bug Unlock`
- **Description**: `Unlock full analysis report for one bug`

### Step 4: Add Subscription Group

1. Click the **+** button at the bottom left
2. Select **Add Subscription Group**
3. In the inspector:
   - **Reference Name**: `WhatTheBug Pro`

### Step 5: Add Monthly Subscription

1. Select the subscription group you just created
2. Click the **+** button inside the group (or right-click the group → Add Subscription)
3. Configure it with these values:

**In the inspector panel:**
- **Reference Name**: `Pro Monthly`
- **Product ID**: `com.whatthebug.pro.monthly`
- **Subscription Duration**: `1 Month`
- **Price**: `4.99` (or your preferred price)
- **Subscription Group**: Should already be set to "WhatTheBug Pro"

**Under Localizations → Add Localization → English:**
- **Display Name**: `WhatTheBug Pro Monthly`
- **Description**: `Unlimited bug identifications with full analysis reports`

### Step 6: Save and Activate

1. Save the file (Cmd+S)
2. Go to **Product** → **Scheme** → **Edit Scheme...**
3. Select **Run** → **Options** tab
4. Under **StoreKit Configuration**, select **WhatTheBug**
5. Click **Close**

### Step 7: Remove Old Configuration

If you have an old StoreKit configuration file:

1. In **Product** → **Scheme** → **Edit Scheme...** → **Run** → **Options**
2. Set **StoreKit Configuration** to **WhatTheBug** (the new one)
3. Find the old `.storekit` file in Project Navigator
4. Right-click it → **Delete** → **Move to Trash**

### Step 8: Clean and Test

1. **Clean Build Folder**: Product → Clean Build Folder (Cmd+Shift+K)
2. **Delete the app** from your simulator/device
3. **Build and Run** (Cmd+R)
4. Go to Profile → Tap "Subscribe"
5. You should see correct product names!

## Visual Guide

Here's what your StoreKit Configuration should look like:

```
WhatTheBug.storekit
├── In-App Purchases
│   └── Unlock Once (com.whatthebug.unlock.once) - €2.99
└── Subscriptions
    └── WhatTheBug Pro
        └── Pro Monthly (com.whatthebug.pro.monthly) - €4.99/month
```

## Quick Reference: Product Details

Copy these values exactly when creating the products:

### Product 1: One-Time Purchase
```
Type: Non-Consumable
Reference Name: Unlock Once
Product ID: com.whatthebug.unlock.once
Price: 2.99

Localization (English):
  Display Name: Single Bug Unlock
  Description: Unlock full analysis report for one bug
```

### Product 2: Monthly Subscription
```
Type: Auto-Renewable Subscription
Reference Name: Pro Monthly
Product ID: com.whatthebug.pro.monthly
Duration: 1 Month
Price: 4.99
Group: WhatTheBug Pro

Localization (English):
  Display Name: WhatTheBug Pro Monthly
  Description: Unlimited bug identifications with full analysis reports
```

## Troubleshooting

### Can't find StoreKit Configuration File template
- Make sure you're using Xcode 12 or later
- Try searching for "storekit" in the template filter
- It's under the "Resource" section

### Product IDs are wrong
- Make sure you typed them exactly as shown above
- They must match what's in `Configuration.swift`
- No spaces, all lowercase

### Still seeing old products
1. Verify the correct StoreKit file is selected in scheme
2. Clean build folder
3. Delete app from simulator/device
4. Restart Xcode
5. Build and run fresh

### Products not loading
- Check console for errors
- Wait a few seconds after app launch
- Verify StoreKit Configuration is selected in scheme settings
- Check that product IDs match exactly

## Next: Add Yearly Subscription (Optional)

If you want to add a yearly option:

1. Click **+** inside the "WhatTheBug Pro" subscription group
2. Add another subscription:
   - Reference Name: `Pro Yearly`
   - Product ID: `com.whatthebug.pro.yearly`
   - Duration: `1 Year`
   - Price: `39.99`
   - Display Name: `WhatTheBug Pro Yearly`

Then update `Configuration.swift` to include both subscription product IDs.

## Why This Works

- Xcode manages `.storekit` files specially
- They need to be created within Xcode's file system
- They can't be imported as regular files
- This is by design to ensure proper StoreKit integration

Let me know if you run into any issues!
