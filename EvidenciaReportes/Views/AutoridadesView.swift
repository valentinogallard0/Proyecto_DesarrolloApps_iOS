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
    
    private var filtered: [Report] {
        guard let f = filter else { return store.reports }
        return store.reports.filter { $0.status == f }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 🗺️ Mapa con anotaciones (usa color según ReportStatus)
                Map(initialPosition: .region(region)) {
                    ForEach(filtered) { report in
                        if let coord = report.coordinate {
                            Annotation(report.title, coordinate: coord) {
                                ReportAnnotationView(report: report, showsTitle: true)
                            }
                        }
                    }
                }
                .frame(height: 280)
                .cornerRadius(20)
                .shadow(radius: 6)
                .padding(.horizontal)
                
                // 📊 Filtros por estado (usa ReportStatus)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button("Todos") { filter = nil }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(filter == nil ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                        ForEach(ReportStatus.allCases) { estado in
                            Button(estado.rawValue) { filter = estado }
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .background(filter == estado ? estado.color : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 📋 Lista de reportes
                List(filtered) { report in
                    HStack {
                        Circle()
                            .fill(report.status.color)
                            .frame(width: 14, height: 14)
                        VStack(alignment: .leading) {
                            Text(report.title)
                                .font(.headline)
                            Text(report.date, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // Acciones rápidas (ejemplo; aquí después actualizarás el repo)
                        Menu {
                            Button("Marcar en proceso") { /* actualizar estado -> .inProgress */ }
                            Button("Marcar reparado") { /* actualizar estado -> .resolved */ }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Panel de Autoridades")
        }
    }
}

#Preview {
    AutoridadesView()
}

