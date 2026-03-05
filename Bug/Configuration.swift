//
//  Configuration.swift
//  Bug
//
//  Bug ID — Loads API keys and config from Config.plist (excluded from version control)
//

import Foundation

enum Configuration {
    static var openAIAPIKey: String {
        guard let apiKey = loadFromPlist(key: "OpenAIAPIKey") else {
            fatalError("OpenAIAPIKey not found in Config.plist. Add Config.plist with key 'OpenAIAPIKey' and exclude from version control.")
        }
        return apiKey
    }

    // MARK: - StoreKit Product IDs
    
    /// TODO: Replace with your actual product IDs from App Store Connect
    /// Non-consumable in-app purchase for unlocking a single bug analysis
    static let oneTimePurchaseProductID = "com.whatthebug.unlock.once"
    
    /// TODO: Replace with your actual product ID from App Store Connect
    /// Auto-renewable subscription for unlimited bug analysis
    static let subscriptionProductID = "com.whatthebug.pro.monthly"
    
    static var productIDs: [String] {
        [oneTimePurchaseProductID, subscriptionProductID]
    }

    // MARK: - Legal URLs (for paywall and App Store)
    
    /// Terms of Use / EULA — use in paywall flow and App Store Connect → App Information
    static let termsOfUseURL = "https://tomashustoles.github.io/whatthebug/terms-of-use.html"

    private static func loadFromPlist(key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let value = plist[key] as? String else {
            return nil
        }
        return value
    }
}
