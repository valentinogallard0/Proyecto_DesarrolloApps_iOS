//
//  ReportsStore.swift
//  EvidenciaReportes
//
//  Created by Assistant on 24/09/25.
//

import Foundation
import CoreLocation
import SwiftUI

final class ReportsStore: ObservableObject {
    @Published var reports: [Report] = [
        Report(type: .pothole, title: "Bache grande", subtitle: "Av. Constitución #123",
               date: .now.addingTimeInterval(-3600),
               coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161), status: .inProgress ),
        Report(type: .streetlight, title: "Luminaria fundida", subtitle: "Parque Fundidora",
               date: .now.addingTimeInterval(-7200),
               coordinate: CLLocationCoordinate2D(latitude: 25.675, longitude: -100.285), status: .new),
        Report(type: .waterLeak, title: "Fuga visible", subtitle: "Col. Centro",
               date: .now.addingTimeInterval(-10800),
               coordinate: CLLocationCoordinate2D(latitude: 25.671, longitude: -100.309), status: .resolved)
    ]
}
