//
//  ContentView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            NavigationStack { AutoridadesView() }
                .tabItem { Label("Autoridades", systemImage: "shield.lefthalf.filled") }

            NavigationStack { Text("Perfil (próximamente)") }
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
        }
    }
}


#Preview {
    ContentView()
}
