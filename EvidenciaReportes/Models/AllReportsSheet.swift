import SwiftUI

struct AllReportsSheet: View {
    let reports: [Report]
    @Environment(\.dismiss) private var dismiss
    
    private var sortedReports: [Report] {
        reports.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if sortedReports.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No hay reportes")
                            .font(.headline)
                        Text("Cuando tengas reportes, aparecerán aquí.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(Color(.systemGroupedBackground))
                } else {
                    List(sortedReports) { report in
                        AllReportsRow(report: report)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Todos los reportes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
    }
}

private struct AllReportsRow: View {
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
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(report.title)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(dateString(report.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if !report.subtitle.isEmpty {
                    Text(report.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 10) {
                    Label(report.type.rawValue, systemImage: "tag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let _ = report.coordinate {
                        Label("Con ubicación", systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(report.status.rawValue)
                        .font(.caption).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(report.status.color.opacity(0.15), in: Capsule())
                        .foregroundStyle(report.status.color)
                }
            }
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}

#Preview {
    let sample = [
        Report(type: .pothole, title: "Bache grande", subtitle: "En la calle Juárez", date: .now.addingTimeInterval(-3600), coordinate: nil, status: .new),
        Report(type: .streetlight, title: "Luminaria apagada", subtitle: "Frente a la plaza", date: .now.addingTimeInterval(-7200), coordinate: nil, status: .inProgress),
        Report(type: .waterLeak, title: "Fuga de agua", subtitle: "Esquina con Hidalgo", date: .now.addingTimeInterval(-86400), coordinate: nil, status: .resolved)
    ]
    return AllReportsSheet(reports: sample)
}
