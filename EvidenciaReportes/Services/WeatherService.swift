//
//  WeatherService.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 25/11/25.
//

import Foundation

struct WeatherService {
    
    private var apiKey: String = "222a368951ac4a0f72962ac0168cc4a7"
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "es")
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
        let weatherData = try decoder.decode(WeatherResponse.self, from: data)
        
        return weatherData
    }
}
