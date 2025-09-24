//
//  MapReportsView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 23/09/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapReportsView: View {
    @Binding var reports: [Report]
    @Environment(\.dismiss) private var dismiss

    // Región inicial (Monterrey)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    
    @State private var showAdd = false
    
    private let minDelta: CLLocationDegrees = 0.002
    private let maxDelta: CLLocationDegrees = 1.5
    private let zoomFactor: Double = 0.6 // cuanto acerca/aleja por toque
    
    private func zoom(_ inwards: Bool) {
        let factor = inwards ? zoomFactor : (1/zoomFactor)
        let newLat = max(min(region.span.latitudeDelta * factor, maxDelta), minDelta)
        let newLon = max(min(region.span.longitudeDelta * factor, maxDelta), minDelta)
        region.span = MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLon)
    }
    
    private var reportsWithCoords: [Report] {
        reports.filter { $0.coordinate != nil }
    }
    
    var body: some View {
        ZStack {
            // ✅ Usamos el overload con annotationItems + MapAnnotation (conforma a MapAnnotationProtocol)
            Map(coordinateRegion: $region,
                interactionModes: [.all],
                annotationItems: reportsWithCoords
            ) { report in
                MapAnnotation(coordinate: report.coordinate!) {
                    ReportAnnotationView(report: report, showsTitle: true)
                }
            }
            .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                // Bottom-right zoom controls
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: { showAdd = true }) {
                            Image(systemName: "plus")
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())
                        Button(action: { zoom(true) }) {
                            Image(systemName: "plus.magnifyingglass")
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())
                        
                        Button(action: { zoom(false) }) {
                            Image(systemName: "minus.magnifyingglass")
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)

        .sheet(isPresented: $showAdd) {
            AddReportView(center: region.center) { newReport in
                reports.append(newReport)
            }
        }
    }
}


#Preview {
    let store = ReportsStore()
    return NavigationStack {
        MapReportsView(reports: .constant(store.reports))
    }
}

