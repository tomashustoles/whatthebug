//
//  OneTimeUnlockManager.swift
//  Bug
//
//  Manages one-time insect unlocks (non-subscription purchases)
//

import Foundation
import Combine

@MainActor
class OneTimeUnlockManager: ObservableObject {
    static let shared = OneTimeUnlockManager()
    
    @Published private(set) var unlockedInsectIDs: Set<String> = []
    @Published private(set) var availableScanCredits: Int = 0
    
    private let unlockedInsectsKey = "unlockedInsectIDs"
    private let scanCreditsKey = "availableScanCredits"
    
    private init() {
        loadUnlockedInsects()
        loadScanCredits()
    }
    
    // MARK: - Check if Insect is Unlocked
    
    func isInsectUnlocked(_ insectID: String) -> Bool {
        return unlockedInsectIDs.contains(insectID)
    }
    
    // MARK: - Unlock Insect
    
    func unlockInsect(_ insectID: String) {
        unlockedInsectIDs.insert(insectID)
        saveUnlockedInsects()
        print("[OneTimeUnlockManager] Unlocked insect: \(insectID)")
    }
    
    // MARK: - Scan Credits
    
    func addScanCredit() {
        availableScanCredits += 1
        saveScanCredits()
        print("[OneTimeUnlockManager] Added scan credit. Total: \(availableScanCredits)")
    }
    
    func useScanCredit() -> Bool {
        guard availableScanCredits > 0 else {
            print("[OneTimeUnlockManager] No scan credits available")
            return false
        }
        availableScanCredits -= 1
        saveScanCredits()
        print("[OneTimeUnlockManager] Used scan credit. Remaining: \(availableScanCredits)")
        return true
    }
    
    var hasScanCredits: Bool {
        return availableScanCredits > 0
    }
    
    // MARK: - Persistence
    
    private func saveUnlockedInsects() {
        let array = Array(unlockedInsectIDs)
        UserDefaults.standard.set(array, forKey: unlockedInsectsKey)
    }
    
    private func loadUnlockedInsects() {
        if let array = UserDefaults.standard.array(forKey: unlockedInsectsKey) as? [String] {
            unlockedInsectIDs = Set(array)
            print("[OneTimeUnlockManager] Loaded \(unlockedInsectIDs.count) unlocked insects")
        }
    }
    
    private func saveScanCredits() {
        UserDefaults.standard.set(availableScanCredits, forKey: scanCreditsKey)
    }
    
    private func loadScanCredits() {
        availableScanCredits = UserDefaults.standard.integer(forKey: scanCreditsKey)
        print("[OneTimeUnlockManager] Loaded \(availableScanCredits) scan credits")
    }
    
    // MARK: - Reset (for testing)
    
    func resetAllUnlocks() {
        unlockedInsectIDs.removeAll()
        availableScanCredits = 0
        saveUnlockedInsects()
        saveScanCredits()
        print("[OneTimeUnlockManager] Reset all unlocks and credits")
    }
}
