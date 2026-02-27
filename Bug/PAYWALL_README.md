# Bug Analysis Paywall Implementation — README

## Overview

This implementation adds a premium paywall system to the bug analysis sheet with a cinematic redesign. The sheet now features a hero image with gradient overlay, a free preview section, and locked premium content behind StoreKit 2 purchases.

## What Was Changed

### 1. **New Files Created**

#### `PurchaseManager.swift`
- Singleton `@MainActor` `ObservableObject` managing StoreKit 2 purchases
- Loads products on initialization
- Handles both one-time purchases and subscriptions
- Listens for transaction updates automatically
- Caches `isPro` status in UserDefaults
- Verifies and finishes all transactions properly

#### `PaywallComponents.swift`
Contains all UI components for the premium paywall:
- **DangerBadge**: Color-coded pill badge (safe/mild/dangerous/deadly)
- **ShadcnRow**: Dark card row component with label + value
- **PremiumParagraphCard**: Card for "How to Locate" and "How to Eliminate" sections
- **LockedContentCard**: Frosted glass effect showing locked content with lock icon
- **ProBadge**: "WhatTheBug Pro ✦" badge shown in top-right when user has Pro
- **PaywallView**: Main paywall UI with two purchase options and unlock button
- **PurchaseOptionCard**: Selectable card for one-time or subscription purchase
- **Color extension**: Hex color support (e.g., `Color(hex: "#111111")`)

### 2. **Files Modified**

#### `Configuration.swift`
Added StoreKit product IDs with TODO comments:
```swift
static let oneTimePurchaseProductID = "com.whatthebug.unlock.once"
static let subscriptionProductID = "com.whatthebug.pro.monthly"
static var productIDs: [String] { [...] }
```

#### `BugAnalysisView.swift`
Complete redesign:
- **Hero Image Header**: Full-width with gradient fade to black
- **Name Section**: Overlaps hero gradient with large condensed headline, italic uppercase Latin name, and danger badge
- **Free Content Section**: Two visible rows (PEST and DANGER) in shadcn-style dark cards
- **Premium Content**: Shows either:
  - **Locked state**: 3 blurred cards with lock icons + full paywall UI
  - **Pro state**: All content visible + Pro badge in top-right corner
- Integrates `PurchaseManager.shared` via `@StateObject`
- Black background (`Color.black`) throughout

### 3. **Files NOT Modified**
- `CameraCaptureService.swift` (no changes needed)
- `BugAnalysisViewModel.swift` (no changes needed)
- `BugResult.swift` (no changes needed)
- Camera flow and scanning functionality remain untouched

## How It Works

### Purchase Flow

1. **Initial State**: User sees free content (PEST, DANGER) and 3 locked cards
2. **Paywall Section**:
   - Two selectable option cards (default: one-time purchase)
   - "Unlock Now" button triggers purchase
   - "Restore Purchases" button syncs previous purchases
3. **After Purchase**: 
   - `isPro` becomes true
   - Locked cards disappear
   - Premium content appears
   - Pro badge shows in top-right

### StoreKit 2 Integration

- Products load asynchronously on app launch
- Transaction listener runs continuously in background
- All transactions are verified before processing
- Transactions are finished after verification
- `isPro` status cached in UserDefaults for offline access
- Subscription status automatically updates when subscription expires/renews

## Design Specifications

### Colors
- Background: `#000000` (pure black)
- Card background: `#111111`
- Card border: `#222222`
- Divider: `#1F1F1F`
- Label gray: `#666666`
- Dim gray: `#888888`
- Fine print: `#444444`

### Danger Level Colors
- **Safe**: `#22C55E` (green)
- **Mild**: `#EAB308` (yellow)
- **Dangerous**: `#F97316` (orange)
- **Deadly**: `#EF4444` (red)

### Typography
- Bug name: 36pt, black weight, tight line height
- Latin name: 11pt, italic, uppercase, tracked
- Section labels: 11pt, semibold, uppercase, tracked
- Values: 16pt, bold, white
- Paragraphs: 15pt, medium weight

### Layout
- Hero image: 280pt height with gradient fade
- Name section: -60pt top offset to overlap gradient
- Cards: 12pt corner radius
- Padding: 20pt horizontal, various vertical
- Button height: 54pt

## App Store Connect Setup

### Required Actions

1. **Create In-App Purchases in App Store Connect**:
   - Go to your app → Features → In-App Purchases
   
2. **Non-Consumable (One-Time Purchase)**:
   - Product ID: `com.whatthebug.unlock.once`
   - Reference Name: "Unlock Single Bug Report"
   - Price: €2.99 (or your preferred price)
   
3. **Auto-Renewable Subscription**:
   - Product ID: `com.whatthebug.pro.monthly`
   - Reference Name: "WhatTheBug Pro Monthly"
   - Subscription Group: Create new group (e.g., "Pro Features")
   - Duration: 1 month
   - Price: €4.99/month (or your preferred price)

4. **Update Product IDs** in `Configuration.swift` if you use different IDs

### Testing

Use StoreKit Configuration File for testing:
1. Xcode → Editor → StoreKit Configuration File
2. Add your two products
3. Set test prices
4. Run app with StoreKit Configuration File active
5. Test purchase and restore flows

## Future Enhancements

Potential improvements:
- Analytics tracking for paywall conversions
- A/B testing different price points
- Free trial for subscription
- Promotional offers
- Family Sharing support
- Multiple subscription tiers

## Support & Notes

- All prices display in user's local currency automatically
- Cancel anytime message is accurate for subscriptions
- Purchases are managed by App Store (no custom server required)
- Receipts are verified on-device using StoreKit 2's built-in verification
- No server-side receipt validation needed for basic implementation
