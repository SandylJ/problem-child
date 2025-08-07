import SwiftUI
import SwiftData

struct ContentView: View {
    // These properties will now be correctly populated from the environment
    // that was set up in ProjectChimeraApp.swift.
    @EnvironmentObject var gameManager: IdleGameManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var onboardingManager: OnboardingManager

    @Query(filter: #Predicate<UserTask> { task in
        task.difficulty == TaskDifficulty.easy &&
            task.associatedStat == ChimeraStat.intellect
    }) var tasks: [UserTask]

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
        }
    }
}
