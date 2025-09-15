//
//  ReportStatus.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 15/09/25.
//
import SwiftUI

enum ReportStatus: String, CaseIterable, Codable, Identifiable {
    case new = "Pendiente"
    case inProgress = "En Proceso"
    case resolved = "Reparado"
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .new: return .red
        case .inProgress: return .orange
        case .resolved: return .green
        }
    }
}
