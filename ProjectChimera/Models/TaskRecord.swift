import Foundation
import SwiftData

@Model
final class TaskRecord {
    var id: UUID
    var date: Date
    var skillRef: Skill?
    var amountXP: Int
    var difficulty: String // Store as string for SwiftData compatibility
    
    init(skill: Skill, amountXP: Int, difficulty: String) {
        self.id = UUID()
        self.date = Date()
        self.skillRef = skill
        self.amountXP = amountXP
        self.difficulty = difficulty
    }
    
    convenience init() {
        self.init(skill: Skill(), amountXP: 10, difficulty: "Easy")
    }
}
