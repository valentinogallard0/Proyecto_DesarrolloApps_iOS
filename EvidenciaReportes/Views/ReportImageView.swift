// View for displaying a report's image, if available
//  EvidenciaReportes
//  Creado para refactorización
import SwiftUI
import UIKit

struct ReportImageView: View {
    let imageData: Data?
    let height: CGFloat
    
    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    .cornerRadius(12)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.secondary.opacity(0.08))
                    VStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("Sin imagen")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: height)
            }
        }
    }
}

#Preview {
    ReportImageView(imageData: nil, height: 160)
}
