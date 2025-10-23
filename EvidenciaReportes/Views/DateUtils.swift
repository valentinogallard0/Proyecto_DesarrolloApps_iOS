// Utilidad centralizada para formateo de fechas relativas
//  EvidenciaReportes
//  Creado para la refactorización

import Foundation

struct DateUtils {
    static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    static func relativeString(for date: Date, relativeTo reference: Date = .now) -> String {
        return relativeFormatter.localizedString(for: date, relativeTo: reference)
    }
}
