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

import SwiftUI
import MapKit

// Modelo extendido de reporte
struct Reporte: Identifiable {
    let id = UUID()
    var descripcion: String
    var estado: EstadoReporte
    var ubicacion: CLLocationCoordinate2D
    var fecha: Date
}

enum EstadoReporte: String, CaseIterable {
    case pendiente = "Pendiente"
    case enProceso = "En Proceso"
    case reparado = "Reparado"
    
    var color: Color {
        switch self {
        case .pendiente: return .red
        case .enProceso: return .orange
        case .reparado: return .green
        }
    }
}

// Datos de prueba
let reportesPrueba: [Reporte] = [
    Reporte(descripcion: "Bache profundo en Av. Reforma", estado: .pendiente,
            ubicacion: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
            fecha: Date()),
    Reporte(descripcion: "Bache pequeño en Insurgentes", estado: .enProceso,
            ubicacion: CLLocationCoordinate2D(latitude: 19.435, longitude: -99.14),
            fecha: Date().addingTimeInterval(-3600)),
    Reporte(descripcion: "Reparado en Col. Roma", estado: .reparado,
            ubicacion: CLLocationCoordinate2D(latitude: 19.44, longitude: -99.135),
            fecha: Date().addingTimeInterval(-7200))
]

struct AutoridadesView: View {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var filtro: EstadoReporte? = nil
    
    var reportesFiltrados: [Reporte] {
        if let filtro = filtro {
            return reportesPrueba.filter { $0.estado == filtro }
        }
        return reportesPrueba
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                
                // 🗺️ Mapa con anotaciones
                Map(initialPosition: .region(region)) {
                    ForEach(reportesFiltrados) { reporte in
                        Annotation(reporte.descripcion, coordinate: reporte.ubicacion) {
                            VStack {
                                Circle()
                                    .fill(reporte.estado.color)
                                    .frame(width: 28, height: 28)
                                Text(reporte.estado.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(reporte.estado.color.opacity(0.8))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .frame(height: 280)
                .cornerRadius(20)
                .shadow(radius: 6)
                .padding(.horizontal)
                
                // 📊 Filtros por estado
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button("Todos") {
                            filtro = nil
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(filtro == nil ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        ForEach(EstadoReporte.allCases, id: \.self) { estado in
                            Button(estado.rawValue) {
                                filtro = estado
                            }
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(filtro == estado ? estado.color : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 📋 Lista de reportes
                List(reportesFiltrados) { reporte in
                    HStack {
                        Circle()
                            .fill(reporte.estado.color)
                            .frame(width: 14, height: 14)
                        VStack(alignment: .leading) {
                            Text(reporte.descripcion)
                                .font(.headline)
                            Text(reporte.fecha, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // Botones de acción rápida
                        Menu {
                            Button("Marcar en proceso") { /* acción */ }
                            Button("Marcar reparado") { /* acción */ }
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
