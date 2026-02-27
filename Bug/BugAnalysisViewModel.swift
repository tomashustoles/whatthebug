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
        state = .loading
        do {
            let result = try await visionService.analyzeImage(image)
            state = .success(result)
        } catch let error as OpenAIVisionError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func reset() {
        state = .idle
    }
}
