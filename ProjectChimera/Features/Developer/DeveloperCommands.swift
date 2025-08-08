import SwiftUI
import SwiftData

// MARK: - Developer Commands
struct DeveloperCommands: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var gameState: ChimeraGameState
    @State private var gameStateManager: GameStateManager?
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingResourceGrant = false
    @State private var showingXPGrant = false
    @State private var showingTimerControl = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Data Management") {
                    Button("Export Backup") {
                        exportBackup()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Import Backup") {
                        showingImportSheet = true
                    }
                    .foregroundColor(.green)
                    
                    Button("Reset All Data") {
                        resetAllData()
                    }
                    .foregroundColor(.red)
                }
                
                Section("Validation") {
                    Button("Validate Data Integrity") {
                        validateDataIntegrity()
                    }
                    .foregroundColor(.orange)
                    
                    Button("Show Data Statistics") {
                        showDataStatistics()
                    }
                    .foregroundColor(.purple)
                }
                
                Section("Testing") {
                    Button("Generate Test Data") {
                        generateTestData()
                    }
                    .foregroundColor(.teal)
                    
                    Button("Simulate Level Up") {
                        simulateLevelUp()
                    }
                    .foregroundColor(.indigo)
                }
                
                Section("Developer Tools") {
                    Button("Grant Resources") {
                        showingResourceGrant = true
                    }
                    .foregroundColor(.green)
                    
                    Button("Add XP") {
                        showingXPGrant = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Fast-Forward Timers") {
                        showingTimerControl = true
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Developer Commands")
            .onAppear {
                gameStateManager = GameStateManager(modelContext: modelContext)
            }
            .sheet(isPresented: $showingExportSheet) {
                ExportBackupView()
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportBackupView()
            }
            .sheet(isPresented: $showingResourceGrant) {
                ResourceGrantView(gameState: gameState)
            }
            .sheet(isPresented: $showingXPGrant) {
                XPGrantView(gameState: gameState)
            }
            .sheet(isPresented: $showingTimerControl) {
                TimerControlView(gameState: gameState)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Export Backup
    private func exportBackup() {
        // Simplified for now - just show an alert
        alertTitle = "Export"
        alertMessage = "Export functionality would share backup data"
        showingAlert = true
    }
    
    // MARK: - Import Backup
    private func importBackup() {
        // This will be handled by the ImportBackupView
    }
    
    // MARK: - Reset Data
    private func resetAllData() {
        // Simplified for now - just show an alert
        alertTitle = "Reset"
        alertMessage = "Reset functionality would clear all data"
        showingAlert = true
    }
    
    // MARK: - Validate Data
    private func validateDataIntegrity() {
        // Simplified for now - just show an alert
        alertTitle = "Validation"
        alertMessage = "Validation functionality would check data integrity"
        showingAlert = true
    }
    
    // MARK: - Show Statistics
    private func showDataStatistics() {
        // Simplified for now - just show an alert
        alertTitle = "Statistics"
        alertMessage = "Statistics functionality would show data counts"
        showingAlert = true
    }
    
    // MARK: - Generate Test Data
    private func generateTestData() {
        // This would create sample data for testing
        alertTitle = "Test Data"
        alertMessage = "Test data generation not implemented yet"
        showingAlert = true
    }
    
    // MARK: - Simulate Level Up
    private func simulateLevelUp() {
        // This would simulate a skill level up for testing
        alertTitle = "Level Up Simulation"
        alertMessage = "Level up simulation not implemented yet"
        showingAlert = true
    }
}

// MARK: - Export Backup View
struct ExportBackupView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export Backup")
                    .font(.title)
                    .padding()
                
                Text("Backup functionality is available through the main developer commands.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Done") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Export Backup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Import Backup View
struct ImportBackupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var gameStateManager: GameStateManager?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Import Backup")
                    .font(.title)
                    .padding()
                
                Text("Select a backup file to import:")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Select Backup File") {
                    // This would open a file picker
                    alertTitle = "Import"
                    alertMessage = "File picker not implemented yet"
                    showingAlert = true
                }
                .padding()
                
                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Import Backup")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                gameStateManager = GameStateManager(modelContext: modelContext)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    DeveloperCommands()
}
