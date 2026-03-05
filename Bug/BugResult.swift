//
//  BugResult.swift
//  Bug
//
//  Bug ID — Structured response model for OpenAI Vision API analysis
//

import Foundation

struct BugResult: Codable, Sendable, Equatable, Identifiable {
    // Unique identifier for tracking unlocks
    let id: String
    
    // Basic identification (always present)
    let commonName: String
    let scientificName: String
    let habitat: String
    let lifeStage: String
    let isPest: Bool
    let dangerLevel: String
    let dangerDescription: String
    
    // Location & finding (always present)
    let howToFind: String
    let howToEliminate: String
    
    // PREMIUM: Geographic & seasonal data (optional for backward compatibility)
    let commonCountries: [String]?
    let seasonalActivity: String?
    
    // PREMIUM: Encounter response guide (optional for backward compatibility)
    let whatToDoSingleEncounter: String?
    let whatToDoFewEncounters: String?
    let whatToDoManyEncounters: String?
    
    // PREMIUM: Elimination strategies (optional for backward compatibility)
    let shortTermElimination: String?
    let longTermElimination: String?
    
    // PREMIUM: Expert guidance (optional for backward compatibility)
    let proTips: String?
    let communityWisdom: String?

    enum CodingKeys: String, CodingKey {
        case id
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case habitat
        case lifeStage = "life_stage"
        case isPest = "is_pest"
        case dangerLevel = "danger_level"
        case dangerDescription = "danger_description"
        case howToFind = "how_to_find"
        case howToEliminate = "how_to_eliminate"
        case commonCountries = "common_countries"
        case seasonalActivity = "seasonal_activity"
        case whatToDoSingleEncounter = "what_to_do_single"
        case whatToDoFewEncounters = "what_to_do_few"
        case whatToDoManyEncounters = "what_to_do_many"
        case shortTermElimination = "short_term_elimination"
        case longTermElimination = "long_term_elimination"
        case proTips = "pro_tips"
        case communityWisdom = "community_wisdom"
    }
    
    // Custom init for generating ID from scientific name
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode ID, or generate unique UUID
        if let decodedID = try? container.decode(String.self, forKey: .id) {
            id = decodedID
        } else {
            // Generate unique ID for each analysis
            id = UUID().uuidString
        }
        
        commonName = try container.decode(String.self, forKey: .commonName)
        scientificName = try container.decode(String.self, forKey: .scientificName)
        habitat = try container.decode(String.self, forKey: .habitat)
        lifeStage = try container.decode(String.self, forKey: .lifeStage)
        isPest = try container.decode(Bool.self, forKey: .isPest)
        dangerLevel = try container.decode(String.self, forKey: .dangerLevel)
        dangerDescription = try container.decode(String.self, forKey: .dangerDescription)
        howToFind = try container.decode(String.self, forKey: .howToFind)
        howToEliminate = try container.decode(String.self, forKey: .howToEliminate)
        commonCountries = try? container.decode([String].self, forKey: .commonCountries)
        seasonalActivity = try? container.decode(String.self, forKey: .seasonalActivity)
        whatToDoSingleEncounter = try? container.decode(String.self, forKey: .whatToDoSingleEncounter)
        whatToDoFewEncounters = try? container.decode(String.self, forKey: .whatToDoFewEncounters)
        whatToDoManyEncounters = try? container.decode(String.self, forKey: .whatToDoManyEncounters)
        shortTermElimination = try? container.decode(String.self, forKey: .shortTermElimination)
        longTermElimination = try? container.decode(String.self, forKey: .longTermElimination)
        proTips = try? container.decode(String.self, forKey: .proTips)
        communityWisdom = try? container.decode(String.self, forKey: .communityWisdom)
    }
    
    // Helper computed properties for safe unwrapping with defaults
    var safeCommonCountries: [String] {
        commonCountries ?? ["Data unavailable"]
    }
    
    var safeSeasonalActivity: String {
        seasonalActivity ?? "Unknown"
    }
    
    var safeWhatToDoSingle: String {
        whatToDoSingleEncounter ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    var safeWhatToDoFew: String {
        whatToDoFewEncounters ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    var safeWhatToDoMany: String {
        whatToDoManyEncounters ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    var safeShortTermElimination: String {
        shortTermElimination ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    var safeLongTermElimination: String {
        longTermElimination ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    var safeProTips: String {
        proTips ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    var safeCommunityWisdom: String {
        communityWisdom ?? "Data unavailable. Re-analyze for detailed guidance."
    }
    
    /// Returns true if this result has all premium fields (new analysis)
    var hasEnhancedData: Bool {
        commonCountries != nil &&
        seasonalActivity != nil &&
        whatToDoSingleEncounter != nil &&
        whatToDoFewEncounters != nil &&
        whatToDoManyEncounters != nil &&
        shortTermElimination != nil &&
        longTermElimination != nil &&
        proTips != nil &&
        communityWisdom != nil
    }
}
