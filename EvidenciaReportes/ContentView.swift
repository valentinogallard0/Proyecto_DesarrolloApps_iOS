//
//  ContentView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ReportsStore
    @State private var showingSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if showingSplash {
            SplashView(isActive: $showingSplash)
        } else if !hasCompletedOnboarding {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        } else {
            TabView {
                NavigationStack { HomeView() }
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
                
                NavigationStack { MapReportsView(reports: $store.reports)}
                    .tabItem { Label("Mapa", systemImage: "map") }

                /*
                 NavigationStack { AutoridadesView() }
                     .tabItem { Label("Autoridades", systemImage: "shield.lefthalf.filled") }
                 */

                NavigationStack { ProfileView() }
                    .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
            }
        }
    }
}


#Preview {
    ContentView().environmentObject(ReportsStore())
}
