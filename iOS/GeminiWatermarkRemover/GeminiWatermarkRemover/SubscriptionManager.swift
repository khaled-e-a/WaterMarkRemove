import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {

    @Published var isSubscribed: Bool = false
    @Published var canRemoveWatermark: Bool = true
    @Published var dailyLimitReached: Bool = false

    private let productId = "elm.GeminiWatermarkRemover.subscription.monthly"
    private let lastRemovalDateKey = "LastRemovalDate"

    private var updates: Task<Void, Never>? = nil

    init() {
        // Listen for transaction updates (renewals, external purchases)
        updates = Task {
            for await verification in Transaction.updates {
                do {
                    let transaction = try checkVerified(verification)
                    await updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed")
                }
            }
        }

        Task {
            await updateSubscriptionStatus()
            checkDailyLimit()
        }
    }

    deinit {
        updates?.cancel()
    }

    func checkDailyLimit() {
        if isSubscribed {
            canRemoveWatermark = true
            dailyLimitReached = false
            return
        }

        let lastDate = UserDefaults.standard.object(forKey: lastRemovalDateKey) as? Date

        if let lastDate = lastDate {
            if Calendar.current.isDateInToday(lastDate) {
                // Already used today
                dailyLimitReached = true
                canRemoveWatermark = false
            } else {
                // New day
                dailyLimitReached = false
                canRemoveWatermark = true
            }
        } else {
            // Never used
            dailyLimitReached = false
            canRemoveWatermark = true
        }
    }

    func incrementDailyUsage() {
        UserDefaults.standard.set(Date(), forKey: lastRemovalDateKey)
        checkDailyLimit()
    }

    func purchase() async throws {
        print("DEBUG: Starting purchase process for \(productId)")

        let products = try await Product.products(for: [productId])
        print("DEBUG: Fetched \(products.count) products")

        guard let product = products.first else {
            print("DEBUG: Product not found during fetch")
            return
        }

        print("DEBUG: Found product: \(product.displayName), Price: \(product.displayPrice)")
        print("DEBUG: Requesting purchase...")

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            print("DEBUG: Purchase successful. Verifying transaction...")
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            print("DEBUG: Transaction verified. Updating status.")
            await updateSubscriptionStatus()

            // Always finish a transaction.
            await transaction.finish()

        case .userCancelled:
            print("DEBUG: User cancelled purchase")
            break
        case .pending:
            print("DEBUG: Purchase pending")
            break
        @unknown default:
             print("DEBUG: Unknown purchase result")
            break
        }
    }

    func updateSubscriptionStatus() async {
        var purchased = false

        // Iterate through the user's current entitlements
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // Check the product type
                if transaction.productType == .autoRenewable || transaction.productType == .nonConsumable {
                    if transaction.productID == productId {
                        purchased = true
                    }
                }
            } catch {
                // Handle error
            }
        }

        self.isSubscribed = purchased
        checkDailyLimit() // Re-check limit based on new subscription status
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
