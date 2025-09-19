//
//  ContentView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        let role = session.session?.role ?? .user  // default a user por si acaso

        TabView {
            if role == .user {
                // Pantallas de USUARIO
                NavigationStack { HomeView() }
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
            }

            if role == .admin {
                // Pantallas de ADMIN
                NavigationStack { AutoridadesView() }
                    .tabItem { Label("Autoridades", systemImage: "shield.lefthalf.filled") }
            }

            // En ambos casos: Perfil
            NavigationStack { ProfileView() }
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager())
}

