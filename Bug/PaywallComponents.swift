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
    
    var body: some View {
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
    @State private var selectedProductType: ProductType = .oneTime
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    
    enum ProductType {
        case oneTime
        case subscription
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
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
            
            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "#EF4444"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            
            // Unlock button
            Button {
                Task { await purchase() }
            } label: {
                HStack {
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
                .frame(height: 54)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isPurchasing)
            .scaleEffect(isPurchasing ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPurchasing)
            
            // Restore purchases
            Button {
                Task { await restore() }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "#888888"))
                    .frame(maxWidth: .infinity)
            }
            .disabled(isPurchasing)
            
            // Fine print
            Text("Managed by App Store. Cancel anytime.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color(hex: "#444444"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
    
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
