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
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        if showingSplash {
            SplashView(isActive: $showingSplash)
        } else if !hasCompletedOnboarding {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        } else {
            TabView(selection: $selectedTab) {
                NavigationStack { HomeView(openMapScreen: { selectedTab = .map }) }
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
                    .tag(Tab.home)
                
                NavigationStack { MapReportsView() }
                    .tabItem { Label("Mapa", systemImage: "map") }
                    .tag(Tab.map)

                /*
                 NavigationStack { AutoridadesView() }
                     .tabItem { Label("Autoridades", systemImage: "shield.lefthalf.filled") }
                 */

                NavigationStack { ProfileView() }
                    .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                    .tag(Tab.profile)
            }
        }
    }
}

extension ContentView {
    enum Tab: Hashable {
        case home
        case map
        case profile
    }
}


#Preview {
    ContentView()
        .environmentObject(ReportsStore(context: SwiftDataStack.shared.context))
        .modelContainer(SwiftDataStack.shared.container)
}
