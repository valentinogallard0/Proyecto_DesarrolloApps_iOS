//
//  HomeViewModel.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 15/09/25.
//
import Foundation
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161)
    @Published var aqi: AQIReading? = AQIReading(aqi: 42, label: "Bueno", advice: "Aire en buen estado", color: .green)
}
