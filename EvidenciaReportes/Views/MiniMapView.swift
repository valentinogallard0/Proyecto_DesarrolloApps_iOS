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
    let userLocation: CLLocationCoordinate2D?
    var onTap: (() -> Void)? = nil
    
    @State private var region: MKCoordinateRegion
    
    init(center: CLLocationCoordinate2D, reports: [Report], userLocation: CLLocationCoordinate2D? = nil, onTap: (() -> Void)? = nil) {
        self.center = center
        self.reports = reports
        self.userLocation = userLocation
        self.onTap = onTap
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        ))
    }
    
    private var reportsWithCoords: [Report] {
        reports.filter { $0.coordinate != nil }
    }
    
    private var annotations: [MiniMapAnnotation] {
        var items = reportsWithCoords.map {
            MiniMapAnnotation(id: $0.id.uuidString, coordinate: $0.coordinate!, kind: .report($0))
        }
        if let userLocation {
            items.append(MiniMapAnnotation(id: "user-location", coordinate: userLocation, kind: .user))
        }
        return items
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $region,
                annotationItems: annotations
            ) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    switch annotation.kind {
                    case .report(let report):
                        ReportAnnotationView(report: report, showsTitle: false)
                    case .user:
                        Circle()
                            .fill(Color.blue.opacity(0.25))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 12, height: 12)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 18, height: 18)
                            )
                    }
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

private struct MiniMapAnnotation: Identifiable {
    enum Kind {
        case report(Report)
        case user
    }
    
    let id: String
    let coordinate: CLLocationCoordinate2D
    let kind: Kind
}
