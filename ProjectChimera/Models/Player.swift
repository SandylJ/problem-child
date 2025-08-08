import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var name: String
    var level: Int
    var essence: Int
    var gold: Int
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.level = 1
        self.essence = 0
        self.gold = 100
    }
    
    convenience init() {
        self.init(name: "Player")
    }
}

