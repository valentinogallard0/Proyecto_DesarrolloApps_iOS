//
//  ProfileView.swift
//  EvidenciaReportes
//
//  Created by Codex on 30/11/25.
//

import SwiftUI

struct ProfileView: View {
    private let badges = [
        ("checkmark.seal.fill", "Colaborador", Color.green),
        ("star.fill", "Top 5 reportes", Color.yellow),
        ("bolt.heart.fill", "Impacto ambiental", Color.pink)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                stats
                badgesSection
                actions
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 84, height: 84)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            Text("Valentino De Paola")
                .font(.title3.weight(.semibold))
            Text("Ciudadano activo · Monterrey")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 6)
        )
    }
    
    private var stats: some View {
        HStack(spacing: 16) {
            statTile(value: "12", label: "Reportes")
            statTile(value: "4", label: "Resueltos")
            statTile(value: "86%", label: "Impacto")
        }
    }
    
    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.bold())
            Text(label.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 3)
        )
    }
    
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reconocimientos")
                .font(.headline)
            ForEach(badges, id: \.0) { badge in
                HStack(spacing: 12) {
                    Image(systemName: badge.0)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(badge.2, in: RoundedRectangle(cornerRadius: 10))
                    Text(badge.1)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
                )
            }
        }
    }
    
    private var actions: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                Label("Ver mis reportes", systemImage: "doc.text.magnifyingglass")
            }
            .buttonStyle(ProfileButtonStyle(themeColor: .blue))
            
            Button(action: {}) {
                Label("Editar información", systemImage: "pencil")
            }
            .buttonStyle(ProfileButtonStyle(themeColor: .gray))
        }
    }
}

private struct ProfileButtonStyle: ButtonStyle {
    let themeColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(themeColor.opacity(configuration.isPressed ? 0.2 : 0.15))
            )
            .foregroundColor(themeColor)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
