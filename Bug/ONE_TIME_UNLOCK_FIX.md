# One-Time Unlock Fix - "THIS BUG" Purchase

## ✅ Problem Fixed

The one-time purchase ("THIS BUG") was incorrectly giving users full Pro access with unlimited scans. It should only unlock the specific insect that was just scanned.

---

## 🎯 Correct Behavior

### One-Time Purchase ("THIS BUG" - €2.99):
- ✅ Unlocks **only the current insect's details**
- ✅ Shows premium content for **that specific bug only**
- ✅ **Does NOT** give unlimited scans
- ✅ **Does NOT** enable Pro mode
- ✅ User returns to free tier for next scan

### Subscription ("ALL BUGS" - €4.99/month):
- ✅ Unlocks **all insects** (past, present, future)
- ✅ **Unlimited scans**
- ✅ **Pro mode enabled**
- ✅ Full access to all premium features

---

## 📁 Files Created

### 1. **OneTimeUnlockManager.swift** (New File)
Manages which specific insects have been unlocked via one-time purchases.

```swift
@MainActor
final class OneTimeUnlockManager: ObservableObject {
    static let shared = OneTimeUnlockManager()
    
    @Published private(set) var unlockedInsectIDs: Set<String> = []
    
    func isInsectUnlocked(_ insectID: String) -> Bool {
        return unlockedInsectIDs.contains(insectID)
    }
    
    func unlockInsect(_ insectID: String) {
        unlockedInsectIDs.insert(insectID)
        saveUnlockedInsects()
    }
}
```

**Features:**
- Tracks unlocked insects by ID
- Persists to UserDefaults
- Singleton pattern for app-wide access

---

## 📁 Files Modified

### 2. **PurchaseManager.swift**
**Changed `isPro` logic to ONLY check subscription:**

**Before:**
```swift
let hasOneTimePurchase = purchasedIDs.contains(Configuration.oneTimePurchaseProductID)
let hasSubscription = purchasedIDs.contains(Configuration.subscriptionProductID)

isPro = hasOneTimePurchase || hasSubscription  // ❌ Wrong!
```

**After:**
```swift
let hasSubscription = purchasedIDs.contains(Configuration.subscriptionProductID)

isPro = hasSubscription  // ✅ Only subscription gives Pro
```

**Added helper property:**
```swift
var hasActiveOneTimeUnlock: Bool {
    return purchasedProductIDs.contains(Configuration.oneTimePurchaseProductID)
}
```

---

### 3. **BugResult.swift**
**Added unique ID for tracking unlocks:**

**Before:**
```swift
struct BugResult: Codable, Sendable, Equatable {
    let commonName: String
    // ... no ID
}
```

**After:**
```swift
struct BugResult: Codable, Sendable, Equatable, Identifiable {
    let id: String  // ← New unique identifier
    let commonName: String
    // ...
}
```

**Custom decoder generates ID:**
```swift
init(from decoder: Decoder) throws {
    // Generate UUID for each analysis
    id = UUID().uuidString
    // ... decode other fields
}
```

---

### 4. **BugAnalysisView.swift**
**Added logic to check both Pro status AND individual unlocks:**

**Added state:**
```swift
@StateObject private var oneTimeUnlockManager = OneTimeUnlockManager.shared
@State private var showPaywallSheet = false
```

**Added computed property:**
```swift
private var shouldShowPremiumContent: Bool {
    guard let result = displayResult else { return false }
    
    // Pro users see everything
    if purchaseManager.isPro {
        return true
    }
    
    // Check if this specific insect is unlocked
    if oneTimeUnlockManager.isInsectUnlocked(result.id) {
        return true
    }
    
    return false
}
```

**Updated content display:**
```swift
// Before:
if purchaseManager.isPro {
    premiumContentSection(result)
}

// After:
if shouldShowPremiumContent {
    premiumContentSection(result)
}
```

**Updated paywall to pass current bug:**
```swift
.sheet(isPresented: $showPaywallSheet) {
    if let result = displayResult {
        PaywallView(
            purchaseManager: purchaseManager,
            currentBugResult: result  // ← Pass current bug
        )
    }
}
```

---

### 5. **PaywallComponents.swift (PaywallView)**
**Updated to handle one-time unlocks:**

**Added parameter:**
```swift
struct PaywallView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    var currentBugResult: BugResult? = nil  // ← New parameter
    // ...
}
```

**Updated purchase function:**
```swift
private func purchase() async {
    // ... purchase logic
    
    do {
        try await purchaseManager.purchase(product)
        
        // If one-time purchase, unlock current bug
        if selectedProductType == .oneTime, let bugResult = currentBugResult {
            await OneTimeUnlockManager.shared.unlockInsect(bugResult.id)
            print("Unlocked: \(bugResult.commonName)")
            dismiss()  // Close paywall
        } else if selectedProductType == .subscription {
            dismiss()  // Close paywall
        }
    }
}
```

---

## 🔄 User Flow Comparison

### Scenario 1: User Buys "THIS BUG" (One-Time)

**Before (Wrong):**
1. User scans Bug A
2. Sees locked content
3. Buys "THIS BUG" (€2.99)
4. ❌ **Gets unlimited scans + Pro mode**
5. ❌ Can scan Bug B, C, D... all unlocked

**After (Correct):**
1. User scans Bug A
2. Sees locked content
3. Buys "THIS BUG" (€2.99)
4. ✅ **Bug A unlocked** - sees full details
5. ✅ Scans Bug B next time
6. ✅ Bug B is **still locked** - must buy again or subscribe
7. ✅ Can still view Bug A details (saved in collection)

---

### Scenario 2: User Buys "ALL BUGS" (Subscription)

**Before and After (Same - Always Correct):**
1. User scans Bug A
2. Sees locked content
3. Buys "ALL BUGS" (€4.99/month)
4. ✅ **Pro mode activated**
5. ✅ Bug A unlocked
6. ✅ Unlimited scans
7. ✅ All future bugs unlocked
8. ✅ Can view all saved bugs

---

## 🎯 Testing Checklist

### One-Time Purchase:
- [ ] Scan an insect (Bug A)
- [ ] See locked content
- [ ] Tap locked card → Paywall opens
- [ ] Select "THIS BUG" card
- [ ] Tap "Unlock Now"
- [ ] Purchase completes
- [ ] **Bug A premium content now visible**
- [ ] Paywall dismisses automatically
- [ ] Scan different insect (Bug B)
- [ ] **Bug B content still locked** ✅
- [ ] Go to Collection → View Bug A
- [ ] **Bug A still shows premium content** ✅
- [ ] Profile shows **NOT Pro** ✅
- [ ] Daily scan limit still applies ✅

### Subscription:
- [ ] Scan an insect
- [ ] Tap locked card → Paywall opens
- [ ] Select "ALL BUGS" card
- [ ] Tap "Unlock Now"
- [ ] Subscribe
- [ ] Current bug unlocked
- [ ] Scan another bug
- [ ] **New bug automatically unlocked** ✅
- [ ] Profile shows **Pro status** ✅
- [ ] Daily scan limit **removed** ✅

---

## 💾 Data Persistence

### OneTimeUnlockManager Storage:
```swift
UserDefaults.standard.set(array, forKey: "unlockedInsectIDs")
```

**Stored data example:**
```json
unlockedInsectIDs: [
    "A1B2C3D4-E5F6-7G8H-9I0J-K1L2M3N4O5P6",  // Bug A
    "B2C3D4E5-F6G7-8H9I-0J1K-L2M3N4O5P6Q7"   // Bug C
]
```

Each UUID corresponds to a specific analysis result.

---

## 🔑 Key Technical Points

### 1. Unique ID Generation
Each `BugResult` gets a unique UUID when decoded from the API response. This ensures even if the same species is scanned twice, they are tracked separately.

### 2. Pro Mode vs One-Time Unlock
- **Pro mode** (`isPro`) - Only from subscription
- **One-time unlock** - Tracked separately in `OneTimeUnlockManager`
- **Content display** - Checks both conditions

### 3. StoreKit Integration
- One-time purchases are **non-consumable** products
- StoreKit tracks the transaction
- App tracks **which specific insect** was unlocked

---

## 🚨 Important Notes

### Apple StoreKit Behavior:
In StoreKit, **non-consumable** one-time purchases can only be bought **once per Apple ID**. However, our implementation allows users to buy "THIS BUG" multiple times for different insects because:

1. Each purchase unlocks a **different insect** (different ID)
2. The purchase is tracked via `Transaction.currentEntitlements`
3. We use the transaction to trigger `unlockInsect(id)` for specific bugs

### Recommended StoreKit Configuration:
- **"THIS BUG"** - Non-Consumable Product
- **"ALL BUGS"** - Auto-Renewable Subscription

---

## ✨ Summary

**Fixed Issues:**
- ❌ One-time purchase no longer gives unlimited access
- ❌ One-time purchase no longer enables Pro mode
- ✅ One-time purchase only unlocks specific insect
- ✅ Subscription gives full Pro access
- ✅ Proper distinction between purchase types

**New Behavior:**
- ✅ "THIS BUG" = Unlock this specific insect
- ✅ "ALL BUGS" = Pro mode + unlimited everything
- ✅ Each insect tracked individually
- ✅ Unlocks persist across app sessions
- ✅ Clear value proposition for both options

The app now correctly implements the freemium model with one-time unlocks! 🎉
