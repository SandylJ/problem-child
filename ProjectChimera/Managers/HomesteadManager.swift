import Foundation
import SwiftUI
import SwiftData

// MARK: - Building Types
enum BuildingType: String, CaseIterable, Codable {
    case farm = "Farm"
    case workshop = "Workshop"
    case study = "Study"
    
    var resourceType: ResourceKind {
        switch self {
        case .farm: return .rations
        case .workshop: return .tools
        case .study: return .intel
        }
    }
    
    var baseProductionPerMinute: Int {
        switch self {
        case .farm: return 2
        case .workshop: return 1
        case .study: return 1
        }
    }
    
    var upgradeCost: Int {
        switch self {
        case .farm: return 10
        case .workshop: return 15
        case .study: return 20
        }
    }
}

// MARK: - Building Model
@Model
final class Building {
    var id: UUID
    var type: String // Store as string for SwiftData compatibility
    var level: Int
    var lastProductionTime: Date
    
    init(type: BuildingType) {
        self.id = UUID()
        self.type = type.rawValue
        self.level = 1
        self.lastProductionTime = Date()
    }
    
    var buildingType: BuildingType {
        get { BuildingType(rawValue: type) ?? .farm }
        set { type = newValue.rawValue }
    }
    
    func tickProduction(perMinute: Int) -> Int {
        let now = Date()
        let timeSinceLastProduction = now.timeIntervalSince(lastProductionTime)
        let minutesSinceLastProduction = timeSinceLastProduction / 60.0
        
        let productionAmount = Int(Double(perMinute) * minutesSinceLastProduction)
        
        if productionAmount > 0 {
            lastProductionTime = now
        }
        
        return productionAmount
    }
    
    func getProductionPerMinute() -> Int {
        return buildingType.baseProductionPerMinute * level
    }
    
    func getUpgradeCost() -> Int {
        return buildingType.upgradeCost * level
    }
}

// MARK: - Homestead Manager
@MainActor
class HomesteadManager: ObservableObject {
    @Published var buildings: [Building] = []
    @Published var isProductionActive = false
    
    private var productionTimer: Timer?
    private let gameState: ChimeraGameState
    
    init(gameState: ChimeraGameState) {
        self.gameState = gameState
        setupBuildings()
    }
    
    deinit {
        productionTimer?.invalidate()
    }
    
    // MARK: - Building Setup
    private func setupBuildings() {
        if buildings.isEmpty {
            for buildingType in BuildingType.allCases {
                let building = Building(type: buildingType)
                buildings.append(building)
            }
        }
    }
    
    // MARK: - Production System
    func startProduction() {
        guard !isProductionActive else { return }
        
        isProductionActive = true
        productionTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.tickProduction()
            }
        }
    }
    
    func stopProduction() {
        isProductionActive = false
        productionTimer?.invalidate()
        productionTimer = nil
    }
    
    private func tickProduction() {
        for building in buildings {
            let productionAmount = building.tickProduction(perMinute: building.getProductionPerMinute())
            if productionAmount > 0 {
                gameState.addResource(kind: building.buildingType.resourceType, amount: productionAmount)
            }
        }
    }
    
    // MARK: - Upgrade System
    func canUpgradeBuilding(_ building: Building) -> Bool {
        let cost = building.getUpgradeCost()
        if let resource = gameState.getResource(by: building.buildingType.resourceType) {
            return resource.quantity >= cost
        }
        return false
    }
    
    func upgradeBuilding(_ building: Building) -> Bool {
        guard canUpgradeBuilding(building) else { return false }
        
        let cost = building.getUpgradeCost()
        if let resource = gameState.getResource(by: building.buildingType.resourceType) {
            if resource.remove(cost) {
                building.level += 1
                return true
            }
        }
        return false
    }
    
    // MARK: - Data Persistence
    func saveToModelContext(_ context: ModelContext) {
        for building in buildings {
            context.insert(building)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save buildings: \(error)")
        }
    }
    
    func loadFromModelContext(_ context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Building>()
            let loadedBuildings = try context.fetch(descriptor)
            
            if loadedBuildings.isEmpty {
                setupBuildings()
            } else {
                buildings = loadedBuildings
            }
        } catch {
            print("Failed to load buildings: \(error)")
            setupBuildings()
        }
    }
    
    // MARK: - Utility Functions
    func getBuilding(by type: BuildingType) -> Building? {
        return buildings.first { $0.buildingType == type }
    }
    
    func getTotalProductionPerMinute(for resourceType: ResourceKind) -> Int {
        return buildings
            .filter { $0.buildingType.resourceType == resourceType }
            .reduce(0) { $0 + $1.getProductionPerMinute() }
    }
}
