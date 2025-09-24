//
//  EvidenciaReportesApp.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//

import SwiftUI

@main
struct EvidenciaReportesApp: App {
    @StateObject private var reportsStore = ReportsStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reportsStore)
        }
    }
}
