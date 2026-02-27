//
//  CapturedInsect.swift
//  Bug
//
//  Bug ID — Model for a captured and analyzed insect
//

import Foundation
import UIKit

struct CapturedInsect: Identifiable, Codable {
    let id: UUID
    let commonName: String
    let scientificName: String
    let capturedAt: Date
    var imagePath: String?
    var bugResult: BugResult?
    
    init(id: UUID = UUID(), commonName: String, scientificName: String, capturedAt: Date = Date(), imagePath: String? = nil, bugResult: BugResult? = nil) {
        self.id = id
        self.commonName = commonName
        self.scientificName = scientificName
        self.capturedAt = capturedAt
        self.imagePath = imagePath
        self.bugResult = bugResult
    }
}
