//
//  Untitled.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 15/09/25.
//
import Foundation
import CoreLocation

//ocupamos aqui poner un Codable para guardar en UserDefaults, leer en JSON y enviar a servidor
struct Report: Identifiable {
    let id: UUID
    let type: ReportType
    let title: String
    let subtitle: String
    let date: Date
    let coordinate: CLLocationCoordinate2D?   // opcional para no romper HomeView
    var status: ReportStatus

    init(id: UUID = UUID(),
         type: ReportType,
         title: String,
         subtitle: String,
         date: Date,
         coordinate: CLLocationCoordinate2D? = nil,
         status: ReportStatus = .new) {
        self.id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.coordinate = coordinate
        self.status = status
    }
}

