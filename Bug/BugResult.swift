//
//  BugResult.swift
//  Bug
//
//  Bug ID — Structured response model for OpenAI Vision API analysis
//

import Foundation

struct BugResult: Codable, Sendable, Equatable {
    let commonName: String
    let scientificName: String
    let habitat: String
    let lifeStage: String
    let isPest: Bool
    let dangerLevel: String
    let dangerDescription: String
    let howToFind: String
    let howToEliminate: String

    enum CodingKeys: String, CodingKey {
        case commonName = "common_name"
        case scientificName = "scientific_name"
        case habitat
        case lifeStage = "life_stage"
        case isPest = "is_pest"
        case dangerLevel = "danger_level"
        case dangerDescription = "danger_description"
        case howToFind = "how_to_find"
        case howToEliminate = "how_to_eliminate"
    }
}
