import Foundation
import StoreKit
import Combine

@MainActor
class SubscriptionManager: ObservableObject {

    @Published var isSubscribed: Bool = false
    @Published var canRemoveWatermark: Bool = true
    @Published var dailyLimitReached: Bool = false

    private let productId = "com.gemini.remover.monthly"
    private let lastRemovalDateKey = "LastRemovalDate"

    init() {
        Task {
            await updateSubscriptionStatus()
            checkDailyLimit()
        }
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
        guard let product = try await Product.products(for: [productId]).first else {
            return
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            await updateSubscriptionStatus()

            // Always finish a transaction.
            await transaction.finish()

        case .userCancelled, .pending:
            break
        default:
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
