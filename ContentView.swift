import SwiftUI

struct ContentView: View {
    // These properties will now be correctly populated from the environment
    // that was set up in ProjectChimeraApp.swift.
    @EnvironmentObject var gameManager: IdleGameManager
    @EnvironmentObject var healthKitManager: HealthKitManager
    @EnvironmentObject var onboardingManager: OnboardingManager

    var body: some View {
        Group {
            // The view correctly checks the onboarding status.
            if onboardingManager.showOnboarding {
                // OnboardingView will automatically receive the onboardingManager
                // from the environment. No need to inject it again.
                OnboardingView()
            } else {
                // MainView and its children will also receive all the managers
                // from the environment.
                MainView()
            }
        }
        .onAppear {
            // You can safely call managers here.
            healthKitManager.requestAuthorization()
        }
    }
}
