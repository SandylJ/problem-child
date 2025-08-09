import Foundation
import SwiftUI
import SwiftData

// MARK: - Expedition Types
enum ExpeditionType: String, CaseIterable, Codable {
    case forestScout = "Forest Scout"
    case mountainSurvey = "Mountain Survey"
    case riverRun = "River Run"
    case desertCaravan = "Desert Caravan"

    var description: String {
        switch self {
        case .forestScout: return "Scout the nearby forest and gather intel."
        case .mountainSurvey: return "Survey the mountains for rare materials."
        case .riverRun: return "Run supplies along the river and trade."
        case .desertCaravan: return "Escort a caravan across the desert sands."
        }
    }

    var duration: TimeInterval {
        switch self {
        case .forestScout: return 15 * 60
        case .mountainSurvey: return 30 * 60
        case .riverRun: return 45 * 60
        case .desertCaravan: return 60 * 60
        }
    }

    var requiredResources: [ResourceKind: Int] {
        switch self {
        case .forestScout: return [.rations: 2, .tools: 1]
        case .mountainSurvey: return [.rations: 3, .tools: 2]
        case .riverRun: return [.rations: 4, .materials: 2]
        case .desertCaravan: return [.rations: 5, .materials: 3, .tools: 2]
        }
    }

    var possibleRewards: [ResourceKind: Int] {
        switch self {
        case .forestScout: return [.intel: 5, .rations: 2]
        case .mountainSurvey: return [.materials: 6, .tools: 2]
        case .riverRun: return [.currency: 40, .rations: 3]
        case .desertCaravan: return [.currency: 80, .materials: 4]
        }
    }

    #if os(iOS) || os(tvOS) || os(watchOS)
    var color: UIColor {
        switch self {
        case .forestScout: return .systemGreen
        case .mountainSurvey: return .systemGray
        case .riverRun: return .systemBlue
        case .desertCaravan: return .systemOrange
        }
    }
    #else
    var color: NSColor {
        switch self {
        case .forestScout: return .systemGreen
        case .mountainSurvey: return .systemGray
        case .riverRun: return .systemBlue
        case .desertCaravan: return .systemOrange
        }
    }
    #endif

    var icon: String {
        switch self {
        case .forestScout: return "leaf.fill"
        case .mountainSurvey: return "mountain.2.fill"
        case .riverRun: return "waveform.path.ecg"
        case .desertCaravan: return "sun.max.fill"
        }
    }
}

// MARK: - Player Expedition Model
@Model
final class PlayerExpedition {
    var id: UUID
    var type: String
    var startTime: Date?
    var endTime: Date?
    var isActive: Bool
    var isCompleted: Bool

    init(type: ExpeditionType) {
        self.id = UUID()
        self.type = type.rawValue
        self.startTime = nil
        self.endTime = nil
        self.isActive = false
        self.isCompleted = false
    }

    var expeditionType: ExpeditionType {
        get { ExpeditionType(rawValue: type) ?? .forestScout }
        set { type = newValue.rawValue }
    }

    var duration: TimeInterval { expeditionType.duration }
    var requiredResources: [ResourceKind: Int] { expeditionType.requiredResources }
    var possibleRewards: [ResourceKind: Int] { expeditionType.possibleRewards }

    func startExpedition() {
        guard !isActive && !isCompleted else { return }
        isActive = true
        startTime = Date()
        endTime = startTime?.addingTimeInterval(duration)
    }

    func isReadyToComplete() -> Bool {
        guard isActive, let end = endTime else { return false }
        return Date() >= end
    }

    func getRemainingTime() -> TimeInterval {
        guard isActive, let end = endTime else { return 0 }
        return max(0, end.timeIntervalSinceNow)
    }

    func getProgress() -> Double {
        guard let start = startTime else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        return min(1.0, max(0.0, elapsed / duration))
    }

    func completeExpedition() {
        guard isReadyToComplete() else { return }
        isActive = false
        isCompleted = true
    }
}

// MARK: - Player Expedition Report Model
@Model
final class PlayerExpeditionReport {
    var id: UUID
    var expeditionId: UUID
    var expeditionType: String
    var completionDate: Date
    private var rewardsJSON: String

    init(expedition: PlayerExpedition, rewards: [ResourceKind: Int]) {
        self.id = UUID()
        self.expeditionId = expedition.id
        self.expeditionType = expedition.type
        self.completionDate = Date()
        // Encode rewards to JSON string
        let dict = Dictionary(uniqueKeysWithValues: rewards.map { ($0.key.rawValue, $0.value) })
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let json = String(data: data, encoding: .utf8) {
            self.rewardsJSON = json
        } else {
            self.rewardsJSON = "{}"
        }
    }

    var expeditionTypeEnum: ExpeditionType {
        ExpeditionType(rawValue: expeditionType) ?? .forestScout
    }

    var rewardsDict: [ResourceKind: Int] {
        guard let data = rewardsJSON.data(using: .utf8),
              let raw = (try? JSONSerialization.jsonObject(with: data)) as? [String: Int] else { return [:] }
        var result: [ResourceKind: Int] = [:]
        for (k, v) in raw {
            if let kind = ResourceKind(rawValue: k) { result[kind] = v }
        }
        return result
    }
}