//
//  OpenAIVisionService.swift
//  Bug
//
//  Bug ID — OpenAI Vision API client for insect identification
//

import Foundation
import UIKit

enum OpenAIVisionError: LocalizedError {
    case invalidImage
    case apiError(String)
    case invalidResponse
    case notAnInsect
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The selected image could not be processed."
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "Unable to analyze the image. Please try again."
        case .notAnInsect:
            return "This does not appear to be an insect. Please photograph an insect for identification."
        case .decodingError(let message):
            return "Analysis failed: \(message)"
        }
    }
}

@MainActor
final class OpenAIVisionService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func analyzeImage(_ image: UIImage) async throws -> BugResult {
        let (base64Image, mimeType) = try encodeImage(image)

        let systemPrompt = """
        You are an expert entomologist. Analyze the provided image and identify the insect or bug.

        IMPORTANT: Respond with ONLY a valid JSON object—no markdown, no code blocks, no additional text.
        If the image does not clearly show an insect, arachnid, or bug, set common_name and scientific_name to "Unknown" and is_pest to false.

        Use this exact JSON structure:
        {
          "common_name": "string - common name of the insect",
          "scientific_name": "string - binomial nomenclature",
          "habitat": "string - where it typically lives",
          "life_stage": "string - e.g. adult, larva, nymph, egg",
          "is_pest": true or false,
          "danger_level": "HIGH" or "MEDIUM" or "LOW",
          "danger_description": "string - brief safety/relevance description",
          "how_to_find": "string - paragraph on how to locate this species",
          "how_to_eliminate": "string - paragraph on removal/control if pest, or 'N/A' if beneficial"
        }
        """

        let userPrompt = "Identify this insect and return the JSON object as specified."

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": systemPrompt],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": userPrompt],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:\(mimeType);base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1024,
            "response_format": ["type": "json_object"]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIVisionError.invalidResponse
        }

        if httpResponse.statusCode != 200 {
            let errorMessage = (try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data))?.error.message
                ?? "API request failed (status \(httpResponse.statusCode))"
            throw OpenAIVisionError.apiError(errorMessage)
        }

        let completion = try JSONDecoder().decode(OpenAICompletionResponse.self, from: data)
        guard let content = completion.choices.first?.message.content, !content.isEmpty else {
            throw OpenAIVisionError.invalidResponse
        }

        let cleanedContent = content
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleanedContent.data(using: .utf8) else {
            throw OpenAIVisionError.decodingError("Could not convert response to data")
        }

        let bugResult = try JSONDecoder().decode(BugResult.self, from: jsonData)

        if bugResult.commonName.lowercased() == "unknown" {
            throw OpenAIVisionError.notAnInsect
        }

        return bugResult
    }

    private func encodeImage(_ image: UIImage) throws -> (String, String) {
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw OpenAIVisionError.invalidImage
        }
        return (imageData.base64EncodedString(), "image/jpeg")
    }
}

// MARK: - OpenAI API Response Models

private struct OpenAIErrorResponse: Codable {
    let error: OpenAIError
}

private struct OpenAIError: Codable {
    let message: String
}

private struct OpenAICompletionResponse: Codable {
    let choices: [OpenAIChoice]
}

private struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

private struct OpenAIMessage: Codable {
    let content: String
}
