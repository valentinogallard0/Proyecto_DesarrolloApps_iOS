//
//  ProfileSettingsView.swift
//  EvidenciaReportes
//
//  Created by Codex on 30/11/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @AppStorage("profile_notifications_enabled") private var notificationsEnabled = true
    @AppStorage("profile_updates_enabled") private var updatesEnabled = true
    @AppStorage("profile_share_stats") private var shareStats = true
    
    var body: some View {
        Form {
            Section(header: Text("Notificaciones")) {
                Toggle("Avisarme cuando cambie el estado", isOn: $notificationsEnabled)
                Toggle("Resúmenes semanales", isOn: $updatesEnabled)
            }
            
            Section(header: Text("Privacidad")) {
                Toggle("Compartir impacto con la comunidad", isOn: $shareStats)
                Text("Puedes cambiar estas preferencias en cualquier momento. Tus datos personales se mantienen privados.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Preferencias")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProfileSettingsView()
    }
}
