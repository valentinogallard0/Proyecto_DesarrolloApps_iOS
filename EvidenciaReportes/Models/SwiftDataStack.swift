//
//  SwiftDataStack.swift
//  EvidenciaReportes
//
//  Created by Codex on 03/12/25.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataStack {
    static let shared = SwiftDataStack()
    
    let container: ModelContainer
    
    private init() {
        do {
            container = try ModelContainer(for: ReportRecord.self)
        } catch {
            fatalError("No se pudo crear el contenedor de SwiftData: \(error)")
        }
    }
    
    var context: ModelContext {
        container.mainContext
    }
}
