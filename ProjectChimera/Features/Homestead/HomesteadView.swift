import SwiftUI
import SwiftData

struct HomesteadView: View {
    @EnvironmentObject var gameState: ChimeraGameState
    @State private var homesteadManager: HomesteadManager?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Resource Totals Section
                    ResourceTotalsView(gameState: gameState)
                    
                    // Production Control
                    if let homesteadManager = homesteadManager {
                        ProductionControlView(homesteadManager: homesteadManager)
                        
                        // Buildings Section
                        BuildingsSectionView(homesteadManager: homesteadManager, gameState: gameState)
                    }
                }
                .padding()
            }
            .navigationTitle("Homestead")
            .onAppear {
                // Initialize homestead manager with the actual game state
                if homesteadManager == nil {
                    homesteadManager = HomesteadManager(gameState: gameState)
                }
                homesteadManager?.loadFromModelContext(modelContext)
                homesteadManager?.startProduction()
            }
            .onDisappear {
                homesteadManager?.stopProduction()
                homesteadManager?.saveToModelContext(modelContext)
            }
        }
    }
}

// MARK: - Resource Totals View
struct ResourceTotalsView: View {
    let gameState: ChimeraGameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resources")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ResourceKind.allCases, id: \.self) { resourceKind in
                    if let resource = gameState.getResource(by: resourceKind) {
                        ResourceCard(resource: resource)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(spacing: 4) {
            Text(resource.resourceKind.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("\(resource.quantity)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Production Control View
struct ProductionControlView: View {
    @ObservedObject var homesteadManager: HomesteadManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Production")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(homesteadManager.isProductionActive ? "Active" : "Inactive")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(homesteadManager.isProductionActive ? .green : .red)
                }
                
                Spacer()
                
                Button(action: {
                    if homesteadManager.isProductionActive {
                        homesteadManager.stopProduction()
                    } else {
                        homesteadManager.startProduction()
                    }
                }) {
                    Text(homesteadManager.isProductionActive ? "Stop" : "Start")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(homesteadManager.isProductionActive ? Color.red : Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Buildings Section View
struct BuildingsSectionView: View {
    @ObservedObject var homesteadManager: HomesteadManager
    let gameState: ChimeraGameState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Buildings")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(homesteadManager.buildings, id: \.id) { building in
                    BuildingCard(
                        building: building,
                        homesteadManager: homesteadManager,
                        gameState: gameState
                    )
                }
            }
        }
    }
}

struct BuildingCard: View {
    let building: Building
    @ObservedObject var homesteadManager: HomesteadManager
    let gameState: ChimeraGameState
    
    private var canUpgrade: Bool {
        homesteadManager.canUpgradeBuilding(building)
    }
    
    private var upgradeCost: Int {
        building.getUpgradeCost()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Building Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(building.buildingType.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Level \(building.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Building Icon
                Image(systemName: buildingIcon)
                    .font(.title2)
                    .foregroundColor(buildingColor)
            }
            
            // Production Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Production")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(building.getProductionPerMinute())/min")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            // Upgrade Button
            Button(action: {
                if homesteadManager.upgradeBuilding(building) {
                    // Success feedback could be added here
                }
            }) {
                HStack {
                    Text("Upgrade")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(upgradeCost)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(canUpgrade ? .white : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(canUpgrade ? Color.blue : Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
            .disabled(!canUpgrade)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var buildingIcon: String {
        switch building.buildingType {
        case .farm: return "leaf.fill"
        case .workshop: return "hammer.fill"
        case .study: return "book.fill"
        }
    }
    
    private var buildingColor: Color {
        switch building.buildingType {
        case .farm: return .green
        case .workshop: return .orange
        case .study: return .blue
        }
    }
}

#Preview {
    HomesteadView()
        .environmentObject(ChimeraGameState())
        .modelContainer(for: [Building.self], inMemory: true)
}
