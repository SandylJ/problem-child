import SwiftUI

struct SkillBadge: View {
    let skill: Skill
    
    private var progressPercentage: Double {
        guard skill.nextLevelXP() > 0 else { return 0 }
        return Double(skill.xp) / Double(skill.nextLevelXP())
    }
    
    private var skillColor: Color {
        switch skill.skillName {
        case .strength:
            return .red
        case .mind:
            return .blue
        case .joy:
            return .yellow
        case .vitality:
            return .green
        case .awareness:
            return .purple
        case .flow:
            return .orange
        case .finance:
            return .mint
        case .other:
            return .gray
        case .runecrafting:
            return .cyan
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Skill Icon/Name
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(skillColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(skill.skillName.rawValue.prefix(1))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(skillColor)
                }
                
                Text(skill.skillName.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            
            // Level
            Text("Lv \(skill.level)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // XP Progress
            VStack(spacing: 2) {
                HStack {
                    Text("\(skill.xp)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(skill.nextLevelXP())")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: skillColor))
                    .scaleEffect(y: 0.5)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(skillColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            SkillBadge(skill: Skill(name: .strength))
            SkillBadge(skill: Skill(name: .mind))
            SkillBadge(skill: Skill(name: .joy))
        }
        
        HStack(spacing: 20) {
            SkillBadge(skill: Skill(name: .vitality))
            SkillBadge(skill: Skill(name: .awareness))
            SkillBadge(skill: Skill(name: .flow))
        }
    }
    .padding()
    .background(Color(.systemGray6))
}

