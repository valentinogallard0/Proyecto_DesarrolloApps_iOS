//
//  EnvironmentDetailView.swift
//  EvidenciaReportes
//
//  Created by Codex on 28/11/25.
//

import SwiftUI

struct EnvironmentDetailView: View {
    @ObservedObject var weatherVM: WeatherViewModel
    @ObservedObject var airQualityVM: AirQualityViewModel
    
    var body: some View {
        ZStack {
            weatherBackgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    infoPanel
                }
                .padding(24)
            }
        }
        .navigationTitle("Clima y aire")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monterrey, NL")
                        .font(.title2.weight(.semibold))
                    Text("Clima actual")
                        .font(.footnote)
                        .textCase(.uppercase)
                        .opacity(0.8)
                }
                Spacer()
                Image(systemName: weatherVM.iconName)
                    .font(.system(size: 54, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
                    .shadow(color: Color.black.opacity(0.25), radius: 12, y: 6)
            }
            
            if weatherVM.isLoading {
                ProgressView("Actualizando clima…")
                    .tint(.white)
            } else if let error = weatherVM.errorMessage {
                Text(error)
                    .font(.body.weight(.semibold))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(weatherVM.temp.rounded()))°C")
                        .font(.system(size: 84, weight: .heavy, design: .rounded))
                        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
                    Text(weatherVM.conditionText == "-" ? "Clima no disponible" : weatherVM.conditionText)
                        .font(.title3.weight(.medium))
                        .opacity(0.85)
                }
            }
            
            HStack(spacing: 12) {
                metricBubble(title: "Mín.", value: "\(Int(weatherVM.tempMin.rounded()))°C")
                metricBubble(title: "Máx.", value: "\(Int(weatherVM.tempMax.rounded()))°C")
                metricBubble(title: "Sensación", value: temperatureText)
            }
        }
        .foregroundColor(.white)
    }
    
    private var infoPanel: some View {
        VStack(spacing: 28) {
            climateSummary
            Divider().blendMode(.overlay)
            airQualitySection
            Divider().blendMode(.overlay)
            recommendationsSection
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var climateSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen de clima")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 16) {
                summaryTile(icon: "clock", title: "Actualizado", value: dateFormatter.string(from: Date()))
                summaryTile(icon: "wind", title: "Condición", value: weatherVM.conditionText == "-" ? "N/D" : weatherVM.conditionText)
            }
        }
    }
    
    private var airQualitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Calidad del aire", systemImage: "aqi.low")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.95))
                Spacer()
                Text(aqiStatusText)
                    .font(.caption.weight(.bold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(aqiColor.opacity(0.25))
                    .clipShape(Capsule())
            }
            
            if airQualityVM.isLoading {
                ProgressView("Actualizando aire…")
                    .tint(.white)
            } else if let error = airQualityVM.errorMessage {
                Text(error)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .lastTextBaseline, spacing: 16) {
                        Text(airQualityVM.aqiNumber == "-" ? "--" : airQualityVM.aqiNumber)
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(airQualityVM.aqiLevel == "-" ? "Sin datos" : airQualityVM.aqiLevel)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                            Text("Índice AQI")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    
                    AirProgressView(value: Double(aqiValue ?? 0) / 5.0, color: aqiColor)
                        .frame(height: 10)
                    
                    HStack(spacing: 16) {
                        pollutantTag(title: "PM2.5", value: airQualityVM.pm25Text)
                        pollutantTag(title: "PM10", value: airQualityVM.pm10Text)
                    }
                }
            }
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Recomendaciones", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.white.opacity(0.95))
            Text(adviceText)
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    private func metricBubble(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private func summaryTile(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
            }
            .foregroundColor(.white.opacity(0.75))
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func pollutantTag(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.white.opacity(0.75))
            Text(value == "-" ? "Sin datos" : value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private var temperatureText: String {
        if weatherVM.isLoading || weatherVM.errorMessage != nil {
            return "--°C"
        }
        return "\(Int(weatherVM.temp.rounded()))°C"
    }
    
    private var aqiValue: Int? {
        Int(airQualityVM.aqiNumber)
    }
    
    private var aqiStatusText: String {
        guard let value = aqiValue else { return "Sin datos" }
        return "Nivel \(value)/5"
    }
    
    private var adviceText: String {
        guard let value = aqiValue else {
            return "Aún no contamos con datos para generar recomendaciones precisas. Intenta recargar en unos minutos."
        }
        switch value {
        case 1:
            return "La calidad del aire es óptima. Disfruta actividades al aire libre sin restricciones."
        case 2:
            return "La calidad es aceptable. Personas sensibles pueden considerar reducir actividades intensas prolongadas."
        case 3:
            return "Se recomienda limitar el tiempo prolongado al aire libre y mantener ventanas cerradas si es posible."
        case 4:
            return "Evita actividades físicas intensas afuera. Usa cubrebocas si presentas molestias respiratorias."
        default:
            return "La calidad del aire es muy mala. Procura permanecer en interiores y utiliza purificadores o mascarillas."
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm 'hrs'"
        return formatter
    }
    
    private var weatherBackgroundGradient: LinearGradient {
        let palette: [Color]
        switch weatherVM.iconName {
        case "sun.max.fill":
            palette = [Color.orange, Color.red.opacity(0.9)]
        case "cloud.fill", "cloud.drizzle.fill", "cloud.rain.fill", "cloud.fog.fill":
            palette = [Color.blue.opacity(0.6), Color.indigo]
        case "cloud.bolt.rain.fill":
            palette = [Color.indigo, Color.purple]
        default:
            palette = [Color.cyan.opacity(0.8), Color.blue]
        }
        return LinearGradient(colors: palette, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var aqiColor: Color {
        guard let value = aqiValue else { return .gray }
        switch value {
        case 1: return .green
        case 2: return .yellow
        case 3: return .orange
        case 4: return .red
        default: return .purple
        }
    }
}

private struct AirProgressView: View {
    let value: Double
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.18))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, min(CGFloat(value), 1.0)) * proxy.size.width)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: value)
    }
}

#Preview {
    NavigationStack {
        EnvironmentDetailView(
            weatherVM: WeatherViewModel(),
            airQualityVM: AirQualityViewModel()
        )
    }
}
