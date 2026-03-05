//
//  PaywallComponents.swift
//  Bug
//
//  Bug ID — Premium paywall UI components
//

import SwiftUI
import StoreKit

// MARK: - Danger Badge

struct DangerBadge: View {
    let level: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(badgeColor)
                .frame(width: 6, height: 6)
            
            Text(level.uppercased())
                .font(.system(size: 10, weight: .bold, design: .default))
                .tracking(1)
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .strokeBorder(badgeColor, lineWidth: 1)
        )
    }
    
    private var badgeColor: Color {
        switch level.uppercased() {
        case "SAFE": return Color(hex: "#22C55E")
        case "MILD": return Color(hex: "#EAB308")
        case "DANGEROUS": return Color(hex: "#F97316")
        case "DEADLY": return Color(hex: "#EF4444")
        default: return Color(hex: "#888888")
        }
    }
}

// MARK: - Shadcn Style Row

struct ShadcnRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white
    var isTop: Bool = false
    var isBottom: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color(hex: "#666666"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - Premium Paragraph Card

struct PremiumParagraphCard: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color(hex: "#666666"))
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(hex: "#111111"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#222222"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Locked Content Card

struct LockedContentCard: View {
    let title: String
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack {
                // Blurred content preview
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .textCase(.uppercase)
                        .tracking(1)
                        .foregroundStyle(Color(hex: "#666666"))
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .blur(radius: 6)
                
                // Black overlay
                Color.black.opacity(0.65)
                
                // Lock icon and "Pro Only" label
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("PRO ONLY")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(hex: "#888888"))
                }
            }
            .background(Color(hex: "#111111"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#222222"), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(height: 120)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pro Badge (top right)

struct ProBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("WhatTheBug Pro")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
            
            Text("✦")
                .font(.system(size: 10))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black)
        .overlay(
            Capsule()
                .strokeBorder(.white, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

// MARK: - Paywall View

struct PaywallView: View {
    @ObservedObject var purchaseManager: PurchaseManager
    var currentBugResult: BugResult? = nil  // Pass the current bug for one-time unlocks
    @State private var selectedProductType: ProductType = .subscription
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    enum ProductType {
        case oneTime
        case subscription
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(white: 0.25))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Icon and headline
                        VStack(alignment: .leading, spacing: 16) {
                            // Sparkle icon
                            Image(systemName: "sparkles")
                                .font(.system(size: 48, weight: .regular))
                                .foregroundStyle(.white)
                            
                            // Headline
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Unlock")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                Text("Full Insect Details")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            
                            // Subtitle
                            Text("Get complete information about every insect")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color(white: 0.6))
                        }
                        .padding(.top, 8)
                        
                        // Features list
                        VStack(alignment: .leading, spacing: 24) {
                            FeatureRow(
                                icon: "infinity",
                                title: "Unlimited Scans",
                                subtitle: "Identify as many insects as you want"
                            )
                            
                            FeatureRow(
                                icon: "doc.text.fill",
                                title: "Complete Reports",
                                subtitle: "Access full details for every insect"
                            )
                            
                            FeatureRow(
                                icon: "shield.checkered",
                                title: "Safety Information",
                                subtitle: "Know what to do when you encounter them"
                            )
                        }
                        
                        // Subscription cards section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("UNLOCK FULL REPORT")
                                .font(.system(size: 11, weight: .semibold))
                                .tracking(1.2)
                                .textCase(.uppercase)
                                .foregroundStyle(Color(hex: "#888888"))
                            
                            // Two option cards
                            HStack(spacing: 12) {
                                // Card A - One-time purchase
                                if let product = purchaseManager.oneTimePurchaseProduct {
                                    PurchaseOptionCard(
                                        badge: "THIS BUG",
                                        price: product.displayPrice,
                                        label: "One scan",
                                        isSelected: selectedProductType == .oneTime
                                    ) {
                                        selectedProductType = .oneTime
                                    }
                                }
                                
                                // Card B - Subscription
                                if let product = purchaseManager.subscriptionProduct {
                                    PurchaseOptionCard(
                                        badge: "ALL BUGS",
                                        price: "\(product.displayPrice)/mo",
                                        label: "Unlimited",
                                        isSelected: selectedProductType == .subscription
                                    ) {
                                        selectedProductType = .subscription
                                    }
                                }
                            }
                        }
                        
                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // Loading state message (if no products)
                        if purchaseManager.products.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text("Loading subscription options...")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color(white: 0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        
                        // Bottom button area (inside scroll view)
                        VStack(spacing: 12) {
                            // Main unlock button
                            Button {
                                Task { await purchase() }
                            } label: {
                                HStack(spacing: 8) {
                                    if isPurchasing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Text("Unlock Now")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundStyle(.black)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isPurchasing || purchaseManager.products.isEmpty)
                            .opacity((isPurchasing || purchaseManager.products.isEmpty) ? 0.6 : 1.0)
                            
                            // Restore purchases
                            Button {
                                Task { await restore() }
                            } label: {
                                Text("Restore Purchases")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(white: 0.6))
                            }
                            .disabled(isPurchasing)
                            
                            // Fine print + Terms link
                            VStack(spacing: 8) {
                                Text("Managed by App Store. Cancel anytime.")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundStyle(Color(hex: "#444444"))
                                    .multilineTextAlignment(.center)
                                
                                if let url = URL(string: Configuration.termsOfUseURL) {
                                    Link("Terms of Use", destination: url)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color(white: 0.5))
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        
        let product: Product?
        switch selectedProductType {
        case .oneTime:
            product = purchaseManager.oneTimePurchaseProduct
        case .subscription:
            product = purchaseManager.subscriptionProduct
        }
        
        guard let product = product else {
            errorMessage = "Product not available"
            return
        }
        
        do {
            try await purchaseManager.purchase(product)
            
            // Handle based on purchase type and context
            if selectedProductType == .oneTime {
                if let bugResult = currentBugResult {
                    // Context: User is viewing a specific bug → Unlock THIS bug
                    OneTimeUnlockManager.shared.unlockInsect(bugResult.id)
                    print("[PaywallView] Unlocked specific insect: \(bugResult.commonName) (ID: \(bugResult.id))")
                } else {
                    // Context: User clicked from scan counter/profile → Add scan credit
                    OneTimeUnlockManager.shared.addScanCredit()
                    print("[PaywallView] Added 1 scan credit")
                }
                dismiss()
            } else if selectedProductType == .subscription {
                // Subscription unlocks everything
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func restore() async {
        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }
        
        await purchaseManager.restorePurchases()
    }
}

// MARK: - Purchase Option Card

struct PurchaseOptionCard: View {
    let badge: String
    let price: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Top-right badge
                HStack {
                    Spacer()
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .strokeBorder(badgeColor, lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Price
                Text(price)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                
                // Label
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "#888888"))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 120)
            .background(Color(hex: "#111111"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private var borderColor: Color {
        isSelected ? .white : Color(hex: "#222222")
    }
    
    private var badgeColor: Color {
        isSelected ? .white : Color(hex: "#666666")
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(.white)
                .frame(width: 28, alignment: .leading)
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(white: 0.6))
            }
        }
    }
}

// MARK: - Color Extension (Hex Support)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
