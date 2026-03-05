//
//  BugAnalysisView.swift
//  Bug
//
//  Bug ID — Premium analysis results sheet with cinematic hero + paywall
//

import SwiftUI
import StoreKit

struct BugAnalysisView: View {
    let image: UIImage
    @Bindable var viewModel: BugAnalysisViewModel
    var onSaved: ((BugResult) -> Void)?
    /// Pre-loaded result for viewing saved insects from Collection (skips API analysis)
    var existingResult: BugResult?
    @State private var loadingPulse = false
    @State private var hasReportedSave = false
    @State private var analysisTask: Task<Void, Never>?
    @State private var showPaywall = false
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var unlockManager = OneTimeUnlockManager.shared

    private var displayResult: BugResult? {
        existingResult ?? (viewModel.state.successValue)
    }
    
    /// Check if user has access to premium content (either via subscription or one-time unlock)
    private var hasAccessToPremiumContent: Bool {
        if purchaseManager.isPro {
            return true
        }
        if let result = displayResult, unlockManager.isInsectUnlocked(result.id) {
            return true
        }
        return false
    }

    var body: some View {
        let _ = print("[BugAnalysisView] body re-evaluated, state: \(viewModel.state), shouldShowLoading: \(viewModel.shouldShowLoading), displayResult: \(displayResult != nil)")
        
        return Group {
            if existingResult != nil {
                resultView(existingResult!)
            } else if viewModel.shouldShowLoading {
                loadingStateView
            } else if let result = displayResult {
                resultView(result)
            } else if case .error(let message) = viewModel.state {
                errorStateView(message)
            }
        }
        .background(Color.black)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showPaywall) {
            if let result = displayResult {
                PaywallView(purchaseManager: purchaseManager, currentBugResult: result)
            }
        }
        .onAppear {
            print("[BugAnalysisView] onAppear - existingResult: \(existingResult != nil ? "YES" : "NO")")
            
            // Only start analysis for new captures (not existing results)
            guard existingResult == nil else {
                print("[BugAnalysisView] Skipping analysis - using existingResult")
                return
            }
            
            print("[BugAnalysisView] Image size: \(image.size)")
            
            // Reset state and start analysis
            viewModel.reset()
            print("[BugAnalysisView] ViewModel reset, state: \(viewModel.state)")
            
            // Start analysis in a managed task with slight delay
            // to ensure sheet is fully presented
            analysisTask = Task { @MainActor in
                print("[BugAnalysisView] Starting analysis task...")
                
                // Small delay to ensure view is fully presented
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                // Check if we were cancelled during the delay
                guard !Task.isCancelled else {
                    print("[BugAnalysisView] Task was cancelled during delay")
                    return
                }
                
                print("[BugAnalysisView] Calling viewModel.analyze()...")
                await viewModel.analyze(image: image)
                print("[BugAnalysisView] viewModel.analyze() completed, state: \(viewModel.state)")
            }
        }
        .onDisappear {
            print("[BugAnalysisView] onDisappear - cancelling task")
            // Cancel any ongoing analysis when view disappears
            analysisTask?.cancel()
            analysisTask = nil
        }
        .onChange(of: viewModel.state) { oldState, newState in
            print("[BugAnalysisView] State changed from \(oldState) to \(newState)")
            
            if case .success(let result) = newState {
                if !hasReportedSave {
                    print("[BugAnalysisView] Success! Calling onSaved callback")
                    hasReportedSave = true
                    onSaved?(result)
                } else {
                    print("[BugAnalysisView] Success state but already reported save")
                }
            }
        }
    }

    private var heroImageHeader: some View {
        GeometryReader { geometry in
            let imageHeight = geometry.size.width * 0.75 // 4:3 aspect ratio (3/4 = 0.75)
            
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: imageHeight)
                    .clipped()
                
                // Gradient fade at bottom
                LinearGradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.5),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: imageHeight * 0.5)
            }
            .frame(width: geometry.size.width, height: imageHeight)
        }
        .aspectRatio(4/3, contentMode: .fit)
    }
    
    private var loadingStateView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Full screen image background
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Dark overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Loading text
                VStack {
                    Spacer()
                    
                    Text("IDENTIFYING...")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.white)
                        .opacity(loadingPulse ? 1 : 0.5)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                loadingPulse = true
                            }
                        }
                    
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func errorStateView(_ message: String) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Full screen image background
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Dark overlay
                Color.black.opacity(0.6)
                
                // Error text
                VStack(alignment: .center, spacing: 16) {
                    Text("IDENTIFICATION FAILED")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(.white)
                        .textCase(.uppercase)
                        .tracking(1)

                    Text(message)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                }
                .padding(.horizontal, 40)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func resultView(_ result: BugResult) -> some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image with gradient and name overlay
                    ZStack(alignment: .bottomLeading) {
                        heroImageHeader
                        
                        // Name section positioned at the bottom of the image
                        nameSection(result)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }
                    
                    // Content sections below hero
                    VStack(alignment: .leading, spacing: 24) {
                        // Free visible section
                        freeContentSection(result)
                            .padding(.horizontal, 20)
                        
                        // Locked or unlocked premium content
                        if hasAccessToPremiumContent {
                            premiumContentSection(result)
                                .padding(.horizontal, 20)
                        } else {
                            lockedContentSection()
                                .padding(.horizontal, 20)
                            
                            // Unlock button (instead of embedded paywall)
                            unlockButton()
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                                .padding(.bottom, 32)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func nameSection(_ result: BugResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if hasAccessToPremiumContent {
                // Bug common name - large condensed headline (capitalized)
                Text(result.commonName.capitalized)
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundStyle(.white)
                    .lineSpacing(-4)
                    .fixedSize(horizontal: false, vertical: true)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                // Latin name (regular weight, uppercase, not italic)
                Text(result.scientificName)
                    .font(.system(size: 11, weight: .regular, design: .default))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(Color(hex: "#888888"))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            } else {
                // Blurred name section for non-premium users
                ZStack(alignment: .leading) {
                    // Placeholder text that will be blurred
                    VStack(alignment: .leading, spacing: 8) {
                        Text(result.commonName.capitalized)
                            .font(.system(size: 36, weight: .black, design: .default))
                            .foregroundStyle(.white)
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        
                        Text(result.scientificName)
                            .font(.system(size: 11, weight: .regular, design: .default))
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .foregroundStyle(Color(hex: "#888888"))
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                    .blur(radius: 8)
                    
                    // Lock icon overlay
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            Text("UNLOCK TO REVEAL")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.2)
                                .textCase(.uppercase)
                                .foregroundStyle(.white)
                        }
                        
                        Text("Tap below to see full details")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(hex: "#888888"))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func freeContentSection(_ result: BugResult) -> some View {
        VStack(spacing: 0) {
            // PEST row
            ShadcnRow(
                label: "PEST",
                value: result.isPest ? "YES" : "NO",
                isTop: true
            )
            
            Divider()
                .background(Color(hex: "#1F1F1F"))
            
            // DANGER row with badge
            HStack(alignment: .center) {
                Text("DANGER")
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Color(hex: "#666666"))
                
                Spacer()
                
                DangerBadge(level: result.dangerLevel)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func premiumContentSection(_ result: BugResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // HABITAT, LIFE STAGE & SEASONAL ACTIVITY card
            PremiumOverviewCard(
                habitat: result.habitat,
                lifeStage: result.lifeStage,
                seasonalActivity: result.safeSeasonalActivity
            )
            
            // GEOGRAPHIC DISTRIBUTION
            GeographicDistributionCard(countries: result.safeCommonCountries)
            
            // HOW TO LOCATE
            PremiumParagraphCard(title: "HOW TO LOCATE", text: result.howToFind)
            
            // WHAT TO DO WHEN YOU SEE THEM
            EncounterResponseCard(
                singleEncounter: result.safeWhatToDoSingle,
                fewEncounters: result.safeWhatToDoFew,
                manyEncounters: result.safeWhatToDoMany
            )
            
            // ELIMINATION STRATEGIES
            EliminationStrategyCard(
                title: "SHORT-TERM (24-48 HOURS)",
                text: result.safeShortTermElimination,
                icon: "⚡",
                accentColor: Color(hex: "#F59E0B")
            )
            
            EliminationStrategyCard(
                title: "LONG-TERM (PERMANENT SOLUTION)",
                text: result.safeLongTermElimination,
                icon: "🎯",
                accentColor: Color(hex: "#22C55E")
            )
            
            // EXPERT GUIDANCE
            ExpertTipsCard(
                title: "PRO TIPS",
                text: result.safeProTips,
                icon: "💡",
                accentColor: Color(hex: "#8B5CF6")
            )
            
            ExpertTipsCard(
                title: "COMMUNITY WISDOM",
                text: result.safeCommunityWisdom,
                icon: "💬",
                accentColor: Color(hex: "#EC4899")
            )
        }
    }
    
    private func lockedContentSection() -> some View {
        VStack(spacing: 12) {
            ForEach(0..<9, id: \.self) { index in
                LockedContentCard(title: lockedCardTitle(index)) {
                    showPaywall = true
                }
            }
        }
        .padding(.top, 12)
    }
    
    private func lockedCardTitle(_ index: Int) -> String {
        switch index {
        case 0: return "HABITAT & ACTIVITY"
        case 1: return "COMMON LOCATIONS"
        case 2: return "HOW TO LOCATE"
        case 3: return "WHAT TO DO WHEN YOU SEE THEM"
        case 4: return "SHORT-TERM ELIMINATION"
        case 5: return "LONG-TERM ELIMINATION"
        case 6: return "PRO TIPS"
        case 7: return "COMMUNITY WISDOM"
        default: return "LOCKED CONTENT"
        }
    }
    
    private func unlockButton() -> some View {
        Button {
            showPaywall = true
        } label: {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Unlock Full Insect Details")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Text("Get complete information about this insect")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "#666666"))
            }
        }
        .buttonStyle(.plain)
    }

    private func dangerColor(_ level: String) -> Color {
        switch level.uppercased() {
        case "SAFE": return Color(hex: "#22C55E")
        case "MILD": return Color(hex: "#EAB308")
        case "DANGEROUS": return Color(hex: "#F97316")
        case "DEADLY": return Color(hex: "#EF4444")
        default: return .white
        }
    }
}
