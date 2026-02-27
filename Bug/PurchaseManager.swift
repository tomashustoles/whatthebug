//
//  PurchaseManager.swift
//  Bug
//
//  Bug ID — StoreKit 2 purchase and subscription manager
//

import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro: Bool = false
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    private var updateListenerTask: Task<Void, Never>?
    
    private init() {
        // Load cached state immediately
        isPro = UserDefaults.standard.bool(forKey: "isPro")
        
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
        do {
            let loadedProducts = try await Product.products(for: Configuration.productIDs)
            products = loadedProducts.sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    var oneTimePurchaseProduct: Product? {
        products.first { $0.id == Configuration.oneTimePurchaseProductID }
    }
    
    var subscriptionProduct: Product? {
        products.first { $0.id == Configuration.subscriptionProductID }
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
    
    // MARK: - Entitlements
    
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
        
        // Update pro status
        let hasOneTimePurchase = purchasedIDs.contains(Configuration.oneTimePurchaseProductID)
        let hasSubscription = purchasedIDs.contains(Configuration.subscriptionProductID)
        
        isPro = hasOneTimePurchase || hasSubscription
        
        // Cache the status
        UserDefaults.standard.set(isPro, forKey: "isPro")
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let transaction = try? self?.checkVerified(result) else {
                    continue
                }
                
                await self?.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
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
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        }
    }
}
