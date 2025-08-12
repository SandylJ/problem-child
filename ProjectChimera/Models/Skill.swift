import Foundation
import SwiftData
import SwiftUI

enum SkillName: String, CaseIterable, Codable {
    case strength = "Strength"
    case mind = "Mind"
    case joy = "Joy"
    case vitality = "Vitality"
    case awareness = "Awareness"
    case flow = "Flow"
    case finance = "Finance"
    case other = "Other"
    case runecrafting = "Runecrafting"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .mind: return "brain.head.profile"
        case .joy: return "heart.fill"
        case .vitality: return "leaf.fill"
        case .awareness: return "eye.fill"
        case .flow: return "drop.fill"
        case .finance: return "dollarsign.circle.fill"
        case .other: return "questionmark.circle.fill"
        case .runecrafting: return "wand.and.stars"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return .red
        case .mind: return .blue
        case .joy: return .pink
        case .vitality: return .green
        case .awareness: return .purple
        case .flow: return .cyan
        case .finance: return .yellow
        case .other: return .gray
        case .runecrafting: return .cyan
        }
    }
}

@Model
final class Skill {
    var id: UUID
    var name: String // Store as string for SwiftData compatibility
    var level: Int
    var xp: Int
    
    init(name: SkillName) {
        self.id = UUID()
        self.name = name.rawValue
        self.level = 1
        self.xp = 0
    }
    
    convenience init() {
        self.init(name: .strength)
    }
    
    func nextLevelXP() -> Int {
        // Simple XP curve: each level requires level * 100 XP
        return level * 100
    }
    
    func addXP(_ amount: Int) {
        xp += amount
        
        // Check for level up
        while xp >= nextLevelXP() {
            xp -= nextLevelXP()
            level += 1
        }
    }
    
    var skillName: SkillName {
        get { SkillName(rawValue: name) ?? .strength }
        set { name = newValue.rawValue }
    }
}
