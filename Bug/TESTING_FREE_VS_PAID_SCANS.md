# Testing Guide: Free Scans vs Paid Scans

## Critical Requirements

### ❌ Free Daily Scans (3 per day)
**MUST NOT unlock premium content**
- User sees: Common name, Scientific name, PEST status, DANGER badge
- User DOES NOT see: Habitat, Life Stage, Activity, Locations, How to Locate, Elimination strategies, Pro Tips, Community Wisdom
- All premium sections show "PRO ONLY" locked cards
- User can unlock by purchasing from the detail sheet

### ✅ Paid Scan Credits ("ONE SCAN" purchase)
**MUST unlock premium content automatically**
- Same basic info as free scans
- PLUS all premium sections immediately visible
- No "PRO ONLY" locked cards
- Unlock persists across app sessions

### ✅ Pro Subscription ("UNLIMITED")
**MUST unlock all content for all insects**
- Unlimited scans
- All premium sections visible for every insect
- No locked cards ever

---

## Test Cases

### Test 1: Free Daily Scan - Content Should Be Locked

**Setup:**
- Fresh app install (or reset daily limit)
- User has 3 free scans available
- User has 0 scan credits
- User is NOT Pro

**Steps:**
1. Open app → Go to Scan tab
2. Take photo of an insect (or select from library)
3. Wait for analysis to complete
4. Check scan counter: Should show "2 left" (was 3, now 2)

**Expected Results:**
- ✅ Analysis sheet shows with insect identified
- ✅ Can see: Common name, Scientific name
- ✅ Can see: PEST status (YES/NO)
- ✅ Can see: DANGER badge (SAFE/MILD/DANGEROUS/DEADLY)
- ❌ Cannot see habitat, life stage, activity
- ❌ Cannot see geographic locations
- ❌ Cannot see "How to Locate"
- ❌ Cannot see encounter response
- ❌ Cannot see elimination strategies
- ❌ Cannot see pro tips or community wisdom
- ✅ Should see 9 locked cards with "PRO ONLY" overlay and blurred text
- ✅ Should see "Unlock Full Insect Details" button at bottom

**Console Output:**
```
[ScanView] Used free daily scan
[ScanView] Analysis saved, creating CapturedInsect
// NO auto-unlock message should appear
```

---

### Test 2: Paid Scan Credit - Content Should Be Unlocked

**Setup:**
- User has exhausted all 3 free daily scans
- User purchases "ONE SCAN" → availableScanCredits = 1
- User is NOT Pro

**Steps:**
1. Go to Scan tab
2. Check counter: Should show "1 left" (the purchased credit)
3. Take photo of a NEW insect (different from Test 1)
4. Wait for analysis to complete

**Expected Results:**
- ✅ Analysis sheet shows with insect identified
- ✅ Can see: Common name, Scientific name
- ✅ Can see: PEST status, DANGER badge
- ✅ Can see: HABITAT card (not locked)
- ✅ Can see: LIFE STAGE (not locked)
- ✅ Can see: ACTIVITY (not locked)
- ✅ Can see: COMMON LOCATIONS list (not locked)
- ✅ Can see: "HOW TO LOCATE" text (not locked)
- ✅ Can see: "WHAT TO DO WHEN YOU SEE THEM" sections (not locked)
- ✅ Can see: "SHORT-TERM ELIMINATION" text (not locked)
- ✅ Can see: "LONG-TERM ELIMINATION" text (not locked)
- ✅ Can see: "PRO TIPS" text (not locked)
- ✅ Can see: "COMMUNITY WISDOM" text (not locked)
- ❌ Should NOT see any "PRO ONLY" locked cards
- ❌ Should NOT see "Unlock Full Insect Details" button

**Console Output:**
```
[ScanView] Used PAID scan credit: true
[ScanView] Analysis saved, creating CapturedInsect
[ScanView] Auto-unlocked insect [Name] (ID: [UUID]) because scan credit was used
🔓 Auto-unlocked insect [Name]
```

---

### Test 3: Re-viewing Previously Unlocked Insect

**Setup:**
- User completed Test 2 (insect was unlocked via paid credit)
- User closed the analysis sheet
- User is now in Collection tab

**Steps:**
1. Go to Collection tab
2. Find the insect from Test 2
3. Tap to open it
4. Analysis sheet appears

**Expected Results:**
- ✅ All premium content still visible (same as Test 2)
- ✅ No "PRO ONLY" locked cards
- ✅ Unlock persists (saved in UserDefaults)

---

### Test 4: Re-viewing Free Scan Insect (Should Still Be Locked)

**Setup:**
- User completed Test 1 (insect scanned with free daily scan)
- User is in Collection tab

**Steps:**
1. Go to Collection tab
2. Find the insect from Test 1
3. Tap to open it

**Expected Results:**
- ✅ Basic info visible (name, pest status, danger)
- ❌ Premium content still locked
- ✅ Shows 9 "PRO ONLY" locked cards
- ✅ Shows "Unlock Full Insect Details" button
- ✅ Tapping locked card → Opens paywall sheet
- ✅ Tapping unlock button → Opens paywall sheet

---

### Test 5: Unlock from Detail Sheet

**Setup:**
- User viewing the locked insect from Test 1/Test 4
- Paywall sheet is open

**Steps:**
1. In paywall, select "THIS BUG" (one-time purchase)
2. Click "Unlock Now"
3. Complete purchase (sandbox account)
4. Paywall dismisses

**Expected Results:**
- ✅ Returns to analysis sheet
- ✅ Premium content now visible
- ✅ No more locked cards
- ✅ `OneTimeUnlockManager.unlockInsect()` was called with this insect's ID
- ✅ Re-opening this insect shows unlocked content

**Console Output:**
```
[PaywallView] Unlocked specific insect: [Name] (ID: [UUID])
```

---

### Test 6: Pro Subscription - All Content Unlocked

**Setup:**
- User purchases "UNLIMITED" subscription
- User is now Pro (`purchaseManager.isPro = true`)

**Steps:**
1. Scan a brand new insect (never seen before)
2. Wait for analysis

**Expected Results:**
- ✅ All premium content visible immediately
- ✅ No locked cards
- ✅ No unlock button
- ✅ `usedScanCredit = false` (subscription covers it)
- ✅ `hasAccessToPremiumContent = true` (because isPro)

**Console Output:**
```
[ScanView] Pro user - unlimited access
```

---

### Test 7: Mix of Free and Paid Scans (Daily Cycle)

**Setup:**
- New day (daily scans reset to 3)
- User has 0 scan credits
- User is NOT Pro
- User has 2 previously unlocked insects from paid credits

**Steps:**
1. Check counter: Should show "3 left" (free scans reset)
2. Scan insect A (free scan 1/3) → Content locked ❌
3. Scan insect B (free scan 2/3) → Content locked ❌
4. Scan insect C (free scan 3/3) → Content locked ❌
5. Purchase 2x "ONE SCAN" → availableScanCredits = 2
6. Check counter: Should show "2 left" (paid credits)
7. Scan insect D (paid credit 1/2) → Content unlocked ✅
8. Scan insect E (paid credit 2/2) → Content unlocked ✅
9. Re-view insect A from collection → Still locked ❌
10. Re-view insect D from collection → Still unlocked ✅

**Expected Results:**
- ✅ Free scans (A, B, C) remain locked
- ✅ Paid scans (D, E) are permanently unlocked
- ✅ Previously unlocked insects (from before) still unlocked
- ✅ User can purchase "ONE SCAN" to unlock A, B, or C individually

---

### Test 8: Edge Case - Purchase Credit During Analysis

**Setup:**
- User has 0 free scans left, 0 credits
- User is viewing a locked insect from a previous free scan

**Steps:**
1. User taps "Unlock Full Insect Details" button
2. Paywall appears
3. User selects "ONE SCAN" (one-time purchase)
4. User completes purchase
5. Paywall dismisses

**Expected Results:**
- ✅ Credit added: `availableScanCredits = 1`
- ✅ Current insect unlocked via `PaywallView` purchase logic
- ✅ Premium content visible immediately
- ✅ Credit NOT consumed (unlock happened via paywall, not via scan)
- ✅ User can use the 1 credit on next new scan

**Console Output:**
```
[PaywallView] Unlocked specific insect: [Name] (ID: [UUID])
```

---

## Validation Checklist

After all tests, verify:

- [ ] Free daily scans (1-3) do NOT unlock content
- [ ] Paid scan credits DO unlock content automatically
- [ ] Pro subscription unlocks all content
- [ ] Unlocks persist across app restarts
- [ ] Daily limit resets properly (3 free scans)
- [ ] Scan counter accurately reflects free scans + credits
- [ ] Console logs show correct messages
- [ ] No unexpected unlocks for free scans
- [ ] No unexpected locks for paid scans
- [ ] Paywall "ONE SCAN" purchase from detail sheet works
- [ ] User can mix free/paid scans over multiple days

---

## Common Issues to Watch For

### ⚠️ Issue: Free scans unlocking content
**Symptom:** After using a free daily scan, premium content is visible  
**Diagnosis:** `usedScanCredit` is incorrectly set to `true` when `scanLimitManager.canScan()` returns `true`  
**Fix:** Ensure `usedScanCredit = false` when using free scans

### ⚠️ Issue: Paid credits not unlocking content
**Symptom:** After using a paid credit, content remains locked  
**Diagnosis:** `usedScanCredit` is `false` or `onSaved` callback not calling `unlockInsect()`  
**Fix:** Ensure `usedScanCredit = true` when credit is consumed and `onSaved` checks the flag

### ⚠️ Issue: Unlocks not persisting
**Symptom:** Re-opening an insect shows locked content again  
**Diagnosis:** `OneTimeUnlockManager.saveUnlockedInsects()` not called or UserDefaults issue  
**Fix:** Check that `unlockInsect()` calls `saveUnlockedInsects()`

### ⚠️ Issue: Pro users consuming credits
**Symptom:** Pro user's scan counter decreases  
**Diagnosis:** Pro check `if !purchaseManager.isPro` is failing  
**Fix:** Ensure Pro status is checked BEFORE consuming scans/credits

---

## Debug Console Commands

When testing, watch for these log messages:

### Free Daily Scan (Correct)
```
[ScanView] Used free daily scan
[ScanView] Analysis saved, creating CapturedInsect
```

### Paid Scan Credit (Correct)
```
[ScanView] Used PAID scan credit: true
[ScanView] Analysis saved, creating CapturedInsect
[ScanView] Auto-unlocked insect [Name] (ID: [UUID]) because scan credit was used
```

### Pro User (Correct)
```
[ScanView] Pro user - unlimited access
[ScanView] Analysis saved, creating CapturedInsect
```

### Wrong: Free scan auto-unlocking (BUG!)
```
[ScanView] Used free daily scan
[ScanView] Analysis saved, creating CapturedInsect
[ScanView] Auto-unlocked insect [Name] (ID: [UUID]) because scan credit was used  ❌ SHOULD NOT HAPPEN
```

If you see the last pattern, the logic is broken!
