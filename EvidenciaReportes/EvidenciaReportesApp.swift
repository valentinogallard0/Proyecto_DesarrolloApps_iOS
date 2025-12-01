//
//  EvidenciaReportesApp.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//

import SwiftUI
import SwiftData

@main
struct EvidenciaReportesApp: App {
    private let dataStack: SwiftDataStack
    @StateObject private var reportsStore: ReportsStore
    @StateObject private var locationManager = LocationManager()
    
    init() {
        let stack = SwiftDataStack.shared
        self.dataStack = stack
        _reportsStore = StateObject(wrappedValue: ReportsStore(context: stack.context))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reportsStore)
                .environmentObject(locationManager)
                .modelContainer(dataStack.container)
        }
    }
}
