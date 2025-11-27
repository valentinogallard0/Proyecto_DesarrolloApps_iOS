//
//  AirQualitySummary.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 25/11/25.
//

struct AirQualitySummary {
    let aqiNumber: String
    let aqiLevel: String
    let pm25Text: String
    let pm10Text: String
    
    init?(from response: AirQualityResponse){
        guard let first = response.list.first else {return nil}
        
        let aqi = first.main.aqi
        
        aqiNumber = "\(aqi)"
        
        switch aqi {
        case 1: aqiLevel = "Buena"
        case 2: aqiLevel = "Aceptable"
        case 3: aqiLevel = "Moderado"
        case 4: aqiLevel = "Malo"
        case 5: aqiLevel = "Muy malo"
        default: aqiLevel = "Desconocido"
        }
        
        pm25Text = String(format: "PM2.5: %.1f µg/m³", first.components.pm2_5)
        pm10Text = String(format: "PM10: %.1f µg/m³", first.components.pm10)
    }
}
