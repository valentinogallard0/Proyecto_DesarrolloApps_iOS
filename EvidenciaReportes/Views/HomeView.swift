//
//  HomeView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//
import SwiftUI
import CoreLocation
import MapKit

// MARK: - Models

// MARK: - ViewModel (Mock Data)

// MARK: - Main Screen
struct HomeView: View {
    @EnvironmentObject private var store: ReportsStore
    @StateObject private var vm = HomeViewModel()
    @State private var selectedType: ReportType? = nil
    @State private var goToMap = false
    @State private var showAllReportsSheet = false
    @State private var selectedReport: Report? = nil
    
    private var recentFromStore: [Report] {
        Array(
            store.reports
                .sorted(by: { $0.date > $1.date })
                .prefix(5)
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    aqiCard
                    quickActions
                    mapPreview
                    recentSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) { titleBar }
            }
            .sheet(item: $selectedType, onDismiss: { selectedType = nil }) { type in
                let center = vm.userLocation ?? CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161)
                AddReportView(center: center, initialType: type) { newReport in
                    store.reports.append(newReport)
                }
            }
            .sheet(isPresented: $showAllReportsSheet) {
                AllReportsSheet(reports: store.reports)
            }
            .sheet(item: $selectedReport) { report in
                ReportDetailView(report: report)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var titleBar: some View {
        HStack(spacing: 8) {
            Text("Ciudad Activa")
                .font(.headline)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Monterrey, NL", systemImage: "mappin.and.ellipse")
                    .font(.title.weight(.heavy))
                    
                Spacer()

            }
            Text("Reporta. Participa. Respira mejor.")
                .font(.subheadline)

        }
    }
    
    private var aqiCard: some View {
        Group {
            if let aqi = vm.aqi {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(aqi.color.opacity(0.15))
                        Text("\(aqi.aqi)")
                            .font(.title2).bold()
                            .foregroundStyle(aqi.color)
                    }
                    .frame(width: 64, height: 64)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Calidad del aire")
                            .font(.headline)
                        HStack {
                            Text(aqi.label).bold().foregroundStyle(aqi.color)
                            Text("•")
                            Text(aqi.advice).foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                    Spacer()
                    Button {
                        // Acción: ver detalle AQI
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
            } else {
                ProgressView("Obteniendo calidad del aire…")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Crear reporte")
                .font(.headline)
            HStack(spacing: 12) {
                ForEach(ReportType.allCases) { type in
                    Button {
                        selectedType = type
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.title2)
                            Text(type.rawValue)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(type.color.opacity(0.15))
                        )
                        .foregroundStyle(type.color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // 🔁 REEMPLAZADO: ahora es un minimapa real
    private var mapPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cerca de ti")
                .font(.headline)
            
            let center = vm.userLocation ?? CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161)
            
            NavigationLink(isActive: $goToMap) {
                MapReportsView(reports: $store.reports)
            } label: {
                MiniMapView(center: center, reports: store.reports) {
                    goToMap = true
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recientes")
                    .font(.headline)
                Spacer()
                Button("Ver todo") {
                    showAllReportsSheet = true
                }
                .font(.subheadline)
            }
            
            VStack(spacing: 10) {
                ForEach(recentFromStore) { report in
                    Button {
                        #if os(iOS)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        #endif
                        selectedReport = report
                    } label: {
                        DetailedReportView(report: report)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}


// MARK: - Components
struct DetailedReportView: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Icon + Title + Date
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(report.type.color.opacity(0.15))
                    Image(systemName: report.type.icon)
                        .foregroundStyle(report.type.color)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(report.title)
                            .font(.headline)
                            .lineLimit(2)
                        Spacer()
                        Text(dateString(report.date))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    if !report.subtitle.isEmpty {
                        Text(report.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // Media thumbnail if available
            // TODO: Add thumbnail rendering when Report provides an image source, e.g. `imageData`, `photo`, or `attachments`.
            // Example implementation when you have `imageData`:
            // if let data = report.imageData, let uiImage = UIImage(data: data) {
            //     Image(uiImage: uiImage)
            //         .resizable()
            //         .scaledToFill()
            //         .frame(height: 160)
            //         .clipped()
            //         .cornerRadius(12)
            // }

            // Meta info: type, location, coordinates
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Label(report.type.rawValue, systemImage: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let _ = report.coordinate {
                        Label("Con ubicación", systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if let coord = report.coordinate {
                    Text("Lat: \(coord.latitude, format: .number.precision(.fractionLength(5)))  •  Lon: \(coord.longitude, format: .number.precision(.fractionLength(5)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if let address = report.address, !address.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "location")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func dateString(_ date: Date) -> String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .short
        return df.localizedString(for: date, relativeTo: .now)
    }
}


// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack { HomeView() }
                .environmentObject(ReportsStore())
        }
    }
}

