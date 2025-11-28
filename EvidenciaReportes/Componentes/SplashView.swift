
import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    // Estado para la animación (opacidad y escala)
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    // Estado para el cambio de vista
    @State private var shouldTransition: Bool = false

    var body: some View {
        ZStack {
            // 1. Fondo que se adapta al modo Oscuro/Claro.
            // Usamos .background en el ZStack para mayor consistencia.
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) { // Espaciado un poco más compacto
                // 2. Icono central
                Image(systemName: "leaf.fill")
                    .font(.system(size: 80)) // Icono más grande
                    .foregroundColor(.green) // Usamos .foregroundColor para el color de primer plano
                    .shadow(radius: 5) // Una sombra sutil le da profundidad

                // 3. Título principal
                Text("Ciudad Activa")
                    .font(.custom("AvenirNext-Bold", size: 34)) // Fuente personalizada si está disponible, o simplemente .largeTitle
                    .fontWeight(.bold)
                    .foregroundColor(.primary) // Se adapta al modo Oscuro/Claro

                // 4. Subtítulo (opcional, pero funciona bien para un mensaje clave)
                Text("Reporta. Participa. Respira mejor.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            // Aplicamos los efectos de animación a todo el VStack
            .opacity(opacity)
            .scaleEffect(scale)
            
            // 5. Animación de carga (indicador de actividad)
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .green))
                    .scaleEffect(1.5) // Indicador un poco más grande
                    .padding(.bottom, 50)
            }
            .opacity(opacity) // También animamos el ProgressView
        }
        .onAppear {
            // Animación inicial de la aparición
            withAnimation(.easeOut(duration: 1.0)) { // Animación más larga y suave
                opacity = 1.0
                scale = 1.0 // Escala de 0.8 a 1.0 para el efecto de "rebote"
            }
            
            // Retraso para la permanencia del splash screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Tiempo de espera ajustado a 1.5s
                shouldTransition = true // Cambiamos el estado de transición
                
                // Animación de salida (opcional: desvanecer el splash)
                withAnimation(.easeIn(duration: 0.5)) {
                    opacity = 0.0 // Hace que el splash se desvanezca
                }
            }
            
            // Retraso adicional para que la animación de salida se complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if shouldTransition {
                    withAnimation {
                        isActive = false // Finalmente, cambiamos la vista
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
