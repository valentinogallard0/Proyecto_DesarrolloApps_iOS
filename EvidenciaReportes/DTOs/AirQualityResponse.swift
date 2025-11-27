//
//  AirQualityResponse.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 25/11/25.
//
import Foundation

struct AirQualityResponse: Decodable{
    let coord: Coord
    let list: [AirQualityEntry]
}

struct Coord: Decodable{
    let lon: Double
    let lat: Double
}

struct AirQualityEntry: Decodable{
    let main: AirQualityMain
    let components: AirQualityComponents
    let dt: Int
}

struct AirQualityMain: Decodable{
    let aqi: Int
}

struct AirQualityComponents: Decodable{
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
    let nh3: Double
}
