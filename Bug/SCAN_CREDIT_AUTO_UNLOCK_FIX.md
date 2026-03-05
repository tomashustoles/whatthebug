# Scan Credit Auto-Unlock Fix

## The Problem

When a user purchased a one-time scan credit and used it to scan an insect:

```
❌ BROKEN FLOW:
1. User buys "ONE SCAN" → Credit added (availableScanCredits = 1)
2. User takes photo → Credit deducted (availableScanCredits = 0)
3. Analysis completes → Result shown with LOCKED content
4. User confused: "I paid for this scan, why is it locked?"
```

The scan credit was consumed but the insect was never marked as unlocked in `OneTimeUnlockManager`.

## Important: Free Scans vs Paid Scans

### Free Daily Scans (3 per day)
- ❌ **Do NOT unlock premium content**
- User sees only: PEST status, DANGER level
- Premium sections remain locked (paywall shows)
- Content can be unlocked later via purchase

### Paid Scan Credits ("ONE SCAN" purchase)
- ✅ **DO unlock premium content automatically**
- User paid for this specific insect
- All premium sections visible immediately
- Unlock is permanent (saved forever)

### Pro Subscription ("UNLIMITED")
- ✅ **All insects unlocked automatically**
- No credits needed
- Unlimited scans, all content visible

## The Solution

Track when a scan credit is used and automatically unlock the insect when analysis succeeds:

```
✅ FIXED FLOW:
1. User buys "ONE SCAN" → Credit added (availableScanCredits = 1)
2. User takes photo → Credit deducted (availableScanCredits = 0)
                    → usedScanCredit flag set to TRUE
3. Analysis completes → Result saved
                      → Check: usedScanCredit == true
                      → unlockInsect(result.id) called automatically
4. User sees unlocked content immediately! 🎉
```

## Implementation Details

### Step 1: Track Credit Usage
Added state variable to `ScanView.swift`:

```swift
@State private var usedScanCredit = false  // Track if current scan used a credit
```

### Step 2: Set Flag When Credit is Consumed
In both camera capture and photo library flows:

```swift
// When photo is taken/selected
if !purchaseManager.isPro {
    if scanLimitManager.canScan(isPro: false) {
        // Using FREE daily scan (1/3, 2/3, or 3/3)
        scanLimitManager.incrementScanCount()
        usedScanCredit = false  // ❌ Free scan - NO auto-unlock
        print("[ScanView] Used free daily scan")
    } else {
        // Using PAID scan credit (after free scans exhausted)
        let creditUsed = oneTimeUnlockManager.useScanCredit()
        usedScanCredit = creditUsed  // ✅ Paid credit - WILL auto-unlock
        print("[ScanView] Used PAID scan credit: \(creditUsed)")
    }
} else {
    // Pro subscriber - unlimited scans, no credits needed
    usedScanCredit = false  // No credit used (subscription covers it)
    print("[ScanView] Pro user - unlimited access")
}
```

**Key Logic:**
- `scanLimitManager.canScan()` returns `true` → User has free scans left → Set `usedScanCredit = false`
- `scanLimitManager.canScan()` returns `false` → No free scans → Use paid credit → Set `usedScanCredit = true`
- This ensures **only paid scans trigger auto-unlock**, not free scans

### Step 3: Auto-Unlock on Success
In the `onSaved` callback (triggered when analysis completes):

```swift
onSaved: { result in
    // If this scan used a credit, automatically unlock the insect
    if usedScanCredit {
        oneTimeUnlockManager.unlockInsect(result.id)
        print("🔓 Auto-unlocked insect \(result.commonName)")
    }
    
    // Continue with normal save flow...
}
```

### Step 4: Reset Flag on Sheet Dismissal
```swift
.onChange(of: showAnalysisSheet) { oldValue, isPresented in
    if !isPresented {
        usedScanCredit = false  // Reset for next scan
    }
}
```

## Why This Works

### The Data Flow

```
ScanView (Parent)
   ├─ State: usedScanCredit = true
   ├─ oneTimeUnlockManager (has unlockInsect() method)
   │
   └─> BugAnalysisView (Child Sheet)
       ├─ Receives: onSaved callback
       ├─ Analysis completes → calls onSaved(result)
       │
       └─> Callback executes in parent scope
           ├─ Parent can access: usedScanCredit
           ├─ Parent can access: oneTimeUnlockManager
           └─> Calls: oneTimeUnlockManager.unlockInsect(result.id)
```

The key insight: The `onSaved` callback executes in the **parent scope** (ScanView), where we have access to both:
- The `usedScanCredit` flag
- The `oneTimeUnlockManager` instance

This allows us to automatically unlock the insect right after it's saved.

## Benefits

### 1. Immediate Access
Users don't need to manually unlock content they've already paid for via scan credit.

### 2. Seamless UX
```
OLD: Scan → Pay → See Locked → Confused → Close Sheet → Re-purchase?
NEW: Scan (with credit) → See Unlocked → Happy! 😊
```

### 3. Persistent Unlocks
Once unlocked via scan credit, the insect stays unlocked forever:
- Saved in UserDefaults via `OneTimeUnlockManager`
- Available in Collection view
- No need to pay again

### 4. Clear Value Proposition
Users understand what they're buying:
- **ONE SCAN** = 1 insect unlocked forever
- **UNLIMITED** = All insects unlocked (subscription)

## Testing Scenarios

### Scenario 1: Free Daily Scan (Should NOT Unlock)
```
1. New user opens app (3 free scans, 0 credits)
2. Takes photo #1 → usedScanCredit = false (free scan)
3. Analysis completes → NO auto-unlock (onSaved skips unlock)
4. Views result → Premium content LOCKED ✅
5. User can unlock by:
   - Buying "ONE SCAN" for this insect
   - Subscribing to "UNLIMITED"
```

### Scenario 2: Paid Scan Credit (Should Auto-Unlock)
```
1. User has used all 3 free scans (scansRemaining = 0)
2. Purchases "ONE SCAN" from profile → availableScanCredits = 1
3. Takes photo #4 → usedScanCredit = true (paid credit consumed)
4. Analysis completes → Insect auto-unlocked ✅
5. Views result → Premium content VISIBLE ✅
6. Re-opens from collection → Still unlocked ✅
```

### Scenario 3: Mix of Free and Paid Scans
```
1. New user: 3 free scans, 0 credits
2. Scan #1 (free) → Content locked ❌
3. Scan #2 (free) → Content locked ❌
4. Scan #3 (free) → Content locked ❌
5. Buys 2x "ONE SCAN" → availableScanCredits = 2
6. Scan #4 (paid credit) → Content unlocked ✅
7. Scan #5 (paid credit) → Content unlocked ✅
8. Next day: 3 free scans reset
9. Scan #6 (free) → Content locked ❌
```

### Scenario 4: Re-viewing Unlocked Insect
```
1. User has previously unlocked "Ladybug" via scan credit
2. Opens Collection → Taps "Ladybug"
3. BugAnalysisView checks: isInsectUnlocked("ladybug-id") → true
4. Shows premium content immediately ✅
```

### Scenario 3: Pro User (No Credits Needed)
```
1. User has active subscription
2. Takes photo → usedScanCredit = false (subscription covers it)
3. Analysis completes → No auto-unlock needed
4. hasAccessToPremiumContent returns true anyway (isPro) ✅
5. All content visible regardless of unlock status ✅
```

### Scenario 5: Multiple Paid Credits
```
1. User buys 3x "ONE SCAN" → availableScanCredits = 3
2. Scans Bug A → Credit used, auto-unlocked ✅
3. Scans Bug B → Credit used, auto-unlocked ✅
4. Scans Bug C → Credit used, auto-unlocked ✅
5. All 3 bugs permanently unlocked in Collection ✅
```

## Edge Cases Handled

### What if analysis fails?
```swift
// Analysis fails/errors
→ onSaved never called
→ Credit already consumed (can't refund automatically)
→ User retains unlock for any previous successful scans
```

### What if user dismisses sheet during analysis?
```swift
// Sheet dismissed mid-analysis
→ Task cancelled
→ onSaved never called
→ Credit already consumed (but no unlock granted)
→ User can try again with remaining credits/scans
```

### What if user cancels subscription?
```swift
// User was Pro, then cancels
→ Previously unlocked insects (via credits) remain unlocked ✅
→ New insects will be locked (no active subscription)
→ User can still buy credits for individual insects
```

## Related Files

- `ScanView.swift` - Added credit tracking and auto-unlock logic
- `BugAnalysisView.swift` - Checks `isInsectUnlocked()` to show content
- `OneTimeUnlockManager.swift` - Manages unlocked insect IDs
- `PaywallView.swift` - Handles purchase and unlock for specific insects

## Summary

This fix ensures that when users purchase and consume a **paid** one-time scan credit, they immediately get access to the premium content for that insect—no additional steps required. The unlock is permanent and persists across app sessions.

**CRITICAL:** Free daily scans do NOT unlock premium content. Only paid scan credits and Pro subscriptions unlock content.
### Content Access Matrix

| Scan Type | Content Unlocked? | User Pays? |
|-----------|------------------|------------|
| Free daily scan (1-3) | ❌ NO | ❌ Free |
| Paid scan credit | ✅ YES (forever) | ✅ $X per scan |
| Pro subscription | ✅ YES (all insects) | ✅ $X/month |

**Before Fix:**
- Free scans → Content locked ✅ (correct)
- Paid credit → Content locked ❌ (bug!)
- Pro subscription → Content unlocked ✅ (correct)

**After Fix:**
- Free scans → Content locked ✅ (correct)
- Paid credit → Content unlocked ✅ (fixed!)
- Pro subscription → Content unlocked ✅ (correct)


