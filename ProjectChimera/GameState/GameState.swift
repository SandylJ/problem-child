import Foundation
import SwiftUI
import SwiftData

// MARK: - XP Calculation Functions
func xpFor(task: Task) -> Int {
    switch task.difficulty {
    case .trivial: return 10
    case .easy: return 20
    case .medium: return 35
    case .hard: return 60
    case .epic: return 100
    }
}

func skillFromTaskType(_ stat: ChimeraStat) -> SkillName {
    switch stat {
    case .discipline: return .strength
    case .mindfulness: return .mind
    case .intellect: return .awareness
    case .creativity: return .joy
    case .resilience: return .vitality
    }
}

@MainActor
class ChimeraGameState: ObservableObject {
    // MARK: - Published Properties
    @Published var player: Player?
    @Published var skills: [Skill] = []
    @Published var resources: [Resource] = []
    @Published var taskRecords: [TaskRecord] = []
    
    // MARK: - Managers
    @Published var perkManager: PerkManager!
    @Published var toastCenter: ToastCenter!
    
    // MARK: - In-Memory Caches
    private var skillCache: [UUID: Skill] = [:]
    private var resourceCache: [UUID: Resource] = [:]
    
    // MARK: - Initialization
    init() {
        perkManager = PerkManager(gameState: self)
        toastCenter = ToastCenter()
        // Don't auto-setup seed data for testing
    }
    
    // MARK: - Seed Data Initializer
    func setupSeedData() {
        // Create default player if none exists
        if player == nil {
            player = Player(name: "Chimera Player")
        }
        
        // Create default skills if none exist
        if skills.isEmpty {
            skills = SkillName.allCases.map { Skill(name: $0) }
            updateSkillCache()
        }
        
        // Create default resources if none exist
        if resources.isEmpty {
            resources = [
                Resource(kind: .rations, quantity: 10),
                Resource(kind: .tools, quantity: 5),
                Resource(kind: .intel, quantity: 0),
                Resource(kind: .materials, quantity: 0),
                Resource(kind: .currency, quantity: 100),
                Resource(kind: .essence, quantity: 0)
            ]
            updateResourceCache()
        }
    }
    
    // MARK: - Reset for Testing
    func resetForTesting() {
        player = nil
        skills.removeAll()
        resources.removeAll()
        taskRecords.removeAll()
        skillCache.removeAll()
        resourceCache.removeAll()
    }
    
    // MARK: - Cache Management
    private func updateSkillCache() {
        skillCache.removeAll()
        for skill in skills {
            skillCache[skill.id] = skill
        }
    }
    
    private func updateResourceCache() {
        resourceCache.removeAll()
        for resource in resources {
            resourceCache[resource.id] = resource
        }
    }
    
    // MARK: - Convenience Functions
    func awardXP(skill: SkillName, amount: Int) {
        let skillModel: Skill
        let previousLevel: Int
        
        if let existingSkill = skills.first(where: { $0.skillName == skill }) {
            skillModel = existingSkill
            previousLevel = existingSkill.level
        } else {
            // Create skill if it doesn't exist
            let newSkill = Skill(name: skill)
            skills.append(newSkill)
            skillCache[newSkill.id] = newSkill
            skillModel = newSkill
            previousLevel = 1
        }
        
        skillModel.addXP(amount)
        
        // Check for perk unlocks if skill leveled up
        if skillModel.level > previousLevel {
            perkManager.checkForNewPerks(skill: skillModel)
            
            // Show level up toast
            toastCenter.showLevelUp(skill: skill, newLevel: skillModel.level)
        } else {
            // Show XP gain toast
            toastCenter.showXPGain(skill: skill, amount: amount, level: skillModel.level)
        }
        
        // Create task record
        let taskRecord = TaskRecord(
            skill: skillModel,
            amountXP: amount,
            difficulty: "Easy" // Default difficulty
        )
        taskRecords.append(taskRecord)
    }
    
    func addResource(kind: ResourceKind, amount: Int) {
        guard let resource = resources.first(where: { $0.resourceKind == kind }) else {
            // Create resource if it doesn't exist
            let newResource = Resource(kind: kind, quantity: amount)
            resources.append(newResource)
            resourceCache[newResource.id] = newResource
            return
        }
        
        resource.add(amount)
    }
    
    // MARK: - Utility Functions
    func getSkill(by name: SkillName) -> Skill? {
        return skills.first { $0.skillName == name }
    }
    
    func getResource(by kind: ResourceKind) -> Resource? {
        return resources.first { $0.resourceKind == kind }
    }
    
    func getTotalXP() -> Int {
        return skills.reduce(0) { $0 + $1.xp }
    }
    
    func getTotalLevel() -> Int {
        return skills.reduce(0) { $0 + $1.level }
    }
    
    // MARK: - Data Persistence Helpers
    func saveToModelContext(_ context: ModelContext) {
        // Save player
        if let player = player {
            context.insert(player)
        }
        
        // Save skills
        for skill in skills {
            context.insert(skill)
        }
        
        // Save resources
        for resource in resources {
            context.insert(resource)
        }
        
        // Save task records
        for record in taskRecords {
            context.insert(record)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save game state: \(error)")
        }
    }
    
    func loadFromModelContext(_ context: ModelContext) {
        // Load player
        let playerDescriptor = FetchDescriptor<Player>()
        if let players = try? context.fetch(playerDescriptor), let firstPlayer = players.first {
            player = firstPlayer
        }
        
        // Load skills
        let skillDescriptor = FetchDescriptor<Skill>()
        if let fetchedSkills = try? context.fetch(skillDescriptor) {
            skills = fetchedSkills
            updateSkillCache()
        }
        
        // Load resources
        let resourceDescriptor = FetchDescriptor<Resource>()
        if let fetchedResources = try? context.fetch(resourceDescriptor) {
            resources = fetchedResources
            updateResourceCache()
        }
        
        // Load task records
        let recordDescriptor = FetchDescriptor<TaskRecord>()
        if let fetchedRecords = try? context.fetch(recordDescriptor) {
            taskRecords = fetchedRecords
        }
    }
}
