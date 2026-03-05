//
//  ProfileView.swift
//  Bug
//
//  Bug ID — Profile with Subscription section and app info
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    @Bindable var insectStore: InsectStore
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var unlockManager = OneTimeUnlockManager.shared
    @State private var scanLimitManager = ScanLimitManager.shared
    @State private var showingPaywall = false
    @Environment(\.openURL) private var openURL
    
    // Helper to get the current window scene
    private var windowScene: UIWindowScene? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return scene
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Subscription section
                VStack(alignment: .leading, spacing: 16) {
                    Text("SUBSCRIPTION")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    subscriptionCard
                }
                
                // Daily Scans section (only for non-Pro users)
                if !purchaseManager.isPro {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DAILY SCANS")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        dailyScansCard
                    }
                }
                
                // App Info section
                VStack(alignment: .leading, spacing: 16) {
                    Text("APP INFO")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                    
                    appInfoCard
                }
            }
            .padding(24)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(Color.black)
        .sheet(isPresented: $showingPaywall) {
            // Paywall view for non-Pro users
            PaywallView(purchaseManager: purchaseManager)
        }
    }
    
    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(purchaseManager.isPro ? "Active" : "Premium")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(purchaseManager.isPro ? "Your subscription is active" : "Unlock unlimited identifications")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Button {
                print("[ProfileView] Button tapped - isPro: \(purchaseManager.isPro)")
                if purchaseManager.isPro {
                    print("[ProfileView] Opening subscription management...")
                    // Open subscription management in App Store
                    Task {
                        do {
                            if let windowScene = windowScene {
                                try await AppStore.showManageSubscriptions(in: windowScene)
                                print("[ProfileView] Successfully opened subscription management")
                            } else {
                                print("[ProfileView] No window scene, using fallback URL")
                                // Fallback if no window scene available
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    openURL(url)
                                }
                            }
                        } catch {
                            print("[ProfileView] Error opening subscription management: \(error)")
                            // Fallback to opening subscription management URL
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                openURL(url)
                            }
                        }
                    }
                } else {
                    print("[ProfileView] Opening paywall sheet...")
                    // Show paywall for non-Pro users
                    showingPaywall = true
                    print("[ProfileView] showingPaywall set to true")
                }
            } label: {
                Text(purchaseManager.isPro ? "Manage" : "Subscribe")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(purchaseManager.isPro ? Color(white: 0.25) : Color.accentColor)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.12))
        }
    }
    
    private var dailyScansCard: some View {
        Button {
            showingPaywall = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Scans")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("\(scanLimitManager.dailyScansUsed)/\(scanLimitManager.maxDailyScans) used today")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    
                    // Show scan credits if available
                    if unlockManager.availableScanCredits > 0 {
                        Text("+\(unlockManager.availableScanCredits) purchased \(unlockManager.availableScanCredits == 1 ? "credit" : "credits")")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                
                Spacer()
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(Color(white: 0.25), lineWidth: 3)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(scanLimitManager.dailyScansUsed) / CGFloat(scanLimitManager.maxDailyScans))
                        .stroke(
                            scanLimitManager.hasScansRemaining ? Color.accentColor : Color.red,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(scanLimitManager.scansRemaining)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.12))
            }
        }
        .buttonStyle(.plain)
    }
    
    private var appInfoCard: some View {
        VStack(spacing: 0) {
            // Terms of Use
            Link(destination: URL(string: Configuration.termsOfUseURL)!) {
                HStack {
                    Label("Terms of Use", systemImage: "doc.text.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(Color(white: 0.12))
            }
            
            Divider()
                .background(Color(white: 0.08))
            
            // Privacy Policy
            Link(destination: URL(string: "https://tomashustoles.github.io/whatthebug/privacy-policy.html")!) {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(Color(white: 0.12))
            }
            
            Divider()
                .background(Color(white: 0.08))
            
            // Support
            Link(destination: URL(string: "https://tomashustoles.github.io/whatthebug/support.html")!) {
                HStack {
                    Label("Support", systemImage: "questionmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                }
                .padding(16)
                .background(Color(white: 0.12))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.08), lineWidth: 1)
        )
    }
}

