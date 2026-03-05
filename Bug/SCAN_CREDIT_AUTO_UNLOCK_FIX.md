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
        // Using free daily scan
        scanLimitManager.incrementScanCount()
        usedScanCredit = false  ✅ No credit used
    } else {
        // Using scan credit
        let creditUsed = oneTimeUnlockManager.useScanCredit()
        usedScanCredit = creditUsed  ✅ Mark that credit was used
    }
}
```

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

### Scenario 1: Fresh User with Credit
```
1. New user opens app (3 free scans, 0 credits)
2. Purchases "ONE SCAN" from profile → availableScanCredits = 1
3. Uses all 3 free scans → scansRemaining = 0
4. Takes 4th photo → usedScanCredit = true (credit consumed)
5. Analysis completes → Insect auto-unlocked
6. Views result → Premium content visible ✅
```

### Scenario 2: Re-viewing Unlocked Insect
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
```

### Scenario 4: Multiple Credits
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

This fix ensures that when users purchase and consume a one-time scan credit, they immediately get access to the premium content for that insect—no additional steps required. The unlock is permanent and persists across app sessions.

**Before:** Scan credit consumed → Content locked → User confused  
**After:** Scan credit consumed → Content unlocked → User happy 🎉
