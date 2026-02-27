//
//  InsectStore.swift
//  Bug
//
//  Bug ID — Persistent store for captured insects
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class InsectStore {
    private(set) var insects: [CapturedInsect] = []
    private let storageKey = "capturedInsects"
    
    init() {
        load()
    }
    
    func add(insect: CapturedInsect) {
        insects.insert(insect, at: 0)
        save()
    }
    
    func remove(insect: CapturedInsect) {
        insects.removeAll { $0.id == insect.id }
        if let path = insect.imagePath {
            try? FileManager.default.removeItem(atPath: path)
        }
        save()
    }

    func updateBugResult(for insect: CapturedInsect, _ result: BugResult) {
        guard let idx = insects.firstIndex(where: { $0.id == insect.id }) else { return }
        var updated = insects[idx]
        updated.bugResult = result
        insects[idx] = updated
        save()
    }
    
    func removeAll() {
        for insect in insects {
            if let path = insect.imagePath {
                try? FileManager.default.removeItem(atPath: path)
            }
        }
        insects.removeAll()
        save()
    }
    
    private func save() {
        let data = try? JSONEncoder().encode(insects)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CapturedInsect].self, from: data) else { return }
        insects = decoded
    }
    
    static func saveImage(_ image: UIImage, id: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = "\(id.uuidString).jpg"
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let url = cacheDir.appendingPathComponent("InsectImages").appendingPathComponent(filename)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            return url.path
        } catch {
            return nil
        }
    }
}
