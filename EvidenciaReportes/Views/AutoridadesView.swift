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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var filter: ReportStatus? = nil
    
    // Datos de prueba usando el modelo unificado `Report`
    private var sampleReports: [Report] = [
        Report(type: .pothole, title: "Bache profundo en Av. Constitución", subtitle: "Mty Centro",
               date: .now.addingTimeInterval(-600),
               coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
               status: .new),
        Report(type: .pothole, title: "Bache pequeño en Insurgentes", subtitle: "Zona Valle",
               date: .now.addingTimeInterval(-3600),
               coordinate: CLLocationCoordinate2D(latitude: 25.66, longitude: -100.35),
               status: .inProgress),
        Report(type: .streetlight, title: "Luminaria reparada en Col. Roma", subtitle: "Calle Principal",
               date: .now.addingTimeInterval(-7200),
               coordinate: CLLocationCoordinate2D(latitude: 25.70, longitude: -100.30),
               status: .resolved)
    ]
    
    private var filtered: [Report] {
        guard let f = filter else { return sampleReports }
        return sampleReports.filter { $0.status == f }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 🗺️ Mapa con anotaciones (usa color según ReportStatus)
                Map(initialPosition: .region(region)) {
                    ForEach(filtered) { report in
                        if let coord = report.coordinate {
                            Annotation(report.title, coordinate: coord) {
                                VStack {
                                    Circle()
                                        .fill(report.status.color)
                                        .frame(width: 28, height: 28)
                                    Text(report.status.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(report.status.color.opacity(0.8))
                                        .cornerRadius(6)
                                }
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
