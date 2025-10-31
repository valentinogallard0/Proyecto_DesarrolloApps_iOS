//
//  AutoridadesView.swift
//  EvidenciaReportes
//
//  Created by Alumno on 11/09/25.
//
//
//  AutoridadesView.swift
//  EvidenciaReportes
//
//  Creado como ejemplo de vista gubernamental
//

// MARK: - ReportStatus.swift (NUEVO)
import SwiftUI
import MapKit

struct AutoridadesView: View {
    @EnvironmentObject private var store: ReportsStore
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var filter: ReportStatus? = nil
    @State private var selectedReportID: UUID? = nil
    
    private var filtered: [Report] {
        guard let f = filter else { return store.reports }
        return store.reports.filter { $0.status == f }
    }
    
    private var mapSection: some View {
        ZStack {
            Map(initialPosition: .region(region)) {
                ForEach(filtered) { report in
                    if let coord = report.coordinate {
                        Annotation("", coordinate: coord) {
                            Button {
                                if selectedReportID == report.id {
                                    selectedReportID = nil
                                } else {
                                    selectedReportID = report.id
                                }
                            } label: {
                                ReportAnnotationView(report: report, showsTitle: selectedReportID == report.id)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                filterChip(title: "Todos", isActive: filter == nil, color: .blue) {
                    filter = nil
                }
                
                ForEach(ReportStatus.allCases) { estado in
                    filterChip(title: estado.rawValue, isActive: filter == estado, color: estado.color) {
                        filter = estado
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
        }
    }
    
    private var reportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reportes")
                .font(.headline)
                .padding(.horizontal, 4)
            
            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No hay reportes con este filtro.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .cardStyle()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filtered) { report in
                        reportCard(for: report)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func filterChip(title: String, isActive: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isActive ? color : Color.gray.opacity(0.25), in: Capsule())
                .foregroundStyle(isActive ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
    
    private func reportCard(for report: Report) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(report.status.color)
                    .frame(width: 14, height: 14)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.headline)
                    Text(DateUtils.relativeString(for: report.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(report.status.rawValue)
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(report.status.color.opacity(0.15), in: Capsule())
                    .foregroundStyle(report.status.color)
            }
            
            if let address = report.address, !address.isEmpty {
                Label(address, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !report.subtitle.isEmpty {
                Text(report.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Spacer()
                Menu {
                    Button("Marcar en proceso") { /* actualizar estado -> .inProgress */ }
                    Button("Marcar reparado") { /* actualizar estado -> .resolved */ }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                mapSection
                filterSection
                reportsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Panel de Autoridades")
    }
}

#Preview {
    AutoridadesView()
        .environmentObject(ReportsStore())
}
