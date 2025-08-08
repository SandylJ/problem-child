import SwiftUI
import UIKit

// MARK: - Toast Types
enum ToastType {
    case xpGain(skill: SkillName, amount: Int, level: Int)
    case perkUnlock(perk: Perk)
    case levelUp(skill: SkillName, newLevel: Int)
    case resourceGain(kind: ResourceKind, amount: Int)
    case achievement(title: String, description: String)
    
    var title: String {
        switch self {
        case .xpGain(let skill, let amount, _):
            return "+\(amount) \(skill.displayName) XP"
        case .perkUnlock:
            return "New Perk Unlocked!"
        case .levelUp(let skill, let newLevel):
            return "\(skill.displayName) Level \(newLevel)!"
        case .resourceGain(let kind, let amount):
            return "+\(amount) \(kind.displayName)"
        case .achievement(let title, _):
            return title
        }
    }
    
    var message: String {
        switch self {
        case .xpGain(_, _, let level):
            return "Level \(level)"
        case .perkUnlock(let perk):
            return perk.perkType.rawValue
        case .levelUp(let skill, _):
            return "\(skill.displayName) has leveled up!"
        case .resourceGain(_, _):
            return "Resource gained"
        case .achievement(_, let description):
            return description
        }
    }
    
    var icon: String {
        switch self {
        case .xpGain(let skill, _, _):
            return skill.icon
        case .perkUnlock(let perk):
            return perk.perkType.icon
        case .levelUp(let skill, _):
            return skill.icon
        case .resourceGain(let kind, _):
            return kind.icon
        case .achievement:
            return "trophy.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .xpGain(let skill, _, _):
            return skill.color
        case .perkUnlock(let perk):
            return perk.perkType.color
        case .levelUp(let skill, _):
            return skill.color
        case .resourceGain(let kind, _):
            return kind.color
        case .achievement:
            return .yellow
        }
    }
    
    var hapticType: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .xpGain:
            return .light
        case .perkUnlock:
            return .medium
        case .levelUp:
            return .heavy
        case .resourceGain:
            return .light
        case .achievement:
            return .heavy
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .xpGain(let skill, let amount, let level):
            return "Gained \(amount) \(skill.displayName) experience points. Current level \(level)"
        case .perkUnlock(let perk):
            return "New perk unlocked: \(perk.perkType.rawValue). \(perk.perkType.description)"
        case .levelUp(let skill, let newLevel):
            return "\(skill.displayName) has reached level \(newLevel)"
        case .resourceGain(let kind, let amount):
            return "Gained \(amount) \(kind.displayName)"
        case .achievement(let title, let description):
            return "Achievement unlocked: \(title). \(description)"
        }
    }
}

// MARK: - Toast Item
struct ToastItem: Identifiable {
    let id = UUID()
    let type: ToastType
    let timestamp: Date
    
    init(type: ToastType) {
        self.type = type
        self.timestamp = Date()
    }
}

// MARK: - Toast Center
@MainActor
class ToastCenter: ObservableObject {
    @Published var currentToast: ToastItem?
    @Published var isShowingToast = false
    
    private var toastQueue: [ToastItem] = []
    private var hapticGenerator: UIImpactFeedbackGenerator?
    
    // MARK: - User Settings
    @Published var showConfettiOnLevelUp = true
    @Published var enableHapticFeedback = true
    
    init() {
        setupHapticGenerator()
    }
    
    private func setupHapticGenerator() {
        hapticGenerator = UIImpactFeedbackGenerator(style: .light)
        hapticGenerator?.prepare()
    }
    
    // MARK: - Toast Management
    func showToast(_ type: ToastType) {
        let toast = ToastItem(type: type)
        
        if currentToast == nil {
            displayToast(toast)
        } else {
            toastQueue.append(toast)
        }
    }
    
    private func displayToast(_ toast: ToastItem) {
        currentToast = toast
        isShowingToast = true
        
        // Trigger haptic feedback
        if enableHapticFeedback {
            triggerHapticFeedback(for: toast.type)
        }
        
        // Auto-dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissCurrentToast()
        }
    }
    
    func dismissCurrentToast() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isShowingToast = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.currentToast = nil
            self.showNextToast()
        }
    }
    
    private func showNextToast() {
        guard !toastQueue.isEmpty else { return }
        let nextToast = toastQueue.removeFirst()
        displayToast(nextToast)
    }
    
    // MARK: - Haptic Feedback
    private func triggerHapticFeedback(for type: ToastType) {
        let generator = UIImpactFeedbackGenerator(style: type.hapticType)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Convenience Methods
    func showXPGain(skill: SkillName, amount: Int, level: Int) {
        showToast(.xpGain(skill: skill, amount: amount, level: level))
    }
    
    func showPerkUnlock(perk: Perk) {
        showToast(.perkUnlock(perk: perk))
    }
    
    func showLevelUp(skill: SkillName, newLevel: Int) {
        showToast(.levelUp(skill: skill, newLevel: newLevel))
    }
    
    func showResourceGain(kind: ResourceKind, amount: Int) {
        showToast(.resourceGain(kind: kind, amount: amount))
    }
    
    func showAchievement(title: String, description: String) {
        showToast(.achievement(title: title, description: description))
    }
}
