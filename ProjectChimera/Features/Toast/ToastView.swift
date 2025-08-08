import SwiftUI

struct ToastView: View {
    let toast: ToastItem
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main toast content
            HStack(spacing: 12) {
                // Icon
                Image(systemName: toast.type.icon)
                    .font(.title2)
                    .foregroundColor(toast.type.color)
                    .frame(width: 32, height: 32)
                    .background(toast.type.color.opacity(0.2))
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(toast.type.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(toast.type.message)
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
                .accessibilityLabel("Dismiss notification")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .offset(y: isVisible ? 0 : -100)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(toast.type.accessibilityLabel)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to dismiss")
        }
        .onAppear {
            isVisible = true
            
            // Show confetti for level-ups if enabled
            if case .levelUp = toast.type {
                showConfetti = true
            }
            
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
        .overlay(
            // Confetti effect for level-ups
            ConfettiView()
                .opacity(showConfetti ? 1 : 0)
                .animation(.easeInOut(duration: 2.0), value: showConfetti)
        )
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            ConfettiParticle(
                id: UUID(),
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: 0.5...1.5),
                color: [.red, .blue, .green, .yellow, .purple, .orange].randomElement() ?? .red
            )
        }
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: Identifiable {
    let id: UUID
    let x: Double
    let y: Double
    let rotation: Double
    let scale: Double
    let color: Color
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 8, height: 8)
            .scaleEffect(particle.scale)
            .position(
                x: particle.x * UIScreen.main.bounds.width,
                y: particle.y * UIScreen.main.bounds.height
            )
            .rotationEffect(.degrees(particle.rotation))
            .opacity(isAnimating ? 0 : 1)
            .animation(
                .easeOut(duration: 2.0)
                .delay(Double.random(in: 0...0.5)),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Toast Overlay
struct ToastOverlay: View {
    @ObservedObject var toastCenter: ToastCenter
    
    var body: some View {
        ZStack {
            if toastCenter.isShowingToast, let toast = toastCenter.currentToast {
                // Background overlay
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture {
                        toastCenter.dismissCurrentToast()
                    }
                
                // Toast
                VStack {
                    Spacer()
                    
                    ToastView(toast: toast) {
                        toastCenter.dismissCurrentToast()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: toastCenter.isShowingToast)
    }
}

#Preview {
    ToastView(
        toast: ToastItem(type: .xpGain(skill: .strength, amount: 50, level: 3))
    ) {
        print("Dismissed")
    }
}

