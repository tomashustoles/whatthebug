# App Store Connect Setup - Visual Flow

## 📊 Complete Process Flowchart

```
┌─────────────────────────────────────────────────────────┐
│  STEP 1: LOCAL TESTING (No App Store Connect)          │
│  ────────────────────────────────────────────           │
│  • Create StoreKit Configuration File                   │
│  • Add products with test prices                        │
│  • Test purchases in simulator/device                   │
│  • Verify everything works                              │
│  ⏱️  Time: 30 minutes                                   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 2: APP STORE CONNECT - CREATE PRODUCTS           │
│  ────────────────────────────────────────────           │
│  A. Non-Consumable (One-Time Purchase)                 │
│     • Product ID: com.whatthebug.unlock.once           │
│     • Price: €2.99                                      │
│     • Display Name: "Unlock This Bug"                  │
│     • Description + Screenshot                          │
│     • Submit for Review → Wait 24-48 hours             │
│                                                          │
│  B. Auto-Renewable Subscription                        │
│     • Create Subscription Group: "Pro Features"        │
│     • Product ID: com.whatthebug.pro.monthly          │
│     • Price: €4.99/month                               │
│     • Duration: 1 Month                                │
│     • Display Name: "WhatTheBug Pro"                  │
│     • Benefits + Description + Screenshot              │
│     • Submit for Review → Wait 24-48 hours            │
│  ⏱️  Time: 30-45 minutes + review wait                │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 3: CREATE SANDBOX TESTER ACCOUNT                 │
│  ────────────────────────────────────────────           │
│  • App Store Connect → Users and Access → Sandbox      │
│  • Create test account                                  │
│    - Email: testuser+whatthebug@yourdomain.com        │
│    - Password: (save it!)                              │
│    - Country: Your testing region                      │
│  ⏱️  Time: 5 minutes                                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 4: UPLOAD TO TESTFLIGHT                          │
│  ────────────────────────────────────────────           │
│  • Xcode → Product → Archive                           │
│  • Distribute App → App Store Connect                  │
│  • Upload build                                         │
│  • Wait for processing (5-30 minutes)                  │
│  • Complete export compliance                           │
│  • Add internal testers                                │
│  ⏱️  Time: 30 minutes + processing                     │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 5: TEST IN TESTFLIGHT                            │
│  ────────────────────────────────────────────           │
│  On Test Device:                                        │
│  1. Sign out of real App Store                         │
│  2. Install TestFlight app                             │
│  3. Install your app from TestFlight                   │
│  4. Launch app, take bug photo                         │
│  5. Go to paywall, tap "Unlock Now"                    │
│  6. Sign in with SANDBOX account                       │
│     (not your real Apple ID!)                          │
│  7. Complete purchase (no real money!)                 │
│  8. Verify content unlocks                             │
│  9. Test restore purchases                             │
│  ⏱️  Time: 1-2 hours testing                           │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 6: PREPARE APP STORE LISTING                     │
│  ────────────────────────────────────────────           │
│  • App name, description, keywords                     │
│  • Screenshots (6.7" and 5.5" required)                │
│  • App icon (1024x1024)                                │
│  • Privacy policy URL                                   │
│  • Support URL                                          │
│  • Age rating                                           │
│  • Pricing (Free - purchases are separate)            │
│  • Review notes                                         │
│  ⏱️  Time: 2-3 hours                                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 7: SUBMIT FOR APP REVIEW                         │
│  ────────────────────────────────────────────           │
│  • Ensure products are approved                        │
│  • Attach TestFlight build                             │
│  • Review all information                              │
│  • Click "Submit for Review"                           │
│  • Wait 24-48 hours for review                         │
│  ⏱️  Time: 15 minutes + review wait                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STEP 8: APPROVED & LIVE! 🎉                           │
│  ────────────────────────────────────────────           │
│  • Click "Release This Version" (if manual release)    │
│  • App goes live in App Store                          │
│  • Monitor analytics, reviews, sales                   │
│  • Celebrate! 🚀                                        │
└─────────────────────────────────────────────────────────┘
```

---

## 🗓️ Timeline Breakdown

| Phase | Duration | Can Work In Parallel? |
|-------|----------|----------------------|
| Local StoreKit Testing | 30 min | - |
| Create Products in ASC | 45 min | ✅ Can do while local testing |
| Products Review Wait | 24-48 hrs | ✅ Continue with other steps |
| Create Sandbox Account | 5 min | ✅ Anytime |
| Upload to TestFlight | 30 min + processing | After products created |
| TestFlight Testing | 1-2 hrs | After build processed |
| Prepare App Listing | 2-3 hrs | ✅ Can do while products review |
| App Review Wait | 24-48 hrs | - |
| **Total Calendar Time** | **3-5 days** | |
| **Total Active Work** | **~5-6 hours** | |

---

## 🔑 Critical Success Factors

### ✅ Product IDs Must Match EXACTLY

**Configuration.swift:**
```swift
static let oneTimePurchaseProductID = "com.whatthebug.unlock.once"
static let subscriptionProductID = "com.whatthebug.pro.monthly"
```

**App Store Connect:**
- One-time: `com.whatthebug.unlock.once` ← Same!
- Subscription: `com.whatthebug.pro.monthly` ← Same!

**If they don't match:** Products won't load! 🚫

---

### ✅ Testing Environments

| Environment | Where | Account Type | Real Money? |
|-------------|-------|--------------|-------------|
| **Local (StoreKit Config)** | Xcode Simulator/Device | None needed | No |
| **TestFlight** | Real device | Sandbox account | No |
| **Production** | Real device | Real Apple ID | **YES** |

**Never test with your real Apple ID in TestFlight!**

---

## 🎯 What You Need for Each Stage

### Local Testing (Now)
- [x] StoreKit Configuration File
- [x] Two products defined
- [x] Xcode
- [ ] Nothing else!

### TestFlight Testing (Next Week)
- [ ] App Store Connect account ($99/year)
- [ ] Products created in ASC
- [ ] Products approved (24-48 hrs wait)
- [ ] Sandbox tester account
- [ ] Build uploaded to TestFlight
- [ ] Real device (iPhone/iPad)

### App Store Launch (Production)
- [ ] Everything from TestFlight ↑
- [ ] App Store listing complete
- [ ] Screenshots (multiple sizes)
- [ ] Privacy policy URL
- [ ] App Store approval (24-48 hrs wait)

---

## 📋 Quick Action Plan

### This Week: Local Testing
```
Day 1: Create StoreKit Config → Test locally
Day 2-3: Polish UI, fix bugs
Day 4: Prepare for App Store Connect
```

### Next Week: TestFlight
```
Day 5: Create products in ASC
Day 6-7: Wait for product approval
Day 8: Upload to TestFlight
Day 9: Test with sandbox account
```

### Week After: Launch
```
Day 10-11: Prepare App Store listing
Day 12: Submit for review
Day 13-14: Wait for approval
Day 15: Launch! 🚀
```

---

## 🚨 Common Mistakes to Avoid

### ❌ Using Real Apple ID for Testing
**Wrong:** Testing purchases with your personal Apple ID in TestFlight
**Right:** Create and use sandbox tester account

### ❌ Product ID Mismatch
**Wrong:** `com.whatthebug.unlock` in code, `com.whatthebug.unlock.once` in ASC
**Right:** Exact match everywhere

### ❌ Forgetting Restore Button
**Wrong:** No way to restore purchases
**Right:** "Restore Purchases" button visible (you have this!)

### ❌ Missing Privacy Policy
**Wrong:** No privacy policy URL
**Right:** Privacy policy published online, URL added to ASC

### ❌ Unclear Purchase Value
**Wrong:** User doesn't know what they're buying
**Right:** Clear labels, descriptions, visible benefits (you have this!)

---

## 📞 Need Help?

### Apple Developer Support
- https://developer.apple.com/support/
- App Store Connect support chat
- Developer forums

### Documentation
- `APP_STORE_CONNECT_GUIDE.md` ← Full detailed guide
- `STOREKIT_TESTING_GUIDE.md` ← Local testing
- `IMPLEMENTATION_CHECKLIST.md` ← Before launch

---

## 🎉 You're Ready When...

- [x] Code builds without errors ✅
- [x] Local StoreKit testing works ✅
- [ ] Products created in ASC
- [ ] Products approved
- [ ] TestFlight build uploaded
- [ ] Tested with sandbox account
- [ ] All features work in TestFlight
- [ ] App Store listing complete
- [ ] Submitted for review
- [ ] Approved by Apple
- [ ] **LAUNCHED!** 🚀

---

**Next Step:** Create products in App Store Connect (see detailed guide)
