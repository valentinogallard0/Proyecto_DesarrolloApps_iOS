//
//  ReportRecord.swift
//  EvidenciaReportes
//
//  Created by Codex on 03/12/25.
//

import CoreLocation
import Foundation
import SwiftData

@Model
final class ReportRecord {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var title: String
    var subtitle: String
    var date: Date
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var statusRaw: String
    var imageData: Data?
    
    init(report: Report) {
        self.id = report.id
        self.typeRaw = report.type.rawValue
        self.title = report.title
        self.subtitle = report.subtitle
        self.date = report.date
        self.latitude = report.coordinate?.latitude
        self.longitude = report.coordinate?.longitude
        self.address = report.address
        self.statusRaw = report.status.rawValue
        self.imageData = report.imageData
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var reportType: ReportType {
        ReportType(rawValue: typeRaw) ?? .pothole
    }
    
    var reportStatus: ReportStatus {
        ReportStatus(rawValue: statusRaw) ?? .new
    }
}
