//
//  Untitled.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 15/09/25.
//
import Foundation
import CoreLocation

struct Report: Identifiable, Equatable, Codable {
    let id: UUID
    let type: ReportType
    let title: String
    let subtitle: String
    let date: Date
    let coordinate: CLLocationCoordinate2D?   // opcional para no romper HomeView
    var address: String?
    var status: ReportStatus
    var imageData: Data?    // Foto opcional adjunta al reporte

    init(id: UUID = UUID(),
         type: ReportType,
         title: String,
         subtitle: String,
         date: Date,
         coordinate: CLLocationCoordinate2D? = nil,
         address: String? = nil,
         status: ReportStatus = .new,
         imageData: Data? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.coordinate = coordinate
        self.address = address
        self.status = status
        self.imageData = imageData
    }
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.date == rhs.date &&
        lhs.coordinate == rhs.coordinate &&
        lhs.address == rhs.address &&
        lhs.status == rhs.status &&
        lhs.imageData == rhs.imageData
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, type, title, subtitle, date, coordinate, address, status, imageData
    }
    
    private struct CoordinateWrapper: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(ReportType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        date = try container.decode(Date.self, forKey: .date)
        if let coordinateWrapper = try container.decodeIfPresent(CoordinateWrapper.self, forKey: .coordinate) {
            coordinate = CLLocationCoordinate2D(latitude: coordinateWrapper.latitude,
                                                longitude: coordinateWrapper.longitude)
        } else {
            coordinate = nil
        }
        address = try container.decodeIfPresent(String.self, forKey: .address)
        status = try container.decode(ReportStatus.self, forKey: .status)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(date, forKey: .date)
        if let coordinate {
            let wrapper = CoordinateWrapper(latitude: coordinate.latitude, longitude: coordinate.longitude)
            try container.encode(wrapper, forKey: .coordinate)
        }
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(imageData, forKey: .imageData)
    }
}

extension Report {
    init(record: ReportRecord) {
        var coordinate: CLLocationCoordinate2D? = nil
        if let latitude = record.latitude, let longitude = record.longitude {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        self.init(
            id: record.id,
            type: record.reportType,
            title: record.title,
            subtitle: record.subtitle,
            date: record.date,
            coordinate: coordinate,
            address: record.address,
            status: record.reportStatus,
            imageData: record.imageData
        )
    }
}
