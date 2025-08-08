import Foundation
import SwiftUI

// MARK: - Perk Types
enum PerkType: String, CaseIterable, Codable {
    case expeditionSuccessRate = "Expedition Success Rate"
    case studyProduction = "Study Production"
    case dailyFocusSlots = "Daily Focus Slots"
    case resourceGathering = "Resource Gathering"
    case skillXpBonus = "Skill XP Bonus"
    case buildingEfficiency = "Building Efficiency"
    case homesteadCapacity = "Homestead Capacity"
    
    var description: String {
        switch self {
        case .expeditionSuccessRate:
            return "Increases the success rate of expeditions"
        case .studyProduction:
            return "Increases production from Study buildings"
        case .dailyFocusSlots:
            return "Increases the number of daily focus slots"
        case .resourceGathering:
            return "Increases resource gathering from all sources"
        case .skillXpBonus:
            return "Increases XP gained from all activities"
        case .buildingEfficiency:
            return "Increases production efficiency of all buildings"
        case .homesteadCapacity:
            return "Increases homestead storage capacity"
        }
    }
    
    var icon: String {
        switch self {
        case .expeditionSuccessRate: return "map.fill"
        case .studyProduction: return "book.fill"
        case .dailyFocusSlots: return "brain.head.profile"
        case .resourceGathering: return "leaf.fill"
        case .skillXpBonus: return "star.fill"
        case .buildingEfficiency: return "building.2.fill"
        case .homesteadCapacity: return "house.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .expeditionSuccessRate: return .blue
        case .studyProduction: return .purple
        case .dailyFocusSlots: return .orange
        case .resourceGathering: return .green
        case .skillXpBonus: return .yellow
        case .buildingEfficiency: return .gray
        case .homesteadCapacity: return .brown
        }
    }
}

// MARK: - Perk Model
final class Perk {
    var id: UUID
    var type: String // Store as string for SwiftData compatibility
    var value: Double
    var isActive: Bool
    var unlockedAt: Date?
    
    init(type: PerkType, value: Double) {
        self.id = UUID()
        self.type = type.rawValue
        self.value = value
        self.isActive = false
        self.unlockedAt = nil
    }
    
    var perkType: PerkType {
        get { PerkType(rawValue: type) ?? .expeditionSuccessRate }
        set { type = newValue.rawValue }
    }
    
    func activate() {
        self.isActive = true
        self.unlockedAt = Date()
    }
    
    func apply(gameState: ChimeraGameState) {
        // Apply the perk effect to the game state
        switch perkType {
        case .expeditionSuccessRate:
            // This would be applied when calculating expedition success
            break
        case .studyProduction:
            // This would be applied when calculating study building production
            break
        case .dailyFocusSlots:
            // This would be applied when calculating available focus slots
            break
        case .resourceGathering:
            // This would be applied when calculating resource gains
            break
        case .skillXpBonus:
            // This would be applied when calculating XP gains
            break
        case .buildingEfficiency:
            // This would be applied when calculating building production
            break
        case .homesteadCapacity:
            // This would be applied when calculating storage limits
            break
        }
    }
}

// MARK: - Perk Manager
@MainActor
class PerkManager: ObservableObject {
    @Published var activePerks: [Perk] = []
    @Published var showingPerkUnlock = false
    @Published var unlockedPerk: Perk?
    
    private let gameState: ChimeraGameState
    
    init(gameState: ChimeraGameState) {
        self.gameState = gameState
    }
    
    // MARK: - Skill Level Perk Mapping
    func checkForNewPerks(skill: Skill) {
        let newPerks = getPerksForSkillLevel(skill: skill)
        
        for perk in newPerks {
            // Check if we already have this perk type for this skill level
            let existingPerk = activePerks.first { $0.perkType == perk.perkType }
            if existingPerk == nil {
                unlockPerk(perk)
            }
        }
    }
    
    private func getPerksForSkillLevel(skill: Skill) -> [Perk] {
        var perks: [Perk] = []
        
        switch skill.skillName {
        case .strength:
            if skill.level >= 5 {
                perks.append(Perk(type: .expeditionSuccessRate, value: 0.05)) // +5%
            }
            if skill.level >= 10 {
                perks.append(Perk(type: .resourceGathering, value: 0.10)) // +10%
            }
        case .mind:
            if skill.level >= 5 {
                perks.append(Perk(type: .studyProduction, value: 0.10)) // +10%
            }
            if skill.level >= 10 {
                perks.append(Perk(type: .skillXpBonus, value: 0.15)) // +15%
            }
        case .joy:
            if skill.level >= 3 {
                perks.append(Perk(type: .dailyFocusSlots, value: 1.0)) // +1 slot
            }
            if skill.level >= 8 {
                perks.append(Perk(type: .buildingEfficiency, value: 0.20)) // +20%
            }
        case .vitality:
            if skill.level >= 5 {
                perks.append(Perk(type: .homesteadCapacity, value: 0.25)) // +25%
            }
        case .awareness:
            if skill.level >= 5 {
                perks.append(Perk(type: .expeditionSuccessRate, value: 0.03)) // +3%
            }
        case .flow:
            if skill.level >= 5 {
                perks.append(Perk(type: .skillXpBonus, value: 0.10)) // +10%
            }
        case .finance:
            if skill.level >= 5 {
                perks.append(Perk(type: .resourceGathering, value: 0.05)) // +5%
            }
        case .other:
            // No perks for "other" skill
            break
        }
        
        return perks
    }
    
    private func unlockPerk(_ perk: Perk) {
        perk.activate()
        activePerks.append(perk)
        perk.apply(gameState: gameState)
        
        // Show unlock notification via ToastCenter
        gameState.toastCenter.showPerkUnlock(perk: perk)
    }
    
    // MARK: - Perk Effects
    func getExpeditionSuccessRateBonus() -> Double {
        return activePerks
            .filter { $0.perkType == .expeditionSuccessRate }
            .reduce(0.0) { $0 + $1.value }
    }
    
    func getStudyProductionBonus() -> Double {
        return activePerks
            .filter { $0.perkType == .studyProduction }
            .reduce(0.0) { $0 + $1.value }
    }
    
    func getDailyFocusSlotsBonus() -> Int {
        return Int(activePerks
            .filter { $0.perkType == .dailyFocusSlots }
            .reduce(0.0) { $0 + $1.value })
    }
    
    func getResourceGatheringBonus() -> Double {
        return activePerks
            .filter { $0.perkType == .resourceGathering }
            .reduce(0.0) { $0 + $1.value }
    }
    
    func getSkillXpBonus() -> Double {
        return activePerks
            .filter { $0.perkType == .skillXpBonus }
            .reduce(0.0) { $0 + $1.value }
    }
    
    func getBuildingEfficiencyBonus() -> Double {
        return activePerks
            .filter { $0.perkType == .buildingEfficiency }
            .reduce(0.0) { $0 + $1.value }
    }
    
    func getHomesteadCapacityBonus() -> Double {
        return activePerks
            .filter { $0.perkType == .homesteadCapacity }
            .reduce(0.0) { $0 + $1.value }
    }
}
