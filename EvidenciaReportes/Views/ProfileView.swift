//
//  ProfileView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 72))
                .padding(.top, 24)

            Text(session.session?.email ?? "Invitado")
                .font(.title2).bold()

            if let role = session.session?.role {
                Text(role == .admin ? "Rol: Administrador" : "Rol: Usuario")
                    .foregroundStyle(.secondary)
            }

            if let issued = session.session?.issuedAt {
                Text("Conectado desde: \(issued.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(role: .destructive) {
                session.clear()
            } label: {
                Text("Salir")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer(minLength: 20)
        }
        .padding()
        .navigationTitle("Perfil")
    }
}
