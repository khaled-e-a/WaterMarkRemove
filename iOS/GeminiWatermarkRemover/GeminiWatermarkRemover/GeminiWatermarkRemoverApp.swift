import SwiftUI

@main
struct GeminiWatermarkRemoverApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var historyManager = HistoryManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(subscriptionManager)
                .environmentObject(historyManager)
                .preferredColorScheme(.dark) // Force dark mode for sleek look
        }
    }
}
