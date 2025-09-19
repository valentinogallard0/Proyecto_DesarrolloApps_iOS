//
//  EvidenciaReportesApp.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//

import SwiftUI

@main
struct EvidenciaReportesApp: App {
    @StateObject private var session = SessionManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        Group {
            if session.isAuthenticated {
                ContentView() // Tabs condicionados por rol (ver siguiente sección)
            } else {
                LoginView(sessionManager: session)
            }
        }
        .animation(.easeInOut, value: session.isAuthenticated)
    }
}

