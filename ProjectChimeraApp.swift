import SwiftUI

@main
struct ProjectChimeraApp: App {
    // CORRECTED: Create a separate @StateObject for each manager.
    // This ensures each manager's lifecycle is correctly managed by SwiftUI
    // and resolves the access level issues by initializing them here.
    @StateObject private var gameManager = IdleGameManager()
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var equipmentManager = EquipmentManager()
    @StateObject private var sanctuaryManager = SanctuaryManager()
    @StateObject private var guildManager = GuildManager()
    @StateObject private var shopManager = ShopManager()

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
