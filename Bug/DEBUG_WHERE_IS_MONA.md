# Debug: Where Are You Seeing "Mona Art Companion"?

## Important Question

The console logs show the correct products are loading:
```
[PurchaseManager] Successfully loaded 2 products:
  - Unlock This Bug (com.whatthebug.unlock.once) - 79,00 Kč
  - WhatTheBug Pro (com.whatthebug.pro.monthly) - 99,00 Kč
```

But you're seeing "Mona Art Companion Pro Subscription" somewhere. We need to identify WHERE you're seeing it.

## Possible Locations

### 1. Profile Tab - Subscription Card (Most Likely NOT Here)
This just shows:
- "Premium" or "Active" (generic text)
- "Subscribe" or "Manage" button
- NO product names displayed here

### 2. PaywallView Sheet (Should Show Correct Products)
When you tap "Subscribe" in Profile, this should open and show:
- "Unlock This Bug" card
- "WhatTheBug Pro" card

**But the console is NOT showing the PaywallView logs!** This suggests:
- Either the PaywallView isn't opening
- Or you're looking at something else

### 3. iOS System Subscription Management (MOST LIKELY THIS!)
When you tap "Manage" as a Pro user, it opens Apple's native subscription management interface.

**This is controlled by iOS, not our app!**

If you have an ACTIVE subscription to "Mona Art Companion" from a different app (or previous test), iOS will show THAT subscription when you open the system settings.

## Test This:

### Step 1: Check What Opens When You Tap Buttons

1. Go to **Profile tab**
2. **Are you Pro or not Pro?**
   - If "Subscribe" button → You're NOT Pro
   - If "Manage" button → You ARE Pro

3. **Tap the button**
   - Does a **sheet slide up from bottom** (PaywallView)?
   - Or does it **open iOS Settings** (System Subscription Management)?

### Step 2: If It Opens a Sheet (PaywallView)

The console should show:
```
[PaywallView] Rendering with 2 products
[PaywallView]   - Unlock This Bug (com.whatthebug.unlock.once)
[PaywallView]   - WhatTheBug Pro (com.whatthebug.pro.monthly)
[PaywallView] Rendering one-time card: 'Unlock This Bug' - 79,00 Kč
[PurchaseOptionCard] Rendering card with title: 'Unlock This Bug', price: '79,00 Kč'
[PaywallView] Rendering subscription card: 'WhatTheBug Pro' - 99,00 Kč
[PurchaseOptionCard] Rendering card with title: 'WhatTheBug Pro', price: '99,00 Kč/mo'
```

If you DON'T see these logs, the PaywallView is not opening!

### Step 3: If It Opens iOS Settings

You'll see the iOS native subscription management interface. This shows:
- ALL your active subscriptions across ALL apps
- Including "Mona Art Companion" if you have that subscription

**This is NOT controlled by our app!** It's Apple's system UI.

## Most Likely Scenario

Based on your console output showing correct products loading, but you seeing "Mona Art Companion":

**You're tapping "Manage" and seeing the iOS system subscription management, which is showing your ACTIVE Mona Art Companion subscription from a different app.**

## Solution: Check Your Active Subscriptions

1. Go to iPhone/iPad **Settings**
2. Tap your **Apple ID** at the top
3. Tap **Subscriptions**
4. Look for **"Mona Art Companion"**

If you see it there, that's a REAL active subscription you have, not related to WhatTheBug.

## To Verify WhatTheBug Products Work:

### Test the PaywallView:

1. **Sign out of your account** (to become non-Pro)
   - Or delete the app and reinstall
   - Or clear UserDefaults for "isPro"

2. Go to **Profile tab**

3. You should see **"Subscribe"** button

4. **Tap "Subscribe"**

5. **Check console** - you should see the PaywallView logs

6. **Take a screenshot** of what appears

This will show us if the PaywallView is actually displaying the correct products.

## Alternative: Test from Bug Analysis

1. **Capture a bug photo**
2. Wait for analysis
3. Scroll down to see the paywall
4. **Check console** for PaywallView logs
5. **Take a screenshot** of what you see

## What to Send Me

Please provide:

1. **Screenshot** showing where you see "Mona Art Companion"
2. **Console logs** after tapping "Subscribe" or viewing a bug analysis
3. **Answer**: Are you tapping "Subscribe" or "Manage"?
4. **Answer**: Does a sheet open, or does it go to Settings?

This will help me identify the actual issue!
