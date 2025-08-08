import Foundation

public struct RewardBundle: Codable, Hashable {
    public var gold: Int = 0
    public var items: [String: Int] = [:]
}

public enum ChallengeKind: String, Codable, CaseIterable {
    case tasksCompleted
    case steps
    case crafting
    case questBoss
}

public struct DailyChallenge: Identifiable, Codable, Hashable {
    public let id: UUID
    public let kind: ChallengeKind
    public let target: Int
    public let reward: RewardBundle
    public var progress: Int = 0

    public var isDone: Bool { progress >= target }
    
    public init(kind: ChallengeKind, target: Int, reward: RewardBundle) {
        self.id = UUID()
        self.kind = kind
        self.target = target
        self.reward = reward
        self.progress = 0
    }
}
