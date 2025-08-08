import SwiftUI

// MARK: - Settings Manager
@MainActor
class SettingsManager: ObservableObject {
    @Published var enableAnimations: Bool {
        didSet {
            UserDefaults.standard.set(enableAnimations, forKey: "enableAnimations")
        }
    }
    
    @Published var enableConfetti: Bool {
        didSet {
            UserDefaults.standard.set(enableConfetti, forKey: "enableConfetti")
        }
    }
    
    @Published var enableHaptics: Bool {
        didSet {
            UserDefaults.standard.set(enableHaptics, forKey: "enableHaptics")
        }
    }
    
    @Published var enableSoundEffects: Bool {
        didSet {
            UserDefaults.standard.set(enableSoundEffects, forKey: "enableSoundEffects")
        }
    }
    
    @Published var enableNotifications: Bool {
        didSet {
            UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
        }
    }
    
    init() {
        self.enableAnimations = UserDefaults.standard.bool(forKey: "enableAnimations")
        self.enableConfetti = UserDefaults.standard.bool(forKey: "enableConfetti")
        self.enableHaptics = UserDefaults.standard.bool(forKey: "enableHaptics")
        self.enableSoundEffects = UserDefaults.standard.bool(forKey: "enableSoundEffects")
        self.enableNotifications = UserDefaults.standard.bool(forKey: "enableNotifications")
        
        // Set defaults to true if not previously set
        if UserDefaults.standard.object(forKey: "enableAnimations") == nil {
            self.enableAnimations = true
        }
        if UserDefaults.standard.object(forKey: "enableConfetti") == nil {
            self.enableConfetti = true
        }
        if UserDefaults.standard.object(forKey: "enableHaptics") == nil {
            self.enableHaptics = true
        }
        if UserDefaults.standard.object(forKey: "enableSoundEffects") == nil {
            self.enableSoundEffects = true
        }
        if UserDefaults.standard.object(forKey: "enableNotifications") == nil {
            self.enableNotifications = true
        }
    }
    
    func resetCache() {
        // Clear image caches, temporary files, etc.
        URLCache.shared.removeAllCachedResponses()
        
        // Clear any other app-specific caches
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? FileManager.default.removeItem(at: cacheURL)
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingResetAlert = false
    @State private var showingAboutSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Visual Effects") {
                    Toggle("Animations", isOn: $settingsManager.enableAnimations)
                        .tint(.blue)
                    
                    Toggle("Confetti Effects", isOn: $settingsManager.enableConfetti)
                        .tint(.green)
                        .disabled(!settingsManager.enableAnimations)
                }
                
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $settingsManager.enableHaptics)
                        .tint(.orange)
                    
                    Toggle("Sound Effects", isOn: $settingsManager.enableSoundEffects)
                        .tint(.purple)
                    
                    Toggle("Notifications", isOn: $settingsManager.enableNotifications)
                        .tint(.red)
                }
                
                Section("Data & Cache") {
                    Button("Reset Cache") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.orange)
                    
                    Button("Export Data") {
                        // This would trigger data export
                    }
                    .foregroundColor(.blue)
                }
                
                Section("About") {
                    Button("About Project Chimera") {
                        showingAboutSheet = true
                    }
                    .foregroundColor(.primary)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Cache", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    settingsManager.resetCache()
                }
            } message: {
                Text("This will clear cached images and temporary files. Your game data will not be affected.")
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutView()
            }
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Project Chimera")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("A gamified productivity app that turns your daily tasks into an epic adventure.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Level up your skills through real-world achievements")
                    }
                    
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.green)
                        Text("Build and manage your homestead")
                    }
                    
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.orange)
                        Text("Embark on expeditions to gather resources")
                    }
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                        Text("Unlock perks and special abilities")
                    }
                }
                .padding()
                
                Spacer()
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("About")
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

// MARK: - Haptic Helper
class HapticHelper {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}

#Preview {
    SettingsView()
}
