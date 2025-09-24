//
//  AddReportView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 23/09/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddReportView: View {
    let center: CLLocationCoordinate2D
    var onSave: (Report) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var type: ReportType = .pothole
    @State private var titleText: String = ""
    @State private var subtitleText: String = ""
    @State private var status: ReportStatus = .new
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(ReportType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }
                Section("Detalle") {
                    TextField("Título", text: $titleText)
                    TextField("Ubicación (texto)", text: $subtitleText)
                }
                Section("Estado") {
                    Picker("Estado", selection: $status) {
                        ForEach(ReportStatus.allCases) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                }
                Section("Coordenadas") {
                    Text("Lat: \(center.latitude, specifier: "%.5f")  Lon: \(center.longitude, specifier: "%.5f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nuevo reporte")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let newReport = Report(
                            type: type,
                            title: titleText.isEmpty ? type.rawValue : titleText,
                            subtitle: subtitleText,
                            date: .now,
                            coordinate: center,
                            status: status
                        )
                        onSave(newReport)
                        dismiss()
                    }
                    .disabled(titleText.isEmpty && subtitleText.isEmpty)
                }
            }
        }
    }
}
