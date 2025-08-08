import SwiftUI
import SwiftData

struct SkillWebView: View {
    @EnvironmentObject var gameState: ChimeraGameState
    @State private var selectedSkill: Skill?
    @State private var showingSkillDetail = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(SkillName.allCases, id: \.self) { skillName in
                        if let skill = gameState.getSkill(by: skillName) {
                            SkillBadge(skill: skill)
                                .onTapGesture {
                                    selectedSkill = skill
                                    showingSkillDetail = true
                                }
                        } else {
                            // Placeholder for skills that haven't been created yet
                            SkillBadge(skill: Skill(name: skillName))
                                .onTapGesture {
                                    let newSkill = Skill(name: skillName)
                                    selectedSkill = newSkill
                                    showingSkillDetail = true
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Skill Web")
            .sheet(isPresented: $showingSkillDetail) {
                if let skill = selectedSkill {
                    SkillWebDetailView(skill: skill)
                }
            }
        }
    }
}

struct SkillWebDetailView: View {
    let skill: Skill
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Skill Header
                    VStack(alignment: .center, spacing: 10) {
                        Text(skill.skillName.rawValue)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Level \(skill.level)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // XP Progress
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Experience")
                            .font(.headline)
                        
                        HStack {
                            Text("\(skill.xp) / \(skill.nextLevelXP()) XP")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int((Double(skill.xp) / Double(skill.nextLevelXP())) * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: Double(skill.xp), total: Double(skill.nextLevelXP()))
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Upcoming Perks (Placeholder)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upcoming Perks")
                            .font(.headline)
                        
                        Text("Coming soon! Perks and abilities will be unlocked as you progress.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Skill Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SkillWebView()
        .environmentObject(ChimeraGameState())
}
