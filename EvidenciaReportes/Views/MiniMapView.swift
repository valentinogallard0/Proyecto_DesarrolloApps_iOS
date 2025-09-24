//
//  MiniMapView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 23/09/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MiniMapView: View {
    let center: CLLocationCoordinate2D
    let reports: [Report]
    var onTap: (() -> Void)? = nil
    
    @State private var region: MKCoordinateRegion
    
    init(center: CLLocationCoordinate2D, reports: [Report], onTap: (() -> Void)? = nil) {
        self.center = center
        self.reports = reports
        self.onTap = onTap
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        ))
    }
    
    private var reportsWithCoords: [Report] {
        reports.filter { $0.coordinate != nil }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // ✅ Igual que arriba: annotationItems + MapAnnotation
            Map(coordinateRegion: $region,
                annotationItems: reportsWithCoords
            ) { report in
                MapAnnotation(coordinate: report.coordinate!) {
                    ReportAnnotationView(report: report, showsTitle: false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Button {
                onTap?()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "map")
                    Text("Ver en Mapa")
                }
                .font(.subheadline)
                .padding(10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(10)
            }
        }
        .frame(height: 160)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

