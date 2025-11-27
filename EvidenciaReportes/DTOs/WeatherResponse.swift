//
//  WeatherResponse.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 26/11/25.
//
import Foundation

struct WeatherResponse: Decodable {
    let coord: Coord
    let weather: [WeatherCondition]
    let main: WeatherMain
    let name: String
}

struct WeatherCondition: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct WeatherMain: Decodable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    private enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}
