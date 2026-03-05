//
//  PurchaseManager.swift
//  Bug
//
//  Bug ID — StoreKit 2 purchase and subscription manager
//

import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro: Bool = false
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    private var updateListenerTask: Task<Void, Never>?
    
    private init() {
        print("[PurchaseManager] Initializing...")
        // Load cached state immediately
        isPro = UserDefaults.standard.bool(forKey: "isPro")
        print("[PurchaseManager] Cached isPro status: \(isPro)")
        
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Products
    
    func loadProducts() async {
        print("[PurchaseManager] Loading products for IDs: \(Configuration.productIDs)")
        do {
            let loadedProducts = try await Product.products(for: Configuration.productIDs)
            products = loadedProducts.sorted { $0.price < $1.price }
            print("[PurchaseManager] Successfully loaded \(products.count) products:")
            for product in products {
                print("  - \(product.displayName) (\(product.id)) - \(product.displayPrice)")
            }
        } catch {
            print("[PurchaseManager] Failed to load products: \(error)")
        }
    }
    
    var oneTimePurchaseProduct: Product? {
        let product = products.first { $0.id == Configuration.oneTimePurchaseProductID }
        if product == nil {
            print("[PurchaseManager] ⚠️ One-time purchase product not found for ID: \(Configuration.oneTimePurchaseProductID)")
        }
        return product
    }
    
    var subscriptionProduct: Product? {
        let product = products.first { $0.id == Configuration.subscriptionProductID }
        if product == nil {
            print("[PurchaseManager] ⚠️ Subscription product not found for ID: \(Configuration.subscriptionProductID)")
        }
        return product
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            
        case .userCancelled:
            break
            
        case .pending:
            break
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // MARK: - Manage Subscriptions
    
    func showManageSubscriptions(in windowScene: UIWindowScene?) async throws {
        // Opens the App Store's subscription management interface
        guard let scene = windowScene else {
            throw PurchaseError.noWindowScene
        }
        try await AppStore.showManageSubscriptions(in: scene)
    }
    
    // MARK: - Entitlements
    
    var hasActiveOneTimeUnlock: Bool {
        return purchasedProductIDs.contains(Configuration.oneTimePurchaseProductID)
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        // Check for all current entitlements
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else {
                continue
            }
            
            purchasedIDs.insert(transaction.productID)
        }
        
        self.purchasedProductIDs = purchasedIDs
        
        // Update pro status - ONLY subscription gives Pro mode
        let hasSubscription = purchasedIDs.contains(Configuration.subscriptionProductID)
        
        isPro = hasSubscription
        
        // Cache the status
        UserDefaults.standard.set(isPro, forKey: "isPro")
        
        print("[PurchaseManager] Updated entitlements - isPro: \(isPro), purchased: \(purchasedIDs)")
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { continue }
                guard let transaction = try? self.checkVerified(result) else {
                    continue
                }
                
                await self.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
    
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum PurchaseError: LocalizedError {
    case failedVerification
    case noWindowScene
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .noWindowScene:
            return "Unable to present subscription management"
        }
    }
}
