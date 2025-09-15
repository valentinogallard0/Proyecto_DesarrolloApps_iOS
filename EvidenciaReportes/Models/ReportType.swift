//
//  ReportType.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 15/09/25.
//

import Foundation
import SwiftUI

enum ReportType: String, CaseIterable, Identifiable, Codable {
    case pothole = "Bache"
    case streetlight = "Luminaria"
    case waterLeak = "Fuga de agua"
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .pothole: return "exclamationmark.triangle"
        case .streetlight: return "lightbulb"
        case .waterLeak: return "drop"
        }
    }
    
    var color: Color {
        switch self {
        case .pothole: return .orange
        case .streetlight: return .yellow
        case .waterLeak: return .teal
        }
    }
}
