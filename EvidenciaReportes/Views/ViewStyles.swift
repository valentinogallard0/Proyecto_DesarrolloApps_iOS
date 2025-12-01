// Centralized styles for common views
//  EvidenciaReportes
//  Creado para refactorización
import SwiftUI

extension View {
    /// Card style with background, rounded corners, and shadow
    func cardStyle(cornerRadius: CGFloat = 16, shadowColor: Color = .black.opacity(0.05), shadowRadius: CGFloat = 8, shadowYOffset: CGFloat = 4) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
            )
    }
    
    /// Style for report icon backgrounds
    func reportIconBackground(_ color: Color, cornerRadius: CGFloat = 12) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(0.15))
            )
    }
}
