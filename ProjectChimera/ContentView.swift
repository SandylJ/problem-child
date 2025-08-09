import SwiftUI
import SwiftData

struct ContentView: View {
    // These properties will now be correctly populated from the environment
    // that was set up in ProjectChimeraApp.swift.
    @EnvironmentObject var gameManager: IdleGameManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var onboardingManager: OnboardingManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            // Show onboarding until the user completes it.
            if !onboardingManager.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainView()
            }
        }
        .onAppear {
            // HealthKit authorization requires a completion handler.
            healthKitManager.requestAuthorization { _ in }
            ensureUserExists()
        }
    }

    private func ensureUserExists() {
        // Ensure there is a persisted user so views relying on @Query(User) don't get stuck loading
        let descriptor = FetchDescriptor<User>()
        if let users = try? modelContext.fetch(descriptor), users.isEmpty {
            let defaultUser = User(username: "PlayerOne")
            modelContext.insert(defaultUser)
        }
    }
}
