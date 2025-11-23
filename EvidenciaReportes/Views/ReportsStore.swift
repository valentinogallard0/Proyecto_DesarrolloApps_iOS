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
    @Published var reports: [Report] = [] {
        didSet {
            guard !skipSave else { return }
            persistence.saveReports(reports)
        }
    }
    
    private let persistence: ReportsPersistence
    private var skipSave = false
    
    private static let sampleReports: [Report] = [
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
    
    init(persistence: ReportsPersistence = ReportsPersistence()) {
        self.persistence = persistence
        let storedReports = persistence.loadReports()
        skipSave = true
        if storedReports.isEmpty {
            reports = Self.sampleReports
        } else {
            reports = storedReports
        }
        skipSave = false
        
        if storedReports.isEmpty {
            persistence.saveReports(reports)
        }
    }
    
    func add(_ report: Report) {
        reports.append(report)
    }
}
