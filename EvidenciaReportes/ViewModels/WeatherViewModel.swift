//
//  WeatherViewModel.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 26/11/25.
//

import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var temp: Double = 0.0
    @Published var tempMin: Double = 0.0
    @Published var tempMax: Double = 0.0
    @Published var conditionText: String = "-"
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = WeatherService()
    
    func loadWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let lat = 25.6866
            let lon = -100.3167
            
            let response = try await service.fetchWeather(lat: lat, lon: lon)
            let summary = WeatherSummary(response: response)
            
            temp = summary.temperature
            tempMin = summary.tempMin
            tempMax = summary.tempMax
            conditionText = summary.description
        } catch {
            errorMessage = "Error obteniendo datos del clima"
            print("Weather error: \(error)")
        }
        
        isLoading = false
    }
}

private struct WeatherSummary {
    let temperature: Double
    let tempMin: Double
    let tempMax: Double
    let description: String
    
    init(response: WeatherResponse) {
        temperature = response.main.temp
        tempMin = response.main.tempMin
        tempMax = response.main.tempMax
        description = response.weather.first?.description.capitalized ?? "-"
    }
}
