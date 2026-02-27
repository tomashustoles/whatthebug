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

    private static func loadFromPlist(key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let value = plist[key] as? String else {
            return nil
        }
        return value
    }
}
