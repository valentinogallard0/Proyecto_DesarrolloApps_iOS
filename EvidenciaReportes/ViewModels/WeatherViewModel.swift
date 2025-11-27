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
    @Published var iconName: String = "sun.max.fill"
    
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
            iconName = summary.symbolName
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
    let symbolName: String
    
    init(response: WeatherResponse) {
        temperature = response.main.temp
        tempMin = response.main.tempMin
        tempMax = response.main.tempMax
        description = response.weather.first?.description.capitalized ?? "-"
        symbolName = WeatherSummary.symbolName(for: response.weather.first?.main)
    }
    
    private static func symbolName(for condition: String?) -> String {
        guard let condition else { return "sun.max.fill" }
        switch condition.lowercased() {
        case "clouds": return "cloud.fill"
        case "rain": return "cloud.rain.fill"
        case "drizzle": return "cloud.drizzle.fill"
        case "thunderstorm": return "cloud.bolt.rain.fill"
        case "snow": return "cloud.snow.fill"
        case "mist", "fog", "haze": return "cloud.fog.fill"
        default: return "sun.max.fill"
        }
    }
}
