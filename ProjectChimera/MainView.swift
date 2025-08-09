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
            // No-op: let user complete onboarding naturally
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
                RootUserTaskList()
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

struct RootUserTaskList: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    var body: some View {
        if let user = users.first {
            TaskListView(user: user, didLevelUp: .constant(false), didEvolve: .constant(false))
        } else {
            // Create a default user synchronously on first load
            let newUser = User(username: "PlayerOne")
            modelContext.insert(newUser)
            TaskListView(user: newUser, didLevelUp: .constant(false), didEvolve: .constant(false))
        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: [User.self, Task.self], inMemory: true)
}
