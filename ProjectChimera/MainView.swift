import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager

    var body: some View {
        Group {
            if onboardingManager.hasCompletedOnboarding {
                AppTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            // If onboarding is completed but no user exists, create one
            if onboardingManager.hasCompletedOnboarding {
                // This will be handled in AppTabView.onAppear
            } else {
                // Force complete onboarding if there are issues
                print("Onboarding not completed, forcing completion...")
                onboardingManager.completeOnboarding()
            }
        }
    }
}

struct AppTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var gameState: ChimeraGameState
    @State private var showingSettings = false
    @State private var showingDeveloperMenu = false
    
    var body: some View {
        TabView {
            // Main Game Tabs
            NavigationView {
                TaskListView(user: User(username: "Player"), didLevelUp: .constant(false), didEvolve: .constant(false))
            }
            .tabItem {
                Label("Tasks", systemImage: "checklist")
            }
            
            NavigationView {
                SkillWebView()
            }
            .tabItem {
                Label("Skills", systemImage: "network")
            }
            
            NavigationView {
                HomesteadView()
            }
            .tabItem {
                Label("Homestead", systemImage: "house.fill")
            }
            
            NavigationView {
                ExpeditionsView()
            }
            .tabItem {
                Label("Expeditions", systemImage: "map.fill")
            }
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .onAppear {
            // Ensure seed data is set up
            if gameState.player == nil {
                gameState.setupSeedData()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingDeveloperMenu) {
            DeveloperCommands()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Settings") {
                        showingSettings = true
                    }
                    Button("Developer") {
                        showingDeveloperMenu = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [User.self, Task.self], inMemory: true)
}
