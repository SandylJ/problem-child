import Foundation
import SwiftData
import SwiftUI

enum ResourceKind: String, CaseIterable, Codable {
    case rations = "Rations"
    case tools = "Tools"
    case intel = "Intel"
    case materials = "Materials"
    case currency = "Currency"
    case essence = "Essence"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .rations: return "fork.knife"
        case .tools: return "wrench.and.screwdriver.fill"
        case .intel: return "doc.text.fill"
        case .materials: return "cube.fill"
        case .currency: return "dollarsign.circle.fill"
        case .essence: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .rations: return .orange
        case .tools: return .blue
        case .intel: return .purple
        case .materials: return .brown
        case .currency: return .yellow
        case .essence: return .cyan
        }
    }
}

@Model
final class Resource {
    var id: UUID
    var kind: String // Store as string for SwiftData compatibility
    var quantity: Int
    
    init(kind: ResourceKind, quantity: Int = 0) {
        self.id = UUID()
        self.kind = kind.rawValue
        self.quantity = quantity
    }
    
    convenience init() {
        self.init(kind: .rations)
    }
    
    var resourceKind: ResourceKind {
        get { ResourceKind(rawValue: kind) ?? .rations }
        set { kind = newValue.rawValue }
    }
    
    func add(_ amount: Int) {
        quantity = max(0, quantity + amount)
    }
    
    func remove(_ amount: Int) -> Bool {
        guard quantity >= amount else { return false }
        quantity -= amount
        return true
    }
}
