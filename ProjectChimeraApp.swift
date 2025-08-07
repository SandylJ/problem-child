import SwiftUI

@main
struct ProjectChimeraApp: App {
    // Each manager is initialized using its shared singleton instance. This
    // avoids access level issues from private initializers while still allowing
    // SwiftUI to manage their lifecycle via `@StateObject`.
    @StateObject private var gameManager = IdleGameManager.shared
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var equipmentManager = EquipmentManager.shared
    @StateObject private var sanctuaryManager = SanctuaryManager.shared
    @StateObject private var guildManager = GuildManager.shared
    @StateObject private var shopManager = ShopManager.shared

    var body: some Scene {
        WindowGroup {
            // CORRECTED: Inject each manager individually into the environment.
            // This is the standard SwiftUI pattern for providing dependencies to child views.
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(healthKitManager)
                .environmentObject(onboardingManager)
                .environmentObject(equipmentManager)
                .environmentObject(sanctuaryManager)
                .environmentObject(guildManager)
                .environmentObject(shopManager)
        }
    }
}
