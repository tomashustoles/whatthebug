# One Scan Credit System Implementation

## ✅ Fixed: "One Scan" Now Works Properly

The one-time purchase now has **context-aware behavior** depending on where the paywall is opened from.

---

## 🎯 How It Works Now

### Scenario 1: User Opens Paywall from Bug Details (Locked Content)
**Context:** Viewing a specific insect's locked premium content

```
User flow:
1. Scan an insect → See locked content cards
2. Tap locked card → Paywall opens
3. Select "THIS BUG" (€2.99)
4. Purchase → Unlocks ONLY this specific insect
5. Premium content now visible for THIS bug
```

**Result:** The specific insect ID is added to unlocked list

---

### Scenario 2: User Opens Paywall from Scan Counter or Profile
**Context:** Not viewing any specific bug

```
User flow:
1. Tap scan counter circle (shows "3 left")
2. Paywall opens
3. Select "ONE SCAN" (€2.99)
4. Purchase → Adds +1 scan credit
5. Counter now shows "4 left" (3 daily + 1 credit)
```

**Result:** User gets 1 additional scan to use whenever they want

---

## 📊 Scan Counter Display

The counter now shows **total available scans**:

```swift
Total Scans = Daily Limit Remaining + Scan Credits
```

**Examples:**
- Daily: 2/3 used, Credits: 0 → Shows **"1 left"**
- Daily: 3/3 used, Credits: 1 → Shows **"1 left"**
- Daily: 1/3 used, Credits: 2 → Shows **"4 left"** (2 + 2)
- Pro user → Shows **"999 left"** (unlimited)

---

## 🔧 Technical Implementation

### 1. **OneTimeUnlockManager.swift** (Updated)

**Added scan credits tracking:**

```swift
@Published private(set) var availableScanCredits: Int = 0

func addScanCredit() {
    availableScanCredits += 1
    saveScanCredits()
}

func useScanCredit() -> Bool {
    guard availableScanCredits > 0 else { return false }
    availableScanCredits -= 1
    saveScanCredits()
    return true
}

var hasScanCredits: Bool {
    return availableScanCredits > 0
}
```

**Persistence:**
- Unlocked insects → `UserDefaults` key: `"unlockedInsectIDs"`
- Scan credits → `UserDefaults` key: `"availableScanCredits"`

---

### 2. **PaywallView** (Updated)

**Context-aware purchase logic:**

```swift
private func purchase() async {
    try await purchaseManager.purchase(product)
    
    if selectedProductType == .oneTime {
        if let bugResult = currentBugResult {
            // Has specific bug → Unlock THIS insect
            OneTimeUnlockManager.shared.unlockInsect(bugResult.id)
        } else {
            // No specific bug → Add scan credit
            OneTimeUnlockManager.shared.addScanCredit()
        }
    }
}
```

---

### 3. **ScanView** (Updated)

**Shows total scans available:**

```swift
private var totalScansRemaining: Int {
    if purchaseManager.isPro {
        return 999
    }
    return scanLimitManager.scansRemaining + oneTimeUnlockManager.availableScanCredits
}
```

**Uses credits when daily limit exhausted:**

```swift
if scanLimitManager.canScan(isPro: false) {
    scanLimitManager.incrementScanCount()
} else {
    // Use scan credit
    _ = oneTimeUnlockManager.useScanCredit()
}
```

---

## 🔄 Complete User Flows

### Flow A: Buy "ONE SCAN" from Counter → Use for New Scan

```
1. User has 0 daily scans left
2. Taps counter → Paywall opens
3. Buys "ONE SCAN" (€2.99)
4. Counter updates: "1 left"
5. User scans a bug
6. Credit is used automatically
7. Counter updates: "0 left"
8. Bug analysis proceeds normally
```

---

### Flow B: Buy "THIS BUG" from Locked Content → Unlock Specific Insect

```
1. User scans Bug A
2. Sees locked content
3. Taps locked card → Paywall opens
4. Buys "THIS BUG" (€2.99)
5. Bug A premium content unlocks
6. User scans Bug B next time
7. Bug B is still locked
8. Counter still shows same daily scans (credit not used)
```

---

### Flow C: Buy "ONE SCAN" → Use on Old Locked Analysis

```
1. User previously scanned Bug A (locked content)
2. Buys "ONE SCAN" from counter
3. Goes to Collection
4. Views Bug A
5. Content still locked (credit for NEW scans only)
6. User taps locked card
7. Buys "THIS BUG" to unlock Bug A specifically
```

---

## 📈 Data Persistence

### UserDefaults Storage:

**Unlocked Insects:**
```json
"unlockedInsectIDs": [
    "UUID-ABC-123",  // Bug A
    "UUID-DEF-456"   // Bug C  
]
```

**Scan Credits:**
```json
"availableScanCredits": 2
```

**Daily Scans:**
```json
"dailyScansUsed": 3,
"lastScanDate": "2026-03-01"
```

---

## 🎯 Business Logic

### When Daily Limit Resets (New Day):
- `dailyScansUsed` → 0
- `scansRemaining` → 3
- **Credits remain unchanged**
- Counter shows: Daily (3) + Credits

### When Using Scans:
1. **First priority:** Use daily scans
2. **When daily exhausted:** Use credits
3. **When both exhausted:** Show paywall

### When Buying "ONE SCAN":
- **With specific bug:** Unlock that bug ID
- **Without specific bug:** Add 1 credit

---

## ✨ Key Features

✅ **Scan credits never expire**  
✅ **Credits stack** (can buy multiple)  
✅ **Credits used after daily limit** exhausted  
✅ **Counter shows total** available scans  
✅ **Context-aware purchases** (bug unlock vs credit)  
✅ **Persists across app sessions**  

---

## 🧪 Testing Scenarios

### Test 1: Buy Credit from Counter
- [ ] Open scan counter paywall
- [ ] Buy "ONE SCAN"
- [ ] Verify counter increases by 1
- [ ] Scan a bug
- [ ] Verify credit is used
- [ ] Counter decreases by 1

### Test 2: Buy Bug Unlock from Details
- [ ] Scan an insect
- [ ] Tap locked content card
- [ ] Buy "THIS BUG"
- [ ] Verify premium content unlocks
- [ ] Scan different insect
- [ ] Verify new insect still locked
- [ ] Counter unchanged (credit not used)

### Test 3: Credits + Daily Limit
- [ ] User has 1 daily scan + 2 credits
- [ ] Counter shows "3 left"
- [ ] Scan Bug A → Uses daily scan
- [ ] Counter shows "2 left"
- [ ] Scan Bug B → Uses credit
- [ ] Counter shows "1 left"
- [ ] Scan Bug C → Uses credit
- [ ] Counter shows "0 left"

### Test 4: Credit Persistence
- [ ] Buy 2 scan credits
- [ ] Force quit app
- [ ] Reopen app
- [ ] Verify credits still available
- [ ] Counter shows correct total

---

## 💡 User Benefits

1. **Flexibility:** Buy credits to save for later
2. **No expiry:** Credits last forever
3. **Clear value:** See exactly how many scans available
4. **Smart usage:** Credits only used when needed
5. **Precise unlocks:** Can unlock specific insects

---

## 🚀 Summary

**"ONE SCAN" purchase now has dual functionality:**

| Context | Action | Result |
|---------|--------|--------|
| From locked bug details | Unlock THIS bug | Specific insect unlocked |
| From scan counter/profile | Add scan credit | +1 scan available |
| Credits + daily limit | Smart usage | Daily first, then credits |

The system is now fully functional with context-aware behavior! 🎉
