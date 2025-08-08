import SwiftUI
import SwiftData

struct ExpeditionsView: View {
    @EnvironmentObject var gameState: ChimeraGameState
    @Environment(\.modelContext) private var modelContext
    @State private var expeditions: [PlayerExpedition] = []
    @State private var reports: [PlayerExpeditionReport] = []
    @State private var selectedExpedition: PlayerExpedition?
    @State private var showingExpeditionDetail = false
    @State private var showingCompletionAlert = false
    @State private var completedExpedition: PlayerExpedition?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Active Expeditions
                    if !activeExpeditions.isEmpty {
                        PlayerActiveExpeditionsSection(
                            expeditions: activeExpeditions,
                            onComplete: completeExpedition
                        )
                    }
                    
                    // Available Expeditions
                    PlayerAvailableExpeditionsSection(
                        expeditions: availableExpeditions,
                        gameState: gameState,
                        onStart: startExpedition
                    )
                    
                    // Recent Reports
                    if !reports.isEmpty {
                        PlayerRecentReportsSection(reports: reports)
                    }
                }
                .padding()
            }
            .navigationTitle("Expeditions")
            .onReceive(timer) { _ in
                checkForCompletedExpeditions()
            }
            .onAppear {
                loadExpeditions()
                loadReports()
            }
            .alert("Expedition Complete!", isPresented: $showingCompletionAlert) {
                Button("Collect Rewards") {
                    if let expedition = completedExpedition {
                        collectRewards(for: expedition)
                    }
                }
            } message: {
                if let expedition = completedExpedition {
                    Text("Your \(expedition.expeditionType.rawValue) expedition has returned with valuable resources!")
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var activeExpeditions: [PlayerExpedition] {
        expeditions.filter { $0.isActive }
    }
    
    private var availableExpeditions: [PlayerExpedition] {
        expeditions.filter { !$0.isActive && !$0.isCompleted }
    }
    
    // MARK: - Data Loading
    private func loadExpeditions() {
        do {
            let descriptor = FetchDescriptor<PlayerExpedition>()
            expeditions = try modelContext.fetch(descriptor)
            
            // Create default expeditions if none exist
            if expeditions.isEmpty {
                for expeditionType in ExpeditionType.allCases {
                    let expedition = PlayerExpedition(type: expeditionType)
                    expeditions.append(expedition)
                    modelContext.insert(expedition)
                }
                try modelContext.save()
            }
        } catch {
            print("Failed to load expeditions: \(error)")
        }
    }
    
    private func loadReports() {
        do {
            let descriptor = FetchDescriptor<PlayerExpeditionReport>()
            reports = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load reports: \(error)")
        }
    }
    
    // MARK: - Expedition Management
    private func startExpedition(_ expedition: PlayerExpedition) {
        // Check if player has required resources
        for (resourceKind, requiredAmount) in expedition.requiredResources {
            if let resource = gameState.getResource(by: resourceKind) {
                if resource.quantity < requiredAmount {
                    return // Not enough resources
                }
            } else {
                return // Resource doesn't exist
            }
        }
        
        // Consume resources
        for (resourceKind, requiredAmount) in expedition.requiredResources {
            if let resource = gameState.getResource(by: resourceKind) {
                _ = resource.remove(requiredAmount)
            }
        }
        
        // Start expedition
        expedition.startExpedition()
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save expedition: \(error)")
        }
    }
    
    private func completeExpedition(_ expedition: PlayerExpedition) {
        guard expedition.isReadyToComplete() else { return }
        
        completedExpedition = expedition
        showingCompletionAlert = true
    }
    
    private func collectRewards(for expedition: PlayerExpedition) {
        // Generate rewards (placeholder - could be randomized)
        let rewards = expedition.possibleRewards
        
        // Add rewards to player's resources
        for (resourceKind, amount) in rewards {
            gameState.addResource(kind: resourceKind, amount: amount)
        }
        
        // Create report
        let report = PlayerExpeditionReport(expedition: expedition, rewards: rewards)
        modelContext.insert(report)
        reports.append(report)
        
        // Complete expedition
        expedition.completeExpedition()
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save expedition completion: \(error)")
        }
        
        completedExpedition = nil
    }
    
    private func checkForCompletedExpeditions() {
        for expedition in activeExpeditions {
            if expedition.isReadyToComplete() {
                // Could trigger notification here
            }
        }
    }
}

// MARK: - Active Expeditions Section
struct PlayerActiveExpeditionsSection: View {
    let expeditions: [PlayerExpedition]
    let onComplete: (PlayerExpedition) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Expeditions")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(expeditions, id: \.id) { expedition in
                PlayerActiveExpeditionCard(
                    expedition: expedition,
                    onComplete: onComplete
                )
            }
        }
    }
}

struct PlayerActiveExpeditionCard: View {
    let expedition: PlayerExpedition
    let onComplete: (PlayerExpedition) -> Void
    
    @State private var remainingTime: TimeInterval = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: expedition.expeditionType.icon)
                    .foregroundColor(Color(expedition.expeditionType.color))
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(expedition.expeditionType.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(expedition.expeditionType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if expedition.isReadyToComplete() {
                    Button("Complete") {
                        onComplete(expedition)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // Progress Bar
            ProgressView(value: expedition.getProgress())
                .progressViewStyle(LinearProgressViewStyle())
            
            // Time Remaining
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(timeString(from: remainingTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if expedition.isReadyToComplete() {
                    Text("Ready!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onAppear {
            updateTime()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTime()
        }
    }
    
    private func updateTime() {
        remainingTime = expedition.getRemainingTime()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Available Expeditions Section
struct PlayerAvailableExpeditionsSection: View {
    let expeditions: [PlayerExpedition]
    let gameState: ChimeraGameState
    let onStart: (PlayerExpedition) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Expeditions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(expeditions, id: \.id) { expedition in
                    PlayerAvailableExpeditionCard(
                        expedition: expedition,
                        gameState: gameState,
                        onStart: onStart
                    )
                }
            }
        }
    }
}

struct PlayerAvailableExpeditionCard: View {
    let expedition: PlayerExpedition
    let gameState: ChimeraGameState
    let onStart: (PlayerExpedition) -> Void
    
    private var canStart: Bool {
        for (resourceKind, requiredAmount) in expedition.requiredResources {
            if let resource = gameState.getResource(by: resourceKind) {
                if resource.quantity < requiredAmount {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: expedition.expeditionType.icon)
                    .foregroundColor(Color(expedition.expeditionType.color))
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(expedition.expeditionType.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(formatDuration(expedition.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Requirements
            VStack(alignment: .leading, spacing: 4) {
                Text("Requirements")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ForEach(Array(expedition.requiredResources.keys), id: \.self) { resourceKind in
                    let required = expedition.requiredResources[resourceKind] ?? 0
                    let available = gameState.getResource(by: resourceKind)?.quantity ?? 0
                    
                    HStack {
                        Text(resourceKind.rawValue)
                            .font(.caption)
                        Spacer()
                        Text("\(available)/\(required)")
                            .font(.caption)
                            .foregroundColor(available >= required ? .green : .red)
                    }
                }
            }
            
            // Rewards Preview
            VStack(alignment: .leading, spacing: 4) {
                Text("Rewards")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                ForEach(Array(expedition.possibleRewards.keys), id: \.self) { resourceKind in
                    let amount = expedition.possibleRewards[resourceKind] ?? 0
                    HStack {
                        Text(resourceKind.rawValue)
                            .font(.caption)
                        Spacer()
                        Text("+\(amount)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Start Button
            Button(action: {
                onStart(expedition)
            }) {
                Text("Start Expedition")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(canStart ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!canStart)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Recent Reports Section
struct PlayerRecentReportsSection: View {
    let reports: [PlayerExpeditionReport]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Reports")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(reports.prefix(5), id: \.id) { report in
                PlayerReportCard(report: report)
            }
        }
    }
}

struct PlayerReportCard: View {
    let report: PlayerExpeditionReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(report.expeditionTypeEnum.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(report.completionDate, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(Array(report.rewardsDict.keys), id: \.self) { resourceKind in
                let amount = report.rewardsDict[resourceKind] ?? 0
                HStack {
                    Text(resourceKind.rawValue)
                        .font(.caption)
                    Spacer()
                    Text("+\(amount)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ExpeditionsView()
        .environmentObject(ChimeraGameState())
        .modelContainer(for: [PlayerExpedition.self, PlayerExpeditionReport.self], inMemory: true)
}
