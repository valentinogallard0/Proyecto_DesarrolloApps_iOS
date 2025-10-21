import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var opacity: Double = 0.7

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("Ciudad Activa")
                    .font(.largeTitle).bold()
                Text("Reporta. Participa. Respira mejor.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.7)) {
                    opacity = 1.0
                }
                // Cambia a HomeView después de 2 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = false
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
