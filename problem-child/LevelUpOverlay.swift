import SwiftUI
#if canImport(Vortex)
import Vortex
#endif

// This view displays a celebratory confetti effect.
struct LevelUpOverlay: View {
    @Binding var didLevelUp: Bool
    
    var body: some View {
        ZStack {
            if didLevelUp {
                #if canImport(Vortex)
                VortexViewReader { proxy in
                    VortexView(.confetti) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 16, height: 16)
                            .tag("square")
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 16)
                            .tag("circle")
                    }
                    .onAppear {
                        proxy.burst()
                        // Reset the state after a delay to hide the overlay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            didLevelUp = false
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false) // Allows taps to go through the overlay
                #else
                // Fallback: simple overlay without Vortex
                Text("Level Up!")
                    .font(.largeTitle.bold())
                    .padding(24)
                    .background(.ultraThinMaterial, in: Capsule())
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            didLevelUp = false
                        }
                    }
                #endif
            }
        }
    }
}
