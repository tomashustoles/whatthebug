//
//  PremiumContentComponents.swift
//  Bug
//
//  Bug ID — Premium UI components for enhanced bug analysis results
//

import SwiftUI

// MARK: - Geographic Distribution Card

struct GeographicDistributionCard: View {
    let countries: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("COMMON LOCATIONS")
                .font(.system(size: 13, weight: .heavy, design: .default))
                .foregroundStyle(Color(hex: "#666666"))
                .tracking(1.2)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(countries, id: \.self) { country in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(hex: "#666666"))
                            .frame(width: 6, height: 6)
                        
                        Text(country)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Encounter Response Card

struct EncounterResponseCard: View {
    let singleEncounter: String
    let fewEncounters: String
    let manyEncounters: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("WHAT TO DO WHEN YOU SEE THEM")
                .font(.system(size: 13, weight: .heavy, design: .default))
                .foregroundStyle(Color(hex: "#666666"))
                .tracking(1.2)
                .padding(20)
                .padding(.bottom, 4)
            
            // One
            encounterSection(
                title: "IF YOU SEE ONE",
                text: singleEncounter,
                isFirst: true
            )
            
            Divider()
                .background(Color(hex: "#1F1F1F"))
            
            // Few (2-5)
            encounterSection(
                title: "IF YOU SEE A FEW (2-5)",
                text: fewEncounters
            )
            
            Divider()
                .background(Color(hex: "#1F1F1F"))
            
            // Many (infestation)
            encounterSection(
                title: "IF YOU SEE MANY (INFESTATION)",
                text: manyEncounters,
                isLast: true
            )
        }
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func encounterSection(
        title: String,
        text: String,
        isFirst: Bool = false,
        isLast: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "#666666"))
                .tracking(1.0)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .padding(.top, isFirst ? -4 : 0)
    }
}

// MARK: - Elimination Strategy Card

struct EliminationStrategyCard: View {
    let title: String
    let text: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .default))
                .foregroundStyle(Color(hex: "#666666"))
                .tracking(1.2)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Expert Tips Card

struct ExpertTipsCard: View {
    let title: String
    let text: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .default))
                .foregroundStyle(Color(hex: "#666666"))
                .tracking(1.2)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Enhanced Overview Card (with seasonal activity)

struct PremiumOverviewCard: View {
    let habitat: String
    let lifeStage: String
    let seasonalActivity: String
    
    var body: some View {
        VStack(spacing: 0) {
            // HABITAT
            ShadcnRow(
                label: "HABITAT",
                value: habitat,
                isTop: true
            )
            
            Divider()
                .background(Color(hex: "#1F1F1F"))
            
            // LIFE STAGE
            ShadcnRow(
                label: "LIFE STAGE",
                value: lifeStage
            )
            
            Divider()
                .background(Color(hex: "#1F1F1F"))
            
            // SEASONAL ACTIVITY
            ShadcnRow(
                label: "ACTIVITY",
                value: seasonalActivity,
                isBottom: true
            )
        }
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview Helpers

#Preview("Geographic Distribution") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        GeographicDistributionCard(
            countries: [
                "United States",
                "Canada",
                "Mexico",
                "Western Europe",
                "Australia"
            ]
        )
        .padding()
    }
}

#Preview("Encounter Response") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ScrollView {
            EncounterResponseCard(
                singleEncounter: "Observe from a safe distance. Most species are harmless and beneficial. If indoors, gently relocate outside using a cup and paper.",
                fewEncounters: "Inspect the area for nests or entry points. Check window screens and door seals. Monitor the situation for 24-48 hours.",
                manyEncounters: "This indicates an active infestation. Contact a pest control professional immediately. Do not disturb nests. Seal food sources and remove standing water."
            )
            .padding()
        }
    }
}

#Preview("Elimination Strategy") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 12) {
            EliminationStrategyCard(
                title: "SHORT-TERM (24-48 HOURS)",
                text: "Apply diatomaceous earth around entry points. Use sticky traps in problem areas. Deploy pheromone attractants. Vacuum thoroughly and dispose of bag immediately.",
                icon: "⚡",
                accentColor: Color(hex: "#F59E0B")
            )
            
            EliminationStrategyCard(
                title: "LONG-TERM (PERMANENT SOLUTION)",
                text: "Seal all cracks and crevices with caulk. Install door sweeps and weatherstripping. Remove clutter and debris around foundation. Maintain proper drainage to eliminate moisture.",
                icon: "🎯",
                accentColor: Color(hex: "#22C55E")
            )
        }
        .padding()
    }
}

#Preview("Expert Tips") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 12) {
            ExpertTipsCard(
                title: "PRO TIPS",
                text: "Professionals look for frass (insect droppings) as the primary sign of activity. Use a UV flashlight at night to spot them more easily. Most active 2-3 hours after sunset.",
                icon: "💡",
                accentColor: Color(hex: "#8B5CF6")
            )
            
            ExpertTipsCard(
                title: "COMMUNITY WISDOM",
                text: "Reddit users report success with mint oil spray (10 drops per cup water). Keep a 'bug log' with photos to track population changes. Many homeowners find prevention is 10x easier than elimination.",
                icon: "💬",
                accentColor: Color(hex: "#EC4899")
            )
        }
        .padding()
    }
}
