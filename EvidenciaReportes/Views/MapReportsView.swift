//
//  MapReportsView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 23/09/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct ReportCluster: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let reports: [Report]
}

struct MapReportsView: View {
    @EnvironmentObject private var store: ReportsStore
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var locationManager: LocationManager

    // Región inicial (Monterrey)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    
    @State private var showAdd = false
    @State private var selectedReport: Report? = nil
    @State private var selectedCluster: ReportCluster? = nil
    @State private var selectedType: ReportType? = nil
    @State private var clusters: [ReportCluster] = []
    @State private var clusterUpdateWorkItem: DispatchWorkItem?
    @State private var didCenterOnUser = false
    
    private let minDelta: CLLocationDegrees = 0.002
    private let maxDelta: CLLocationDegrees = 1.5
    private let zoomFactor: Double = 0.6 // cuanto acerca/aleja por toque
    private let clusterUpdateDelay: TimeInterval = 0.18
    
    private func zoom(_ inwards: Bool) {
        let factor = inwards ? zoomFactor : (1/zoomFactor)
        let newLat = max(min(region.span.latitudeDelta * factor, maxDelta), minDelta)
        let newLon = max(min(region.span.longitudeDelta * factor, maxDelta), minDelta)
        region.span = MKCoordinateSpan(latitudeDelta: newLat, longitudeDelta: newLon)
    }
    
    private var reports: [Report] { store.reports }
    
    private var filteredReports: [Report] {
        if let t = selectedType {
            return reports.filter { $0.type == t }
        }
        return reports
    }
    
    private func makeClusters(from reports: [Report], in region: MKCoordinateRegion) -> [ReportCluster] {
        let items = reports.compactMap { r -> (Report, CLLocationCoordinate2D)? in
            guard let c = r.coordinate else { return nil }
            return (r, c)
        }
        guard !items.isEmpty else { return [] }
        let bucket = max(region.span.latitudeDelta, region.span.longitudeDelta) / 20.0
        if bucket <= 0 {
            return items.map { (r, c) in
                ReportCluster(id: "\(r.id)", coordinate: c, reports: [r])
            }
        }
        var groups: [String: [(Report, CLLocationCoordinate2D)]] = [:]
        for (r, c) in items {
            let latKey = Int(floor(c.latitude / bucket))
            let lonKey = Int(floor(c.longitude / bucket))
            let key = "\(latKey)_\(lonKey)"
            groups[key, default: []].append((r, c))
        }
        return groups.map { (key, group) in
            let coords = group.map { $0.1 }
            let avgLat = coords.map { $0.latitude }.reduce(0, +) / Double(coords.count)
            let avgLon = coords.map { $0.longitude }.reduce(0, +) / Double(coords.count)
            return ReportCluster(
                id: key,
                coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon),
                reports: group.map { $0.0 }
            )
        }
    }
    
    private func regionThatFits(_ coords: [CLLocationCoordinate2D], padding: Double = 1.2) -> MKCoordinateRegion? {
        guard !coords.isEmpty else { return nil }
        if coords.count == 1, let c = coords.first {
            let span = MKCoordinateSpan(
                latitudeDelta: max(region.span.latitudeDelta * 0.5, minDelta),
                longitudeDelta: max(region.span.longitudeDelta * 0.5, minDelta)
            )
            return MKCoordinateRegion(center: c, span: span)
        }
        var minLat = coords.first!.latitude
        var maxLat = coords.first!.latitude
        var minLon = coords.first!.longitude
        var maxLon = coords.first!.longitude
        for c in coords.dropFirst() {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }
        let centerLat = (minLat + maxLat) / 2.0
        let centerLon = (minLon + maxLon) / 2.0
        var latDelta = (maxLat - minLat) * padding
        var lonDelta = (maxLon - minLon) * padding
        latDelta = max(min(latDelta, maxDelta), minDelta)
        lonDelta = max(min(lonDelta, maxDelta), minDelta)
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
    
    private func updateClusters() {
        clusters = makeClusters(from: filteredReports, in: region)
    }
    
    private func scheduleClusterUpdate() {
        clusterUpdateWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            updateClusters()
            clusterUpdateWorkItem = nil
        }
        clusterUpdateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + clusterUpdateDelay, execute: workItem)
    }
    
    private func centerOnUserIfNeeded(with coordinate: CLLocationCoordinate2D?) {
        guard let coordinate else { return }
        guard !didCenterOnUser else { return }
        didCenterOnUser = true
        withAnimation {
            region.center = coordinate
        }
    }
    
    private func centerOnUserLocation() {
        if let coordinate = locationManager.userLocation {
            withAnimation {
                region.center = coordinate
            }
        } else {
            locationManager.requestPermissionIfNeeded()
        }
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region,
                interactionModes: [.all],
                showsUserLocation: true,
                annotationItems: clusters
            ) { cluster in
                MapAnnotation(coordinate: cluster.coordinate) {
                    if cluster.reports.count == 1, let report = cluster.reports.first {
                        Button(action: {
                            selectedReport = report
                            if let coord = report.coordinate {
                                withAnimation { region.center = coord }
                            }
                        }) {
                            ReportAnnotationView(report: report, showsTitle: false)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            selectedCluster = cluster
                            let coords = cluster.reports.compactMap { $0.coordinate }
                            if let fit = regionThatFits(coords, padding: 1.3) {
                                withAnimation { region = fit }
                            } else {
                                withAnimation { region.center = cluster.coordinate }
                            }
                        }) {
                            ClusterAnnotationView(count: cluster.reports.count)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea()
            
            VStack {
                // Top filter chips
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Todos", isSelected: selectedType == nil, color: .blue) {
                                selectedType = nil
                            }
                            ForEach(ReportType.allCases) { type in
                                FilterChip(title: type.rawValue, isSelected: selectedType == type, color: type.color) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal)
                
                Spacer()
                
                // Bottom-right zoom controls
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())

                        Button(action: { showAdd = true }) {
                            Image(systemName: "plus")
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())
                        Button(action: { zoom(true) }) {
                            Image(systemName: "plus.magnifyingglass")
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())
                        
                        Button(action: { zoom(false) }) {
                            Image(systemName: "minus.magnifyingglass")
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                        }
                        .background(.thinMaterial, in: Circle())
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateClusters()
            centerOnUserIfNeeded(with: locationManager.userLocation)
        }
        .onChange(of: region.center) { _ in
            scheduleClusterUpdate()
        }
        .onChange(of: region.span.latitudeDelta) { _ in
            scheduleClusterUpdate()
        }
        .onChange(of: region.span.longitudeDelta) { _ in
            scheduleClusterUpdate()
        }
        .onChange(of: store.reports) { _ in
            updateClusters()
        }
        .onChange(of: selectedType) { _ in
            updateClusters()
        }
        .onChange(of: locationManager.userLocation) { coordinate in
            centerOnUserIfNeeded(with: coordinate)
        }
        .sheet(isPresented: $showAdd) {
            AddReportView(center: region.center) { newReport in
                store.add(newReport)
            }
        }
        .sheet(item: $selectedReport) { report in
            ReportDetailView(report: report)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedCluster) { cluster in
            ClusterReportsList(cluster: cluster)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct ClusterAnnotationView: View {
    let count: Int
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 30, height: 30)
                .shadow(color: Color.blue.opacity(0.25), radius: 3, x: 0, y: 1)
            Circle()
                .stroke(.white, lineWidth: 2)
                .frame(width: 30, height: 30)
            Text("\(count)")
                .font(.caption2).bold()
                .foregroundStyle(.white)
        }
    }
}

private struct ClusterReportsList: View {
    let cluster: ReportCluster
    @Environment(\.dismiss) private var dismiss
    
    private var sortedReports: [Report] {
        cluster.reports.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            List(sortedReports) { report in
                NavigationLink {
                    ReportDetailView(report: report)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(report.type.color.opacity(0.15))
                            Image(systemName: report.type.icon)
                                .foregroundStyle(report.type.color)
                        }
                        .frame(width: 44, height: 44)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(report.title).bold()
                                Spacer()
                                Text(relative(report.date))
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            if !report.subtitle.isEmpty {
                                Text(report.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            HStack {
                                Text(report.status.rawValue)
                                    .font(.caption).bold()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(report.status.color.opacity(0.15), in: Capsule())
                                    .foregroundStyle(report.status.color)
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Reportes en esta zona")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
    
    private func relative(_ date: Date) -> String {
        return DateUtils.relativeString(for: date)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.secondary.opacity(0.15), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MapReportsView()
    }
    .environmentObject(ReportsStore(context: SwiftDataStack.shared.context))
    .environmentObject(LocationManager())
    .modelContainer(SwiftDataStack.shared.container)
}
