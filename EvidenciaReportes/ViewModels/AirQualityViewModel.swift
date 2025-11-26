//
//  AirQualityViewModel.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 25/11/25.
//

import Foundation

@MainActor
class AirQualityViewModel: ObservableObject{
    
    @Published var aqiNumber: String = "-"
    @Published var aqiLevel: String = "-"
    @Published var pm25Text: String = "-"
    @Published var pm10Text: String = "-"
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let service = WeatherService()
    
    func loadForMonterrey() async {
        isLoading = true
        errorMessage = nil
        
        do{
            let lat = 25.6866
            let lon = -100.3167
            
            // llamamos al servicio
            let response = try await service.fetchAirQuality(lat: lat, lon: lon)
            
            guard let summary = AirQualitySummary(from: response) else{
                errorMessage = "No se encontraron datos de calidad del aire"
                isLoading = false
                return
            }
            print(aqiNumber)
            aqiNumber = summary.aqiNumber
            aqiLevel = summary.aqiLevel
            pm25Text = summary.pm25Text
            pm10Text = summary.pm10Text
        } catch {
            errorMessage = "Error obteniendo calidad del aire"
            print("AirQuality Error: \(error)")
        }
        
        isLoading = false
    }
}
