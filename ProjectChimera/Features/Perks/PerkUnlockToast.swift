import SwiftUI

struct PerkUnlockToast: View {
    let perk: Perk
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main toast content
            HStack(spacing: 12) {
                // Perk icon
                Image(systemName: perk.perkType.icon)
                    .font(.title2)
                    .foregroundColor(perk.perkType.color)
                    .frame(width: 32, height: 32)
                    .background(perk.perkType.color.opacity(0.2))
                    .clipShape(Circle())
                
                // Perk details
                VStack(alignment: .leading, spacing: 2) {
                    Text("New Perk Unlocked!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(perk.perkType.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(perk.perkType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .offset(y: isVisible ? 0 : -100)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
        }
        .onAppear {
            isVisible = true
            
            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Perk Unlock Overlay
struct PerkUnlockOverlay: View {
    @ObservedObject var perkManager: PerkManager
    
    var body: some View {
        ZStack {
            if perkManager.showingPerkUnlock, let perk = perkManager.unlockedPerk {
                // Background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        perkManager.showingPerkUnlock = false
                        perkManager.unlockedPerk = nil
                    }
                
                // Toast
                VStack {
                    Spacer()
                    
                    PerkUnlockToast(perk: perk) {
                        perkManager.showingPerkUnlock = false
                        perkManager.unlockedPerk = nil
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: perkManager.showingPerkUnlock)
    }
}

#Preview {
    PerkUnlockToast(
        perk: Perk(type: .expeditionSuccessRate, value: 0.05)
    ) {
        print("Dismissed")
    }
}

