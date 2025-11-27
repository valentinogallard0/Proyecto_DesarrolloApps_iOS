//
//  HomeView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//
import SwiftUI
import CoreLocation
import MapKit


// MARK: - Main Screen
struct HomeView: View {
    @EnvironmentObject private var store: ReportsStore
    @StateObject private var vm = HomeViewModel()
    @StateObject private var airQualityVM = AirQualityViewModel()
    @StateObject private var weatherVM = WeatherViewModel()
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
                    store.add(newReport)
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
            .task {
                await airQualityVM.loadForMonterrey()
                await weatherVM.loadWeather()
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
            HStack(alignment: .top) {
                Label("Monterrey, NL", systemImage: "mappin.and.ellipse")
                    .font(.title.weight(.heavy))
                Spacer()
                temperatureBadge
            }
            Text("Reporta. Participa. Respira mejor.")
                .font(.subheadline)

        }
    }
    
    private var aqiCard: some View {
        let gradient = aqiGradient(for: airQualityValue)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calidad del aire")
                        .font(.headline)
                        .textCase(.uppercase)
                        .opacity(0.85)
                    Text(airQualityVM.aqiLevel == "-" ? "Sin datos" : airQualityVM.aqiLevel)
                        .font(.title3.weight(.semibold))
                }
                Spacer()
                Image(systemName: "aqi.low")
                    .font(.system(size: 30, weight: .bold))
                    .opacity(0.85)
            }
            
            if airQualityVM.isLoading {
                ProgressView("Actualizando datos…")
                    .tint(.white)
            } else if let error = airQualityVM.errorMessage {
                Text(error)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            } else {
                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text(airQualityVM.aqiNumber == "-" ? "--" : airQualityVM.aqiNumber)
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Índice AQI")
                            .font(.caption)
                            .opacity(0.8)
                        Text("Monterrey Centro")
                            .font(.footnote)
                            .opacity(0.8)
                    }
                    Spacer()
                    Spacer()
                    if let value = airQualityValue {
                        metricChip(text: "Nivel \(value)/5")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(
            gradient
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
        .foregroundColor(.white)
        .shadow(color: Color.black.opacity(0.12), radius: 10, y: 6)
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
                        ReportCardView(report: report, showStatus: false, showDate: true)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var airQualityValue: Int? {
        guard let value = Int(airQualityVM.aqiNumber) else { return nil }
        return value
    }
    
    private func aqiGradient(for value: Int?) -> LinearGradient {
        let colors: [Color]
        if let value, (1...5).contains(value) {
            let ratio = Double(value - 1) / 4.0
            let hue = max(0, 0.33 - (0.33 * ratio))
            let start = Color(hue: hue, saturation: 0.55, brightness: 0.9)
            let end = Color(hue: hue, saturation: 0.85, brightness: 0.7)
            colors = [start, end]
        } else {
            colors = [
                Color.gray.opacity(0.35),
                Color.gray.opacity(0.55)
            ]
        }
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func metricChip(text: String) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.18))
            .clipShape(Capsule(style: .continuous))
    }
    
    private var temperatureBadge: some View {
        ZStack {
            // Soft glass-like background for the badge
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
                )

            VStack(spacing: 0) {
                // Weather icon on top
                Image(systemName: weatherVM.iconName)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(iconColor(for: weatherVM.iconName))
                    .shadow(color: Color.black.opacity(0.12), radius: 6, y: 3)
                    .padding(.top, 8)
                    .padding(.bottom, -4) // slight overlap into the temperature

                // Temperature text slightly overlapping the icon area
                Text(temperatureText)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 12)
        }
        .fixedSize()
        .frame(width: 68, height: 64)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
    }
    
    private var temperatureText: String {
        if weatherVM.isLoading || weatherVM.errorMessage != nil {
            return "--°C"
        }
        let value = Int(weatherVM.temp.rounded())
        return "\(value)°C"
    }
    
    private var temperatureSubtitle: String {
        if weatherVM.isLoading {
            return "Actualizando..."
        }
        if weatherVM.errorMessage != nil {
            return "Sin datos"
        }
        let condition = weatherVM.conditionText
        return condition == "-" ? "Clima" : condition
    }
    
    private func iconColor(for iconName: String) -> Color {
        switch iconName {
        case "sun.max.fill": return .yellow
        case "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill", "cloud.snow.fill",
             "cloud.fog.fill", "cloud.bolt.rain.fill": return .gray
        default: return .blue
        }
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

