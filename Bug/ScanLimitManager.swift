//
//  ScanLimitManager.swift
//  Bug
//
//  Bug ID — Daily scan limit manager for free users
//

import Foundation
import Combine

@MainActor
@Observable
final class ScanLimitManager {
    static let shared = ScanLimitManager()
    
    private(set) var dailyScansUsed: Int = 0
    let maxDailyScans = 3
    
    private let scansUsedKey = "dailyScansUsed"
    private let lastResetDateKey = "lastScanResetDate"
    
    private init() {
        checkAndResetIfNeeded()
        loadScansUsed()
    }
    
    var scansRemaining: Int {
        max(0, maxDailyScans - dailyScansUsed)
    }
    
    var hasScansRemaining: Bool {
        dailyScansUsed < maxDailyScans
    }
    
    func canScan(isPro: Bool) -> Bool {
        if isPro {
            return true
        }
        return hasScansRemaining
    }
    
    func incrementScanCount() {
        dailyScansUsed += 1
        save()
    }
    
    func resetForNewDay() {
        dailyScansUsed = 0
        save()
        UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
    }
    
    private func checkAndResetIfNeeded() {
        guard let lastReset = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date else {
            // First time, set the reset date
            UserDefaults.standard.set(Date(), forKey: lastResetDateKey)
            return
        }
        
        // Check if we're on a different day
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastReset) {
            resetForNewDay()
        }
    }
    
    private func loadScansUsed() {
        dailyScansUsed = UserDefaults.standard.integer(forKey: scansUsedKey)
    }
    
    private func save() {
        UserDefaults.standard.set(dailyScansUsed, forKey: scansUsedKey)
    }
}
