# Implementation Checklist

## ✅ Completed

### Files Created
- [x] `PurchaseManager.swift` - StoreKit 2 purchase manager
- [x] `PaywallComponents.swift` - All paywall UI components
- [x] `PAYWALL_README.md` - Documentation
- [x] `VISUAL_STRUCTURE.md` - Visual reference
- [x] `IMPLEMENTATION_CHECKLIST.md` - This file

### Files Modified
- [x] `Configuration.swift` - Added product IDs with TODOs
- [x] `BugAnalysisView.swift` - Complete redesign with paywall

### Design Requirements Met
- [x] Black background throughout
- [x] Hero image with gradient fade
- [x] Name overlapping gradient (cinematic feel)
- [x] Large condensed headline (36pt black weight)
- [x] Uppercase italic Latin name with letter spacing
- [x] Color-coded danger badge pill
- [x] Two free visible rows (PEST, DANGER)
- [x] Shadcn-style dark cards (#111111 bg, 1px #222222 border, 12pt corners)
- [x] Removed Common Name and Scientific Name rows (shown in header)
- [x] Three locked content cards with blur + overlay
- [x] Lock icon + "PRO ONLY" text on locked cards
- [x] Two selectable purchase option cards
- [x] "THIS BUG" and "ALL BUGS" badges
- [x] Full-width white "Unlock Now" button
- [x] Scale effect on button press
- [x] "Restore Purchases" link
- [x] Fine print text
- [x] Pro badge in top-right when unlocked
- [x] All premium content visible for Pro users
- [x] No UIKit (pure SwiftUI)

### StoreKit 2 Implementation
- [x] Product loading via `Product.products(for:)`
- [x] Purchase flow with `product.purchase()`
- [x] Transaction verification with `VerificationResult`
- [x] Transaction finishing with `transaction.finish()`
- [x] Restore purchases via `AppStore.sync()`
- [x] Transaction listener for automatic updates
- [x] `isPro` state management
- [x] UserDefaults caching
- [x] One-time purchase product
- [x] Subscription product
- [x] Product ID configuration

### Content & Fallbacks
- [x] All API fields have fallback handling
- [x] N/A displayed for missing data
- [x] Error view for failed analysis
- [x] Loading state maintained
- [x] Camera/scan flow untouched

## 🔄 TODO: Next Steps

### App Store Connect Setup
- [ ] Create App Store Connect account (if not exists)
- [ ] Create app listing
- [ ] Go to Features → In-App Purchases
- [ ] Create non-consumable: `com.whatthebug.unlock.once`
  - [ ] Set display name
  - [ ] Set description
  - [ ] Set price (suggested: €2.99)
  - [ ] Upload screenshot/asset if required
  - [ ] Submit for review
- [ ] Create auto-renewable subscription group
- [ ] Create subscription: `com.whatthebug.pro.monthly`
  - [ ] Set display name
  - [ ] Set description
  - [ ] Set monthly duration
  - [ ] Set price (suggested: €4.99/month)
  - [ ] Set subscription features
  - [ ] Upload screenshot/asset if required
  - [ ] Submit for review

### Testing
- [ ] Create StoreKit Configuration File in Xcode
  - [ ] File → New → File → StoreKit Configuration File
  - [ ] Add both products with test prices
  - [ ] Enable in scheme settings
- [ ] Test purchase flow (sandbox)
  - [ ] Test one-time purchase
  - [ ] Test subscription
  - [ ] Test cancellation
  - [ ] Test expiration
- [ ] Test restore purchases
- [ ] Test offline mode (cached `isPro`)
- [ ] Test transaction verification
- [ ] Test with real App Store account (TestFlight)

### Optional Enhancements
- [ ] Add analytics (track paywall views, purchases)
- [ ] Add promotional offers
- [ ] Add free trial period
- [ ] Add introductory pricing
- [ ] Add family sharing
- [ ] Add subscription management UI
- [ ] Implement custom subscription tiers
- [ ] Add purchase success animation
- [ ] Add haptic feedback on purchase

### Legal & Compliance
- [ ] Add Terms of Service
- [ ] Add Privacy Policy
- [ ] Update App Store listing with subscription info
- [ ] Ensure EU compliance (cancel anytime, etc.)
- [ ] Add subscription management link (Apple handles this)

## 📋 Code Integration Notes

### How to Use PurchaseManager

```swift
// In any view
@StateObject private var purchaseManager = PurchaseManager.shared

// Check Pro status
if purchaseManager.isPro {
    // Show premium content
}

// Purchase
Task {
    if let product = purchaseManager.oneTimePurchaseProduct {
        try await purchaseManager.purchase(product)
    }
}

// Restore
Task {
    await purchaseManager.restorePurchases()
}
```

### Accessing Products

```swift
// One-time purchase
purchaseManager.oneTimePurchaseProduct?.displayPrice // "€2.99"

// Subscription
purchaseManager.subscriptionProduct?.displayPrice // "€4.99"
```

### Observing Changes

PurchaseManager is `ObservableObject`:
- `@Published isPro: Bool` - Automatically updates views
- `@Published products: [Product]` - Available products
- `@Published purchasedProductIDs: Set<String>` - Active purchases

## 🐛 Troubleshooting

### Products not loading
- Check product IDs match App Store Connect
- Ensure products are approved
- Use StoreKit Configuration File for testing
- Check internet connection

### Purchase fails
- Check StoreKit Configuration File is active
- Ensure sandbox account is set up
- Check transaction verification
- Review console logs

### isPro stays false after purchase
- Check transaction listener is running
- Verify transaction verification succeeds
- Check UserDefaults caching
- Force restart app to trigger update

### Restore doesn't work
- Ensure user purchased on same Apple ID
- Check `AppStore.sync()` completes
- Verify entitlements query
- Check console for errors

## 📊 Metrics to Track (Recommended)

- Paywall view count
- Purchase button taps
- Successful purchases (by type)
- Failed purchases (by error)
- Restore attempts
- Time to purchase (from paywall view)
- Conversion rate
- Revenue per user
- Subscription retention rate
- Churn rate

## 🎨 Design Customization Points

If you want to adjust the design later:

### Colors
Edit in `PaywallComponents.swift`:
- `Color(hex: "#111111")` - Card backgrounds
- `Color(hex: "#222222")` - Borders
- Danger level colors in `DangerBadge`

### Typography
Edit in `BugAnalysisView.swift`:
- Name size: `.font(.system(size: 36, weight: .black))`
- Latin name: `.font(.system(size: 11, ...))`

### Pricing
Change in App Store Connect, then:
- Prices auto-update via StoreKit
- No code changes needed

### Layout
Edit in `BugAnalysisView.swift`:
- Hero height: `.frame(height: 280)`
- Name overlap: `.padding(.top, -60)`
- Card spacing: `spacing:` parameters

## ✅ Final Verification

Before submitting to App Store:
- [ ] All purchases work in sandbox
- [ ] Restore works correctly
- [ ] Pro badge shows when appropriate
- [ ] Locked content properly hidden
- [ ] Premium content properly shown
- [ ] Product IDs match App Store Connect
- [ ] Terms and privacy links work
- [ ] App doesn't crash on purchase error
- [ ] Offline mode works (cached state)
- [ ] Subscription auto-renews (test with short duration)
- [ ] All UI looks correct on all device sizes
- [ ] Dark mode only (no light mode issues)
- [ ] VoiceOver accessible
- [ ] Dynamic Type support maintained
