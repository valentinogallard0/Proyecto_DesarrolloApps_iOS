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
    @Published var recentReports: [Report] = [
        Report(type: .pothole, title: "Bache grande", subtitle: "Av. Constitución #123", date: .now.addingTimeInterval(-3600), coordinate: nil),
        Report(type: .streetlight, title: "Luminaria fundida", subtitle: "Parque Fundidora", date: .now.addingTimeInterval(-7200), coordinate: nil),
        Report(type: .waterLeak, title: "Fuga visible", subtitle: "Col. Centro", date: .now.addingTimeInterval(-10800), coordinate: nil)
    ]
}
