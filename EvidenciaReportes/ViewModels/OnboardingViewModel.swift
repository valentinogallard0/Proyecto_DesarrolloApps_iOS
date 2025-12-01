//
//  OnboardingViewModel.swift
//  EvidenciaReportes
//
//  Created by Codex on 30/11/25.
//

import Foundation

struct OnboardingSlide: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let slides: [OnboardingSlide] = [
        OnboardingSlide(title: "Reporta incidentes", description: "Captura baches, luminarias y fugas en segundos para ayudar a tu ciudad.", systemImage: "exclamationmark.bubble"),
        OnboardingSlide(title: "Visualiza en el mapa", description: "Explora reportes cercanos y consulta su avance en tiempo real.", systemImage: "map.fill"),
        OnboardingSlide(title: "Respira informado", description: "Monitorea clima y calidad del aire para planear tu día.", systemImage: "aqi.low")
    ]
    
    var totalPages: Int { slides.count + 1 } // incluye la diapositiva de permisos
    
    var isOnLastPage: Bool {
        currentPage >= slides.count
    }
    
    func advance() {
        currentPage = min(currentPage + 1, totalPages - 1)
    }
}
