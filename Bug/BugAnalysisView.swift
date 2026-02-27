//
//  BugAnalysisView.swift
//  Bug
//
//  Bug ID — Analysis results sheet with NYC Metro typography
//

import SwiftUI

struct BugAnalysisView: View {
    let image: UIImage
    @Bindable var viewModel: BugAnalysisViewModel
    var onSaved: ((BugResult) -> Void)?
    /// Pre-loaded result for viewing saved insects from Collection (skips API analysis)
    var existingResult: BugResult?
    @State private var loadingPulse = false
    @State private var hasReportedSave = false

    @Environment(\.colorScheme) private var colorScheme

    private var displayResult: BugResult? {
        existingResult ?? (viewModel.state.successValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            imageHeader
            Group {
                if existingResult != nil {
                    resultView(existingResult!)
                } else if viewModel.shouldShowLoading {
                    loadingView
                } else if let result = displayResult {
                    resultView(result)
                } else if case .error(let message) = viewModel.state {
                    errorView(message)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(backgroundColor)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .task {
            guard existingResult == nil else { return }
            await viewModel.analyze(image: image)
        }
        .onChange(of: viewModel.state) { _, newState in
            if case .success(let result) = newState, !hasReportedSave {
                hasReportedSave = true
                onSaved?(result)
            }
        }
    }

    private var imageHeader: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0, green: 0, blue: 0) : Color(red: 1, green: 1, blue: 1)
    }

    private var loadingView: some View {
        Text("IDENTIFYING...")
            .font(.system(size: 32, weight: .heavy))
            .foregroundStyle(.primary)
            .opacity(loadingPulse ? 1 : 0.5)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    loadingPulse = true
                }
            }
    }

    private func errorView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("IDENTIFICATION FAILED")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(labelColor)
                .textCase(.uppercase)

            Text(message)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(32)
    }

    @ViewBuilder
    private func resultView(_ result: BugResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                headerSection(result)
                twoColumnSection(result)

                paragraphSection("HOW TO LOCATE", text: result.howToFind)
                paragraphSection("HOW TO ELIMINATE", text: result.howToEliminate)
            }
            .padding(32)
        }
    }

    private var labelColor: Color {
        colorScheme == .dark ? Color(white: 0.55) : Color(white: 0.45)
    }

    private func headerSection(_ result: BugResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.commonName)
                .font(.system(size: 44, weight: .heavy))
                .foregroundStyle(.primary)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

            Text(result.scientificName)
                .font(.system(size: 24, weight: .bold))
                .italic()
                .foregroundStyle(.primary)
        }
    }

    private func twoColumnSection(_ result: BugResult) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            metroRow("COMMON NAME", value: result.commonName)
            metroRow("SCIENTIFIC NAME", value: result.scientificName)
            metroRow("HABITAT", value: result.habitat)
            metroRow("LIFE STAGE", value: result.lifeStage)
            metroRow("PEST", value: result.isPest ? "YES" : "NO")
            metroRow("DANGER", value: result.dangerLevel, dangerLevel: result.dangerLevel)
        }
    }

    private func metroRow(_ label: String, value: String, dangerLevel: String? = nil) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(labelColor)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(dangerColor(dangerLevel))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private func dangerColor(_ level: String?) -> Color {
        guard let level = level else { return .primary }
        switch level.uppercased() {
        case "HIGH": return Color.red
        case "MEDIUM": return Color.yellow
        case "LOW": return Color.green
        default: return .primary
        }
    }

    private func paragraphSection(_ label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(labelColor)
                .textCase(.uppercase)

            Text(text)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .lineSpacing(6)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
}
