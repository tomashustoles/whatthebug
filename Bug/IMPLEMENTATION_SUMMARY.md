# Implementation Summary - Daily Scan Limits & Profile Updates

## Overview
This update implements daily scan limits for free users, adds privacy/support links to the Profile, and removes the Insects section from Profile (since they're already displayed in the Collection tab).

## Changes Made

### 1. New File: `ScanLimitManager.swift`
- **Purpose**: Manages daily scan limits for free users
- **Key Features**:
  - Tracks daily scans used (max 3 per day for free users)
  - Automatically resets counter at midnight each day
  - Persists data using UserDefaults
  - Pro users have unlimited scans
  
- **Public API**:
  - `dailyScansUsed`: Current number of scans used today
  - `maxDailyScans`: Maximum scans allowed (3)
  - `scansRemaining`: How many scans left today
  - `canScan(isPro:)`: Check if user can scan
  - `incrementScanCount()`: Increment scan counter

### 2. Updated: `ProfileView.swift`
**Removed**:
- ✗ Insects section (already in Collection tab)
- ✗ InsectRow component
- ✗ Empty insects view

**Added**:
- ✓ Daily Scans section (only visible for non-Pro users)
  - Shows "Daily Scans X/3 used today"
  - Circular progress indicator showing remaining scans
  - Color-coded (accent color when scans available, red when exhausted)
  
- ✓ App Info section with:
  - Privacy Policy link (https://tomashustoles.github.io/whatthebug/privacy-policy.html)
  - Support link (https://tomashustoles.github.io/whatthebug/support.html)
  - Both open in Safari with external link icon
  
- ✓ Integration with PurchaseManager and ScanLimitManager

### 3. Updated: `ScanView.swift`
**Added**:
- ✓ Scan limit checking before capture or photo selection
- ✓ Liquid Glass scan counter badge (right side of capture button)
  - Shows remaining scans in a circular Liquid Glass badge
  - Only visible for non-Pro users
  - Displays number remaining + "left" label
  - Uses `.glassEffect(.regular, in: .circle)` for modern iOS design
  
- ✓ Alert when daily limit is reached
  - Title: "Daily Limit Reached"
  - Message: "You've used all 3 daily scans. Upgrade to Pro for unlimited scans!"
  
- ✓ Automatic scan counter increment after successful capture/selection
- ✓ Pro users bypass all limits completely

## User Experience Flow

### Free Users:
1. Open Scan tab → See scan counter badge (e.g., "3 left")
2. Capture/select photo → Counter decrements (e.g., "2 left")
3. After 3 scans → Alert appears, no more scans until next day
4. View Profile → See "Daily Scans 3/3 used today" with visual indicator
5. Next day at midnight → Counter automatically resets to 0/3

### Pro Users:
1. Open Scan tab → No scan counter badge visible
2. Unlimited scans with no restrictions
3. Profile shows "Active" subscription status
4. No daily scans section in Profile

## Design Details

### Liquid Glass Scan Counter
- **Shape**: Circle (56x56pt)
- **Material**: Liquid Glass with `.glassEffect(.regular, in: .circle)`
- **Content**: 
  - Number (20pt bold, white)
  - "left" label (10pt medium, white 70% opacity)
- **Position**: Right side of capture button in GlassEffectContainer
- **Visibility**: Only shown to non-Pro users

### Profile Daily Scans Card
- **Layout**: Horizontal with text on left, circular progress on right
- **Progress Indicator**:
  - Circular progress ring (48x48pt)
  - Background: Gray stroke
  - Progress: Accent color (or red when exhausted)
  - Center text: Number of scans remaining

### App Info Links
- **Design**: Card with two rows
- **Each row**: Icon + Label + Arrow icon
- **Icons**: "hand.raised.fill" (privacy), "questionmark.circle.fill" (support)
- **Interaction**: Opens in Safari

## Technical Implementation

### State Management
- Uses `@Observable` for ScanLimitManager (Swift Observation framework)
- Uses `@StateObject` for PurchaseManager
- Automatic UI updates when scan count changes

### Data Persistence
- UserDefaults stores:
  - `dailyScansUsed`: Int (number of scans used)
  - `lastScanResetDate`: Date (last reset timestamp)
- Survives app restarts
- Automatic cleanup at midnight

### Date Handling
- Uses `Calendar.current.isDateInToday(_:)` for accurate day detection
- Handles timezone changes correctly
- Resets happen at device's local midnight

## Testing Checklist

- [ ] Free user sees scan counter on Scan tab
- [ ] Counter decrements after each scan
- [ ] Alert appears when limit reached
- [ ] Cannot scan after limit reached
- [ ] Profile shows correct scan count
- [ ] Counter resets at midnight (test by changing device date)
- [ ] Pro users don't see scan counter
- [ ] Pro users have unlimited scans
- [ ] Privacy Policy link opens correctly
- [ ] Support link opens correctly
- [ ] Daily Scans section hidden for Pro users
- [ ] Liquid Glass effect renders properly on counter badge

## Future Enhancements (Optional)

1. **Subscription Prompt**: Add "Upgrade to Pro" button on the alert
2. **Animated Counter**: Animate the counter decrement with a transition
3. **Reset Timer**: Show "Resets in X hours" in Profile
4. **Scan History**: Track scan history over time
5. **Analytics**: Track conversion rate from free to Pro based on scan limits

## Files Modified
1. ✓ `ScanLimitManager.swift` (NEW)
2. ✓ `ProfileView.swift` (MODIFIED)
3. ✓ `ScanView.swift` (MODIFIED)

## Dependencies
- Foundation (Date, Calendar, UserDefaults)
- SwiftUI (all UI components)
- StoreKit (PurchaseManager integration)
- Liquid Glass APIs (glassEffect, GlassEffectContainer)
