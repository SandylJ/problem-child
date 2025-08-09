import SwiftUI
#if canImport(Vortex)
import Vortex
#endif

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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            didLevelUp = false
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                #else
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
