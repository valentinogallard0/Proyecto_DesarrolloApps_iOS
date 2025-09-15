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
enum ReportType: String, CaseIterable, Identifiable {
    case pothole = "Bache"
    case streetlight = "Luminaria"
    case waterLeak = "Fuga de agua"
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .pothole: return "exclamationmark.triangle"
        case .streetlight: return "lightbulb"
        case .waterLeak: return "drop"
        }
    }
    
    var color: Color {
        switch self {
        case .pothole: return .orange
        case .streetlight: return .yellow
        case .waterLeak: return .teal
        }
    }
}

struct Report: Identifiable {
    let id = UUID()
    let type: ReportType
    let title: String
    let subtitle: String
    let date: Date
    let coordinate: CLLocationCoordinate2D?
}

struct AQIReading {
    var aqi: Int
    var label: String
    var advice: String
    var color: Color
}

// MARK: - ViewModel (Mock Data)
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161)
    @Published var aqi: AQIReading? = AQIReading(aqi: 42, label: "Bueno", advice: "Aire en buen estado", color: .green)
    @Published var recentReports: [Report] = [
        Report(type: .pothole, title: "Bache grande", subtitle: "Av. Constitución #123", date: .now.addingTimeInterval(-3600), coordinate: nil),
        Report(type: .streetlight, title: "Luminaria fundida", subtitle: "Parque Fundidora", date: .now.addingTimeInterval(-7200), coordinate: nil),
        Report(type: .waterLeak, title: "Fuga visible", subtitle: "Col. Centro", date: .now.addingTimeInterval(-10800), coordinate: nil)
    ]
}

// MARK: - Main Screen
struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var selectedType: ReportType? = nil
    
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
            .toolbar { ToolbarItem(placement: .principal) { titleBar } }
        }
    }
    
    private var titleBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill").foregroundStyle(.green)
            Text("CiudadActiva")
                .font(.headline)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Monterrey, NL", systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    // Acción: abrir buscador / cambiar ubicación
                } label: {
                    Label("Cambiar", systemImage: "location.circle")
                }
                .buttonStyle(.bordered)
                .font(.subheadline)
            }
            Text("Reporta. Participa. Respira mejor.")
                .font(.title2).bold()
            Text("Comparte baches, luminarias y fugas con foto + ubicación. Consulta el aire en tiempo real.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
                    Button { selectedType = type } label: {
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
    
    private var mapPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cerca de ti")
                .font(.headline)
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [.blue.opacity(0.2), .green.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 160)
                // Placeholder del mapa. Sustituir con Map si quieres mapa real en esta fase.
                
                HStack(spacing: 6) {
                    Image(systemName: "map")
                    Text("Abrir mapa")
                }
                .font(.subheadline)
                .padding(10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(12)
            }
        }
    }
    
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recientes")
                    .font(.headline)
                Spacer()
                Button("Ver todo") {
                    // Acción: navegar a lista completa
                }
                .font(.subheadline)
            }
            
            VStack(spacing: 10) {
                ForEach(vm.recentReports) { report in
                    ReportRow(report: report)
                }
            }
        }
    }
}

// MARK: - Components
struct ReportRow: View {
    let report: Report
    var body: some View {
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
                    Text(dateString(report.date))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Text(report.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
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
            HomeView()
            HomeView().preferredColorScheme(.dark)
        }
    }
}
