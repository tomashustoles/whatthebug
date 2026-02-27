# Quick Reference Card - Products & Testing

## 📱 Product Information

### Non-Consumable (One-Time Purchase)
```
Product ID:     com.whatthebug.unlock.once
Display Name:   Unlock This Bug
Price:          €2.99
Type:           Non-Consumable
Description:    Get full bug report for this analysis
```

### Auto-Renewable Subscription
```
Product ID:     com.whatthebug.pro.monthly
Display Name:   WhatTheBug Pro
Price:          €4.99/month
Duration:       1 Month
Type:           Auto-Renewable Subscription
Group:          Pro Features
Description:    Unlimited bug identifications
```

---

## 🧪 Testing Quick Reference

### Local Testing (StoreKit Configuration)
```
File → New → StoreKit Configuration File
Add both products with test prices
Product → Scheme → Edit Scheme → Options
  → Select StoreKit Configuration
Cmd + R to run
```

**Pros:** ✅ Fast, ✅ No account needed, ✅ Instant testing
**Cons:** ❌ Not testing real App Store, ❌ Limited scenarios

---

### TestFlight Testing (Sandbox)
```
1. Create products in App Store Connect
2. Wait for approval (24-48 hrs)
3. Create sandbox tester account
4. Upload build: Xcode → Archive → Distribute
5. On device: Sign out of App Store
6. Install from TestFlight
7. Purchase with SANDBOX account
```

**Pros:** ✅ Real App Store integration, ✅ Tests everything
**Cons:** ❌ Requires ASC setup, ❌ Takes time to set up

---

## 🔐 Sandbox Account Template

```
Email:    testuser+whatthebug@yourdomain.com
Password: [Strong password - save it!]
Region:   United States (or your country)
```

**Important:** 
- Never use real Apple ID for testing
- Can use fake email format: name+tag@domain.com
- Must be unique in Apple's system

---

## 📊 Where to Create Products

```
App Store Connect
  → My Apps
    → [Your App]
      → Features
        → In-App Purchases (for one-time)
          → Click (+) → Non-Consumable
        
        → Subscriptions (for subscription)
          → Click (+) → Create Group
          → Add Subscription to group
```

---

## ✅ Pre-Submission Checklist

### Products
- [ ] Both products created in ASC
- [ ] Product IDs match Configuration.swift
- [ ] Prices set correctly
- [ ] Display names filled
- [ ] Descriptions written
- [ ] Screenshots uploaded (if required)
- [ ] Submitted for review
- [ ] Approved (wait 24-48 hrs)

### TestFlight
- [ ] Build uploaded
- [ ] Export compliance done
- [ ] Sandbox account created
- [ ] Tested one-time purchase
- [ ] Tested subscription
- [ ] Tested restore
- [ ] No crashes

### App Store
- [ ] App listing complete
- [ ] Screenshots (all sizes)
- [ ] Privacy policy URL
- [ ] Description written
- [ ] Keywords added
- [ ] Review notes detailed
- [ ] Build attached
- [ ] Submitted for review

---

## 🚨 Troubleshooting Quick Fixes

### Products Not Loading
```
1. Check Product IDs match EXACTLY
2. Ensure products approved in ASC
3. Clean build: Cmd + Shift + K
4. Delete app, reinstall
5. Check console for errors
```

### Purchase Fails in TestFlight
```
1. Signed out of real App Store?
2. Using sandbox account (not real ID)?
3. Products approved?
4. Check "Environment: Sandbox" shows in purchase sheet
5. Try different sandbox account
```

### Content Doesn't Unlock
```
1. Check console logs
2. Verify isPro is updating
3. Check updatePurchasedProducts() is called
4. Verify @Published triggers view update
5. Test transaction listener
```

### Restore Doesn't Work
```
1. Did you purchase first?
2. Using same sandbox account?
3. Check Transaction.currentEntitlements
4. Verify transaction.finish() is called
5. Try: Editor → Clear Test Account Purchase History
```

---

## 📱 Contact Info for App Review

**What Apple Needs:**

```
Testing Notes Template:
─────────────────────────
To test purchases:

1. Launch app
2. Take or select a bug photo
3. Wait 2-5 seconds for AI analysis
4. Scroll down to paywall section
5. Tap "THIS BUG" option (€2.99 one-time)
   OR "ALL BUGS" option (€4.99/mo subscription)
6. Tap "Unlock Now"
7. Complete sandbox purchase
8. Content unlocks immediately

To test restore:
1. Tap "Restore Purchases" link
2. Previous purchases restore

Both purchases unlock:
- Habitat information
- Life stage details  
- How to locate bugs
- Elimination methods
```

---

## 🔗 Important URLs

### App Store Connect
https://appstoreconnect.apple.com

### Developer Portal
https://developer.apple.com

### App Store Guidelines
https://developer.apple.com/app-store/review/guidelines/

### StoreKit Documentation
https://developer.apple.com/documentation/storekit

### Contact Support
https://developer.apple.com/contact/

---

## 📞 Emergency Contacts (If Rejected)

### Resolution Team
- Respond in Resolution Center (in ASC)
- Be polite and professional
- Address each point specifically
- Upload new build if needed
- Resubmit within 7 days

### Common Rejection Solutions
- **Missing restore:** You have it! Point to line in code
- **Unclear value:** Reference your clear UI
- **Privacy issue:** Update privacy policy, resubmit
- **Crash:** Fix bug, upload new build
- **Guideline violation:** Read guideline, fix issue

---

## 💾 Keep These Saved

### Product IDs (CRITICAL!)
```
com.whatthebug.unlock.once
com.whatthebug.pro.monthly
```

### Sandbox Account Credentials
```
Email: _______________________________
Password: ____________________________
```

### App Store Connect Login
```
Apple ID: ____________________________
Password: ____________________________
```

### Support Info
```
Support Email: _______________________
Privacy Policy URL: __________________
Support Website: _____________________
```

---

## ⏱️ Timeline Estimates

| Task | Time |
|------|------|
| Create products in ASC | 45 min |
| Product approval wait | 24-48 hrs |
| Create sandbox account | 5 min |
| Upload to TestFlight | 30 min |
| TestFlight processing | 10-30 min |
| TestFlight testing | 1-2 hrs |
| App Store listing prep | 2-3 hrs |
| App review wait | 24-48 hrs |
| **Total** | **3-5 days** |

---

## 🎯 Today's Action Items

1. ✅ Verify local StoreKit testing works
2. ✅ Fix any remaining bugs
3. [ ] Create App Store Connect account (if needed)
4. [ ] Create products in ASC
5. [ ] Start preparing screenshots
6. [ ] Write privacy policy (if needed)

---

## 📚 Documentation Index

```
START_HERE.md                 → Overview
BUILD_FIXES.md               → Solved build errors
PERFORMANCE_FIXES.md         → Thread safety fixes
STOREKIT_TESTING_GUIDE.md   → Local testing ⭐️
APP_STORE_CONNECT_GUIDE.md  → Full ASC guide ⭐️⭐️
ASC_VISUAL_FLOW.md          → Visual timeline
IMPLEMENTATION_CHECKLIST.md → Before launch
PAYWALL_README.md           → Feature docs
VISUAL_STRUCTURE.md         → Design specs
```

**Start with:** APP_STORE_CONNECT_GUIDE.md for complete details

---

**Print this card and keep it handy! 📄**
