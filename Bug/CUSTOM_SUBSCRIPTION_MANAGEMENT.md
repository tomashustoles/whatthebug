# Custom Subscription Management UI for Pro Users

## What Changed

Previously, when Pro users tapped "Manage" in the Profile tab, it would open iOS's native subscription management (showing "Mona Art Companion" due to legacy test data).

Now, **both Pro and non-Pro users see our custom branded UI** when they tap the button in Profile.

## Updated Behavior

### ProfileView
- **Both "Subscribe" and "Manage" buttons** now open the same custom `PaywallView` sheet
- No more direct navigation to iOS system settings

### PaywallView
The PaywallView now has **two different modes**:

#### Mode 1: Non-Pro Users (Purchase Mode)
Shows:
- "UNLOCK FULL REPORT" heading
- Two purchase option cards:
  - **Unlock This Bug** (one-time purchase)
  - **WhatTheBug Pro** (subscription)
- "Unlock Now" button
- "Restore Purchases" link

#### Mode 2: Pro Users (Management Mode)
Shows:
- ✅ Green checkmark with "Active Subscription" heading
- Pro badge
- Current plan info with product name and price
- **"Manage in App Store"** button (opens iOS system management)
- **"Restore Purchases"** button
- Info text explaining how to cancel

## User Flow

### Non-Pro User
```
Profile Tab
    ↓
Tap "Subscribe"
    ↓
Custom PaywallView (Purchase Mode)
    ↓
Select product → Purchase
    ↓
Becomes Pro
```

### Pro User
```
Profile Tab
    ↓
Tap "Manage"
    ↓
Custom PaywallView (Management Mode)
    ↓
See current subscription info
    ↓
Can tap "Manage in App Store" if needed
```

## Benefits

### ✅ Consistent Branding
- Both Pro and non-Pro users see WhatTheBug branded UI
- No more confusing "Mona Art Companion" references
- Professional, cohesive user experience

### ✅ Better User Experience
- Pro users see their current plan at a glance
- Clear indication of Pro status
- Easy access to both custom UI and system management

### ✅ Flexibility
- Pro users can still access iOS system management via "Manage in App Store" button
- Restore purchases available for both Pro and non-Pro users
- All subscription management in one place

## UI Preview

### Pro User Management View

```
┌───────────────────────────────────┐
│  ✅                  🏆 Pro       │
│  Active Subscription               │
│  You have unlimited access...      │
│                                    │
│  YOUR PLAN                         │
│  ┌─────────────────────────────┐  │
│  │ WhatTheBug Pro           ✓  │  │
│  │ 99,00 Kč/month              │  │
│  └─────────────────────────────┘  │
│                                    │
│  [↻ Manage in App Store]          │
│  [⟲ Restore Purchases]            │
│                                    │
│  To cancel your subscription...   │
└───────────────────────────────────┘
```

### Non-Pro User Purchase View

```
┌───────────────────────────────────┐
│  UNLOCK FULL REPORT                │
│                                    │
│  ┌──────────┐  ┌──────────┐       │
│  │THIS BUG  │  │ALL BUGS  │       │
│  │Unlock    │  │WhatTheBug│       │
│  │This Bug  │  │Pro       │       │
│  │79,00 Kč  │  │99,00 Kč  │       │
│  │One scan  │  │Unlimited │       │
│  └──────────┘  └──────────┘       │
│                                    │
│  [    Unlock Now    ]              │
│  Restore Purchases                 │
│  Managed by App Store...           │
└───────────────────────────────────┘
```

## Code Changes Summary

### 1. ProfileView.swift
```swift
Button {
    // Always show our custom subscription sheet
    showingPaywall = true
} label: {
    Text(purchaseManager.isPro ? "Manage" : "Subscribe")
}
```

### 2. PaywallView (in PaywallComponents.swift)

Added conditional rendering:
```swift
var body: some View {
    ScrollView {
        VStack {
            if purchaseManager.isPro {
                subscriptionManagementView  // New!
            } else {
                purchaseOptionsView
            }
        }
    }
}
```

Added Pro user management UI:
- Current subscription display
- "Manage in App Store" button
- "Restore Purchases" button
- Helper function `openSystemSubscriptionManagement()`

## Testing

### Test as Non-Pro User
1. Delete app and reinstall (or clear isPro from UserDefaults)
2. Open app → Profile tab
3. Tap "Subscribe"
4. Should see purchase options with correct product names
5. Console should show:
   ```
   [PaywallView] Rendering with 2 products, isPro: false
   [PaywallView]   - Unlock This Bug (com.whatthebug.unlock.once)
   [PaywallView]   - WhatTheBug Pro (com.whatthebug.pro.monthly)
   ```

### Test as Pro User
1. Make a test purchase (or manually set isPro to true)
2. Open app → Profile tab
3. Should see "Manage" button with green checkmark
4. Tap "Manage"
5. Should see subscription management UI with:
   - "Active Subscription" heading
   - Current plan: "WhatTheBug Pro - 99,00 Kč/month"
   - "Manage in App Store" button
6. Console should show:
   ```
   [PaywallView] Rendering with 2 products, isPro: true
   ```

### Test "Manage in App Store" Button
1. As Pro user, tap "Manage in App Store"
2. Should open iOS system subscription management
3. Will show your active subscriptions (including any test Mona subscriptions)
4. This is expected - system management shows ALL subscriptions

## Important Notes

### Why "Manage in App Store" Button?

While we show custom UI, Apple requires that users have a way to:
- Cancel subscriptions
- Change payment methods
- View subscription history
- Handle billing issues

The "Manage in App Store" button provides this access while keeping our branded UI as the primary interface.

### Legacy "Mona" Subscriptions

If Pro users tap "Manage in App Store", they might still see old "Mona Art Companion" subscriptions because:
- Those are real active (or recently expired) test subscriptions
- iOS system UI shows subscription names from when they were purchased
- This is expected behavior and will resolve when:
  - Test subscriptions expire
  - Sandbox account is cleared
  - New subscriptions are created with current product names

### Product Names

The custom UI always shows **current product names** from App Store Connect:
- "Unlock This Bug"
- "WhatTheBug Pro"

These are loaded dynamically via StoreKit 2, so they always reflect your latest configuration.

## Result

✅ Consistent WhatTheBug branding throughout the app
✅ Pro users see their subscription status clearly
✅ Non-Pro users see purchase options
✅ Easy access to system management when needed
✅ No more confusing "Mona Art Companion" in primary UI
✅ Professional, polished subscription experience

The subscription flow is now complete and fully branded! 🎉
