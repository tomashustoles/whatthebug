//
//  OneTimeUnlockManager.swift
//  Bug
//
//  Manages one-time insect unlocks (non-subscription purchases)
//

import Foundation

@MainActor
final class OneTimeUnlockManager: ObservableObject {
    static let shared = OneTimeUnlockManager()
    
    @Published private(set) var unlockedInsectIDs: Set<String> = []
    
    private let userDefaultsKey = "unlockedInsectIDs"
    
    private init() {
        loadUnlockedInsects()
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
    
    // MARK: - Get Next Unlock Count
    
    var availableOneTimeUnlocks: Int {
        // This will be managed by checking StoreKit transactions
        // For now, return 0 - will be updated when one-time purchase is made
        return 0
    }
    
    // MARK: - Persistence
    
    private func saveUnlockedInsects() {
        let array = Array(unlockedInsectIDs)
        UserDefaults.standard.set(array, forKey: userDefaultsKey)
    }
    
    private func loadUnlockedInsects() {
        if let array = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            unlockedInsectIDs = Set(array)
            print("[OneTimeUnlockManager] Loaded \(unlockedInsectIDs.count) unlocked insects")
        }
    }
    
    // MARK: - Reset (for testing)
    
    func resetAllUnlocks() {
        unlockedInsectIDs.removeAll()
        saveUnlockedInsects()
        print("[OneTimeUnlockManager] Reset all unlocks")
    }
}
