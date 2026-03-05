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
        do {
            let data = try JSONEncoder().encode(insects)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("[InsectStore] Save failed: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            var decoded = try JSONDecoder().decode([CapturedInsect].self, from: data)
            
            // Fix image paths: Migrate from old full paths to new Documents directory
            // (iOS can change the Documents path between app launches)
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            
            for i in decoded.indices where decoded[i].imagePath != nil {
                let oldPath = decoded[i].imagePath!
                
                // Check if file exists at current path
                if FileManager.default.fileExists(atPath: oldPath) {
                    // Path is still valid
                    continue
                }
                
                // Try to migrate from old path
                // Extract just the filename from the old path
                let filename = URL(fileURLWithPath: oldPath).lastPathComponent
                
                if let documentsDir = documentsDir {
                    let newURL = documentsDir
                        .appendingPathComponent("InsectImages")
                        .appendingPathComponent(filename)
                    
                    if FileManager.default.fileExists(atPath: newURL.path) {
                        // Update to new path
                        decoded[i].imagePath = newURL.path
                        print("[InsectStore] Migrated image path: \(filename)")
                    } else {
                        // File doesn't exist anywhere, clear the path
                        decoded[i].imagePath = nil
                        print("[InsectStore] Image file not found: \(filename)")
                    }
                }
            }
            
            insects = decoded
            
            // Save with updated paths
            save()
        } catch {
            print("[InsectStore] Load failed: \(error)")
        }
    }
    
    /// Saves image to Documents directory so it persists across app reinstalls and survives
    /// low-storage cache purges. UserDefaults already persists the metadata (names, bugResult).
    static func saveImage(_ image: UIImage, id: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = "\(id.uuidString).jpg"
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let url = documentsDir.appendingPathComponent("InsectImages").appendingPathComponent(filename)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            print("[InsectStore] Saved image: \(url.path)")
            return url.path
        } catch {
            print("[InsectStore] Failed to save image: \(error)")
            return nil
        }
    }
    
    /// Get the current correct path for an image filename
    /// This handles iOS sandbox path changes between app launches
    static func currentPath(for filename: String) -> String? {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = documentsDir.appendingPathComponent("InsectImages").appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: url.path) ? url.path : nil
    }
}
