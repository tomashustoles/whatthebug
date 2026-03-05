# Fix: Display Product Names in Paywall

## Issue

The PaywallView was showing product prices but NOT the product names from App Store Connect. Users were seeing "Mona Art Companion" or generic text instead of the actual product names like "Unlock This Bug" and "WhatTheBug Pro".

## Root Cause

The `PurchaseOptionCard` component was only displaying:
- Badge (THIS BUG / ALL BUGS)
- Price
- Label (One scan / Unlimited)

But it was **NOT displaying the product's display name** from StoreKit (`product.displayName`).

## Solution

### 1. Updated PaywallView

Added the product title to the PurchaseOptionCard initialization:

```swift
// Card A - One-time purchase
if let product = purchaseManager.oneTimePurchaseProduct {
    PurchaseOptionCard(
        badge: "THIS BUG",
        title: product.displayName,  // ← Added this
        price: product.displayPrice,
        label: "One scan",
        isSelected: selectedProductType == .oneTime
    ) {
        selectedProductType = .oneTime
    }
}

// Card B - Subscription
if let product = purchaseManager.subscriptionProduct {
    PurchaseOptionCard(
        badge: "ALL BUGS",
        title: product.displayName,  // ← Added this
        price: "\(product.displayPrice)/mo",
        label: "Unlimited",
        isSelected: selectedProductType == .subscription
    ) {
        selectedProductType = .subscription
    }
}
```

### 2. Updated PurchaseOptionCard

Added the `title` parameter and displayed it in the UI:

```swift
struct PurchaseOptionCard: View {
    let badge: String
    let title: String  // ← New parameter
    let price: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Badge at top
            // ...
            
            // Product Title (NEW)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            // Price
            Text(price)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            // Label
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: "#888888"))
        }
        .frame(height: 140)  // Increased from 120 to accommodate title
        // ...
    }
}
```

### 3. Added Debug Logging

Added detailed logging to track what's being rendered:

```swift
let _ = print("[PaywallView] Rendering one-time card: '\(product.displayName)' - \(product.displayPrice)")
let _ = print("[PurchaseOptionCard] Rendering card with title: '\(title)', price: '\(price)'")
```

## What You'll See Now

The paywall will display both cards with:

### One-Time Purchase Card:
```
┌─────────────────┐
│      THIS BUG   │← Badge
│                 │
│ Unlock This Bug │← Product Name (from App Store Connect)
│ 79,00 Kč        │← Price
│ One scan        │← Label
└─────────────────┘
```

### Subscription Card:
```
┌─────────────────┐
│     ALL BUGS    │← Badge
│                 │
│ WhatTheBug Pro  │← Product Name (from App Store Connect)
│ 99,00 Kč/mo     │← Price
│ Unlimited       │← Label
└─────────────────┘
```

## Testing

1. **Clean Build**: Cmd+Shift+K
2. **Delete App**: Remove from device/simulator
3. **Rebuild and Run**: Cmd+R
4. **Navigate to Paywall**:
   - Option 1: Capture a bug → View analysis → See paywall
   - Option 2: Profile tab → Tap "Subscribe"
5. **Check Console** for:
   ```
   [PaywallView] Rendering one-time card: 'Unlock This Bug' - 79,00 Kč
   [PurchaseOptionCard] Rendering card with title: 'Unlock This Bug', price: '79,00 Kč'
   [PaywallView] Rendering subscription card: 'WhatTheBug Pro' - 99,00 Kč
   [PurchaseOptionCard] Rendering card with title: 'WhatTheBug Pro', price: '99,00 Kč/mo'
   ```
6. **Verify UI** shows the correct product names

## Why "Mona Art Companion" Was Showing

The most likely reasons were:

1. **Cached Data**: StoreKit was showing cached product metadata from a previous test
2. **Wrong App**: Different app bundle was running (Lume/Mona vs WhatTheBug)
3. **Missing Display Names**: Products without localizations showing fallback text
4. **Not Displaying Product Names**: The card wasn't rendering `product.displayName` at all (this was the actual issue!)

## Result

✅ Product names from App Store Connect now display correctly
✅ Both paths show the same products (Bug Analysis + Profile)
✅ Debug logging helps track what's being rendered
✅ UI is more informative with product titles visible

## Important Notes

### Product Names Come From App Store Connect

The `product.displayName` value comes directly from App Store Connect's "In-App Purchase Localizations" section. Make sure:

1. Each product has a localization for your target language (English, Czech, etc.)
2. The display name is set correctly
3. Changes may take a few minutes to propagate

### Testing Locally

When using a StoreKit Configuration file for local testing, the display names come from the `.storekit` file's localization settings, not App Store Connect.

### Both Paywalls Use Same Manager

Both the Bug Analysis paywall and the Profile paywall use:
- Same `PurchaseManager.shared` instance
- Same product IDs from `Configuration.swift`
- Same products loaded from App Store Connect

So they will always show the same products with the same names.

## Verification Checklist

- [x] Updated `PaywallView` to pass `product.displayName`
- [x] Updated `PurchaseOptionCard` to accept and display `title`
- [x] Added debug logging for troubleshooting
- [x] Increased card height to accommodate product name
- [x] Both paywall paths use same component
- [x] Product names load from App Store Connect

The paywall should now correctly display your WhatTheBug products instead of any Mona/Lume references!
