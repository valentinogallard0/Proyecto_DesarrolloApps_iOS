//
//  ProfileView.swift
//  EvidenciaReportes
//
//  Created by Codex on 30/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: ReportsStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showReportsSheet = false
    @State private var selectedReport: Report?
    
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
                recentReportsSection
                badgesSection
                actions
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReportsSheet) {
            AllReportsSheet(reports: store.reports)
        }
        .sheet(item: $selectedReport) { report in
            ReportDetailView(report: report)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
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
                .fill(.regularMaterial)
                .shadow(color: largeCardShadow, radius: 8, y: 6)
        )
    }
    
    private var stats: some View {
        HStack(spacing: 16) {
            statTile(value: "\(totalReports)", label: "Reportes")
            statTile(value: "\(resolvedReports)", label: "Resueltos")
            statTile(value: resolutionRateText, label: "Impacto")
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
                .fill(.regularMaterial)
                .shadow(color: smallCardShadow, radius: 4, y: 3)
        )
    }
    
    private var recentReportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Últimos reportes")
                    .font(.headline)
                Spacer()
                if !store.reports.isEmpty {
                    Button("Ver todo") { showReportsSheet = true }
                        .font(.subheadline)
                }
            }
            
            if recentReports.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("Aún no has creado reportes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: smallCardShadow, radius: 4, y: 2)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(recentReports) { report in
                        Button {
                            selectedReport = report
                        } label: {
                            ReportCardView(report: report, showStatus: true, showDate: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
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
                        .fill(.regularMaterial)
                        .shadow(color: smallCardShadow, radius: 4, y: 2)
                )
            }
        }
    }
    
    private var actions: some View {
        VStack(spacing: 12) {
            Button(action: { showReportsSheet = true }) {
                Label("Ver mis reportes", systemImage: "doc.text.magnifyingglass")
            }
            .buttonStyle(ProfileButtonStyle(themeColor: .blue))
            
            NavigationLink {
                ProfileSettingsView()
            } label: {
                Label("Preferencias", systemImage: "slider.horizontal.3")
            }
            .buttonStyle(ProfileButtonStyle(themeColor: .gray))
        }
    }
    
    private var totalReports: Int {
        store.reports.count
    }
    
    private var resolvedReports: Int {
        store.reports.filter { $0.status == .resolved }.count
    }
    
    private var resolutionRateText: String {
        guard totalReports > 0 else { return "0%" }
        let rate = Double(resolvedReports) / Double(totalReports)
        return "\(Int(rate * 100))%"
    }
    
    private var recentReports: [Report] {
        Array(store.reports.sorted(by: { $0.date > $1.date }).prefix(3))
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
                    .fill(themeColor.opacity(configuration.isPressed ? 0.22 : 0.18))
            )
            .foregroundStyle(.primary)
            .tint(themeColor)
    }
}

private extension ProfileView {
    var largeCardShadow: Color {
        Color.black.opacity(colorScheme == .dark ? 0.45 : 0.08)
    }
    
    var smallCardShadow: Color {
        Color.black.opacity(colorScheme == .dark ? 0.35 : 0.05)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environmentObject(ReportsStore(context: SwiftDataStack.shared.context))
    .modelContainer(SwiftDataStack.shared.container)
}
