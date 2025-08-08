import SwiftUI

// MARK: - Resource Grant View
struct ResourceGrantView: View {
    let gameState: ChimeraGameState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedResource: ResourceKind = .rations
    @State private var amount: String = "100"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Select Resource") {
                    Picker("Resource Type", selection: $selectedResource) {
                        ForEach(ResourceKind.allCases, id: \.self) { resource in
                            HStack {
                                Image(systemName: resource.icon)
                                    .foregroundColor(resource.color)
                                Text(resource.displayName)
                            }
                            .tag(resource)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Amount") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.numberPad)
                }
                
                Section("Current Resources") {
                    ForEach(ResourceKind.allCases, id: \.self) { resource in
                        HStack {
                            Image(systemName: resource.icon)
                                .foregroundColor(resource.color)
                            Text(resource.displayName)
                            Spacer()
                            Text("\(gameState.getResource(by: resource)?.quantity ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Grant Resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Grant") {
                        grantResource()
                    }
                    .disabled(amount.isEmpty || Int(amount) == nil)
                }
            }
            .alert("Resource Granted", isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func grantResource() {
        guard let amountInt = Int(amount) else { return }
        
        gameState.addResource(kind: selectedResource, amount: amountInt)
        
        alertMessage = "Granted \(amountInt) \(selectedResource.displayName)"
        showingAlert = true
    }
}

// MARK: - XP Grant View
struct XPGrantView: View {
    let gameState: ChimeraGameState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSkill: SkillName = .strength
    @State private var amount: String = "50"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Select Skill") {
                    Picker("Skill", selection: $selectedSkill) {
                        ForEach(SkillName.allCases, id: \.self) { skill in
                            HStack {
                                Image(systemName: skill.icon)
                                    .foregroundColor(skill.color)
                                Text(skill.displayName)
                            }
                            .tag(skill)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("XP Amount") {
                    TextField("XP Amount", text: $amount)
                        .keyboardType(.numberPad)
                }
                
                Section("Current Skills") {
                    ForEach(SkillName.allCases, id: \.self) { skill in
                        HStack {
                            Image(systemName: skill.icon)
                                .foregroundColor(skill.color)
                            Text(skill.displayName)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Lv \(gameState.getSkill(by: skill)?.level ?? 1)")
                                    .font(.caption)
                                Text("\(gameState.getSkill(by: skill)?.xp ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add XP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addXP()
                    }
                    .disabled(amount.isEmpty || Int(amount) == nil)
                }
            }
            .alert("XP Added", isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addXP() {
        guard let amountInt = Int(amount) else { return }
        
        gameState.awardXP(skill: selectedSkill, amount: amountInt)
        
        alertMessage = "Added \(amountInt) XP to \(selectedSkill.displayName)"
        showingAlert = true
    }
}

// MARK: - Timer Control View
struct TimerControlView: View {
    let gameState: ChimeraGameState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeAdvance: String = "60"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Fast-Forward Time") {
                    Picker("Time Advance", selection: $selectedTimeAdvance) {
                        Text("1 minute").tag("60")
                        Text("5 minutes").tag("300")
                        Text("10 minutes").tag("600")
                        Text("30 minutes").tag("1800")
                        Text("1 hour").tag("3600")
                        Text("1 day").tag("86400")
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Actions") {
                    Button("Advance Building Production") {
                        advanceBuildingProduction()
                    }
                    .foregroundColor(.green)
                    
                    Button("Complete Active Expeditions") {
                        completeExpeditions()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Advance All Timers") {
                        advanceAllTimers()
                    }
                    .foregroundColor(.orange)
                }
                
                Section("Current Status") {
                    HStack {
                        Text("Active Expeditions")
                        Spacer()
                        Text("\(getActiveExpeditionCount())")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Building Production")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Timer Control")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Time Advanced", isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func advanceBuildingProduction() {
        guard let timeAdvance = Double(selectedTimeAdvance) else { return }
        
        // Simulate building production advancement
        let advanceDate = Date().addingTimeInterval(-timeAdvance)
        
        // Update building production times
        // This would need to be implemented in HomesteadManager
        
        alertMessage = "Advanced building production by \(Int(timeAdvance/60)) minutes"
        showingAlert = true
    }
    
    private func completeExpeditions() {
        // This would complete all active expeditions
        // Implementation would need to be added to ExpeditionsView
        
        alertMessage = "Completed all active expeditions"
        showingAlert = true
    }
    
    private func advanceAllTimers() {
        guard let timeAdvance = Double(selectedTimeAdvance) else { return }
        
        // Advance building production
        advanceBuildingProduction()
        
        // Complete expeditions
        completeExpeditions()
        
        alertMessage = "Advanced all timers by \(Int(timeAdvance/60)) minutes"
        showingAlert = true
    }
    
    private func getActiveExpeditionCount() -> Int {
        // This would count active expeditions
        // Implementation would need to be added
        return 0
    }
}

#Preview {
    ResourceGrantView(gameState: ChimeraGameState())
}

