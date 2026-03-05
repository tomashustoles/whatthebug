# Paywall Triggers - Quick Reference

## 🎯 Where Users Can Upgrade to Pro

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│  TRIGGER 1: Scan Counter Circle                           │
│  ┌──────────────────────────────────┐                     │
│  │  Camera View                     │                     │
│  │                                  │                     │
│  │              [Capture Square]    │                     │
│  │                                  │                     │
│  │  [📷]  [⚪ Capture]  [3️⃣ left]  │ ← TAP HERE         │
│  │                        👆        │                     │
│  └──────────────────────────────────┘                     │
│  ACTION: Tap the "3 left" circle                         │
│  RESULT: Paywall sheet opens                             │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  TRIGGER 2: Locked Content Cards                          │
│  ┌──────────────────────────────────┐                     │
│  │  Analysis Results                │                     │
│  │                                  │                     │
│  │  ✅ PEST: NO                    │                     │
│  │  ✅ DANGER: SAFE                │                     │
│  │                                  │                     │
│  │  🔒 HABITAT & ACTIVITY          │ ← TAP ANY CARD     │
│  │     PRO ONLY          👆        │                     │
│  │                                  │                     │
│  │  🔒 COMMON LOCATIONS            │                     │
│  │     PRO ONLY                    │                     │
│  └──────────────────────────────────┘                     │
│  ACTION: Tap any locked card (9 total)                   │
│  RESULT: Paywall sheet opens                             │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  TRIGGER 3: Daily Scans Card in Profile                  │
│  ┌──────────────────────────────────┐                     │
│  │  Profile Tab                     │                     │
│  │                                  │                     │
│  │  DAILY SCANS                     │                     │
│  │  ┌────────────────────────────┐  │                     │
│  │  │ Daily Scans        ◐ 1    │  │ ← TAP CARD         │
│  │  │ 2/3 used today     👆     │  │                     │
│  │  └────────────────────────────┘  │                     │
│  │                                  │                     │
│  └──────────────────────────────────┘                     │
│  ACTION: Tap the Daily Scans card                        │
│  RESULT: Paywall sheet opens                             │
│                                                            │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  TRIGGER 4: Daily Limit Alert                            │
│  ┌──────────────────────────────────┐                     │
│  │  ⚠️ Daily Limit Reached         │                     │
│  │                                  │                     │
│  │  You've used all 3 daily scans. │                     │
│  │  Upgrade to Pro for unlimited   │                     │
│  │  scans!                          │                     │
│  │                                  │                     │
│  │  ┌──────────────────┐            │                     │
│  │  │ Upgrade to Pro   │ 👆        │ ← TAP BUTTON       │
│  │  └──────────────────┘            │                     │
│  │  ┌──────────────────┐            │                     │
│  │  │     Cancel       │            │                     │
│  │  └──────────────────┘            │                     │
│  └──────────────────────────────────┘                     │
│  ACTION: Use all 3 scans, try again, tap "Upgrade to Pro"│
│  RESULT: Paywall sheet opens                             │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## 🎨 Paywall Sheet Appearance

All 4 triggers show the same professional paywall:

```
┌────────────────────────────────────┐
│  Upgrade to Pro            [Done]  │ ← Navigation bar
├────────────────────────────────────┤
│                                    │
│    WhatTheBug Pro ✦                │
│                                    │
│    Unlimited Identifications       │
│    Full Insect Details             │
│    Priority Support                │
│                                    │
│    [Subscribe for $4.99/month]     │
│    [Subscribe for $29.99/year]     │
│                                    │
│    Restore Purchase                │
│                                    │
└────────────────────────────────────┘
```

## ✅ Implementation Status

| Trigger | Location | Status | Tap Target |
|---------|----------|--------|------------|
| 1️⃣ Scan Counter | ScanView | ✅ Done | Circle with "3 left" |
| 2️⃣ Locked Cards | BugAnalysisView | ✅ Done | Any "PRO ONLY" card |
| 3️⃣ Daily Scans | ProfileView | ✅ Done | Daily Scans card |
| 4️⃣ Limit Alert | ScanView | ✅ Done | "Upgrade to Pro" button |

## 🚀 Files Changed

1. **ScanView.swift**
   - Added scan counter tap handler
   - Updated limit alert with upgrade button
   - Added paywall sheet

2. **BugAnalysisView.swift**
   - Made locked cards tappable
   - Added paywall sheet
   - *(Previously completed)*

3. **ProfileView.swift**
   - Made Daily Scans card tappable
   - Uses existing paywall sheet

## 🎯 User Benefits

✅ **Easy Discovery** - Multiple clear paths to upgrade  
✅ **Context-Aware** - Triggers appear when most relevant  
✅ **Non-Intrusive** - All user-initiated (tap to see)  
✅ **Consistent** - Same paywall experience everywhere  
✅ **Professional** - Clean navigation and dismissal

All paywall triggers are now live and ready to convert users! 🎉
