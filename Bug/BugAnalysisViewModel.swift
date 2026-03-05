//
//  BugAnalysisViewModel.swift
//  Bug
//
//  Bug ID — View model for analysis flow and sheet state
//

import Foundation
import SwiftUI

enum BugAnalysisState: Sendable, Equatable {
    case idle
    case loading
    case success(BugResult)
    case error(String)

    var successValue: BugResult? {
        if case .success(let result) = self { return result }
        return nil
    }
}

@MainActor
@Observable
final class BugAnalysisViewModel {
    var state: BugAnalysisState = .idle
    private let visionService = OpenAIVisionService(apiKey: Configuration.openAIAPIKey)

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    /// True when idle (before analysis starts) or loading — show loading UI in both cases
    var shouldShowLoading: Bool {
        switch state {
        case .idle, .loading: return true
        default: return false
        }
    }

    var canDismiss: Bool {
        !isLoading
    }

    func analyze(image: UIImage) async {
        print("[BugAnalysisViewModel] Starting analysis...")
        state = .loading
        
        do {
            let result = try await visionService.analyzeImage(image)
            
            // Check if task was cancelled before setting success
            try Task.checkCancellation()
            
            print("[BugAnalysisViewModel] Analysis successful: \(result.commonName)")
            state = .success(result)
            
        } catch is CancellationError {
            // Don't set error state on cancellation - view is being dismissed
            print("[BugAnalysisViewModel] Task was cancelled - ignoring")
            return
            
        } catch let error as OpenAIVisionError {
            print("[BugAnalysisViewModel] OpenAI error: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
            
        } catch {
            // Check if this is actually a cancellation error with a different type
            if error.localizedDescription.contains("cancelled") || error.localizedDescription.contains("canceled") {
                print("[BugAnalysisViewModel] Detected cancellation via error message - ignoring")
                return
            }
            
            print("[BugAnalysisViewModel] Unexpected error: \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }

    func reset() {
        state = .idle
    }
}
