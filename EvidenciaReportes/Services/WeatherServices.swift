//
//  WeatherServices.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 25/11/25.
//
import Foundation

struct WeatherService {
    
    private var apiKey: String = "222a368951ac4a0f72962ac0168cc4a7"
    
    func fetchAirQuality(lat: Double, lon: Double) async throws -> AirQualityResponse {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/air_pollution"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let airResponse = try decoder.decode(AirQualityResponse.self, from: data)
        return airResponse
    }
}
