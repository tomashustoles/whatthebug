# Quick StoreKit Testing Setup Guide

## Step-by-Step: Local Testing (No App Store Connect Needed)

### 1. Create StoreKit Configuration File

In Xcode:
```
File → New → File → Search "StoreKit Configuration" → Next
Name: Products.storekit
Location: Save to project root
Add to target: Bug
```

### 2. Add Products to Configuration File

Click the **+** button in the bottom left:

#### Non-Consumable Product (One-Time Purchase)
- Click **+** → **Add Non-Consumable In-App Purchase**
- **Reference Name:** Unlock Single Bug
- **Product ID:** `com.whatthebug.unlock.once` (MUST match Configuration.swift)
- **Price:** €2.99 (or any test price)
- **Localization:**
  - Language: English
  - Display Name: Unlock This Bug
  - Description: Get full information about this bug

#### Auto-Renewable Subscription
- Click **+** → **Add Auto-Renewable Subscription**
- **Reference Name:** Pro Monthly Subscription
- **Product ID:** `com.whatthebug.pro.monthly` (MUST match Configuration.swift)
- **Subscription Group:** Create new → "Pro Features"
- **Duration:** 1 Month
- **Price:** €4.99
- **Localization:**
  - Language: English
  - Display Name: WhatTheBug Pro
  - Description: Unlimited bug identifications and full reports

### 3. Enable StoreKit Configuration in Your Scheme

```
Product → Scheme → Edit Scheme...
→ Run (left sidebar)
→ Options tab
→ StoreKit Configuration: Select "Products.storekit"
→ Close
```

### 4. Run and Test

Build and run (Cmd + R). Now when you:
- Tap "Unlock Now" → StoreKit sandbox purchase sheet appears
- Complete "purchase" → No real money charged
- Purchases persist across app launches (in simulator)
- Can test subscription renewals, cancellations, etc.

---

## Testing Checklist

### Initial State (No Purchase)
- [ ] See PEST and DANGER rows (free content)
- [ ] See 3 locked/blurred cards
- [ ] See two purchase option cards
- [ ] Can select between one-time and subscription
- [ ] "Unlock Now" button is enabled

### One-Time Purchase Flow
- [ ] Select "THIS BUG" card (left one)
- [ ] Tap "Unlock Now"
- [ ] StoreKit sheet appears
- [ ] Tap "Subscribe" or "Buy" (varies by iOS version)
- [ ] Confirm with password/Face ID/Touch ID (may be skipped in sandbox)
- [ ] Sheet dismisses
- [ ] Content unlocks immediately
- [ ] Pro badge appears top-right
- [ ] All premium content visible
- [ ] Locked cards gone

### Subscription Purchase Flow
- [ ] Select "ALL BUGS" card (right one)
- [ ] Tap "Unlock Now"
- [ ] StoreKit sheet appears
- [ ] Complete purchase
- [ ] Content unlocks
- [ ] Pro badge appears

### Restore Purchases
- [ ] Delete app
- [ ] Reinstall and run
- [ ] Tap "Restore Purchases"
- [ ] Previous purchase restored
- [ ] Content unlocked again

### Subscription Management (Advanced)
In StoreKit Configuration file:
- [ ] Can test renewal (fast-forward time)
- [ ] Can test expiration
- [ ] Can test cancellation
- [ ] Can test billing retry

---

## Fast Testing Tips

### Speed Up Subscription Testing

In `Products.storekit`, change subscription duration to 5 minutes for faster testing:

```
Duration: 5 Minutes (instead of 1 Month)
```

Now subscription renews every 5 minutes in testing!

### Clear Purchase History

```
Editor → Clear Test Account Purchase History
```

This resets all purchases in sandbox mode. Useful for testing first-time purchase flow.

### Test Different Prices

Edit product prices directly in `.storekit` file to test different price points:
- €0.99 (low)
- €2.99 (medium)
- €9.99 (high)

No App Store Connect changes needed!

---

## Common Testing Scenarios

### Scenario 1: First-Time User
1. Launch app
2. Capture bug photo
3. See analysis with locked content
4. Purchase one-time unlock
5. Verify content unlocks

### Scenario 2: Returning User
1. Launch app (already purchased)
2. Capture bug photo
3. Verify Pro badge shows
4. Verify all content unlocked immediately

### Scenario 3: Restore After Reinstall
1. Delete app
2. Reinstall
3. Capture bug photo
4. Tap "Restore Purchases"
5. Verify purchase restores

### Scenario 4: Subscription Expiration
1. Purchase subscription
2. In StoreKit Config, fast-forward time
3. Wait for expiration
4. Verify content locks again
5. Verify isPro becomes false

---

## Debugging Purchase Issues

### Console Logs to Watch

```swift
// Success
"Loaded X products"
"Purchase successful"

// Errors
"Failed to load products: ..."
"Purchase failed: ..."
"Transaction verification failed"
```

### Check Transaction States

Add temporary debug logging:

```swift
// In PurchaseManager.purchase()
print("Purchase result: \(result)")

// In updatePurchasedProducts()
print("Current entitlements: \(purchasedIDs)")
print("isPro: \(isPro)")
```

### Verify Product Loading

Add breakpoint or print in:
```swift
func loadProducts() async {
    // Add print here to see loaded products
    print("Loaded products: \(loadedProducts)")
}
```

---

## StoreKit Configuration File Structure

Your `Products.storekit` should look like this when complete:

```
Products.storekit
├── Non-Consumables
│   └── com.whatthebug.unlock.once (€2.99)
└── Subscriptions
    └── Pro Features (Group)
        └── com.whatthebug.pro.monthly (€4.99/month)
```

---

## Moving to Production

### Before TestFlight:
1. **Disable StoreKit Configuration:**
   - Edit Scheme → Options → StoreKit Configuration: None

2. **Create Real Products in App Store Connect:**
   - Go to App Store Connect
   - Your App → Features → In-App Purchases
   - Create matching products with EXACT same Product IDs

3. **Create Sandbox Tester:**
   - App Store Connect → Users and Access
   - Sandbox Testers → Add new tester
   - Use unique email (can be fake: test@example.com won't work, but test+sandbox@yourdomain.com will)

4. **Test on Device with TestFlight:**
   - Sign out of App Store on device
   - Install TestFlight build
   - When prompted, sign in with sandbox account
   - Test full purchase flow

### Before App Review:
- [ ] Both products approved in App Store Connect
- [ ] Screenshots uploaded for each product
- [ ] Pricing set for all territories
- [ ] Subscription terms clear and visible in app
- [ ] Privacy policy and terms linked
- [ ] "Restore Purchases" button functional
- [ ] Products load correctly from App Store (not config file)

---

## Troubleshooting Guide

| Problem | Solution |
|---------|----------|
| "No products available" | Check Product IDs match Configuration.swift exactly |
| Purchase sheet doesn't appear | Verify StoreKit Config is selected in scheme |
| "Cannot connect to App Store" in simulator | Normal - use StoreKit Config instead |
| isPro doesn't persist | Check UserDefaults save is called |
| Subscription shows as expired immediately | Check duration in StoreKit Config |
| Can't test on real device | Need TestFlight + sandbox account |
| Products load but purchase fails | Check transaction verification logic |
| UI doesn't update after purchase | Verify @Published and @ObservedObject/StateObject |

---

## Next: Production Setup

Once local testing works perfectly, proceed to:
1. `PAYWALL_README.md` - App Store Connect setup
2. `IMPLEMENTATION_CHECKLIST.md` - Production checklist
3. Submit products for review (can take 24-48 hours)
4. Test with real sandbox account via TestFlight
5. Submit app for review

---

## Quick Command Reference

```bash
# Clean build
Cmd + Shift + K

# Clean derived data (if builds fail)
rm -rf ~/Library/Developer/Xcode/DerivedData

# Run app
Cmd + R

# Stop app
Cmd + .

# View console
Cmd + Shift + Y
```

---

Good luck testing! 🐛✨
