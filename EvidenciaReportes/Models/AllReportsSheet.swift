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
                        NavigationLink {
                            ReportDetailView(report: report)
                        } label: {
                            DetailedReportView(report: report)
                        }
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

#Preview {
    let sample = [
        Report(type: .pothole, title: "Bache grande", subtitle: "En la calle Juárez", date: .now.addingTimeInterval(-3600), coordinate: nil, status: .new),
        Report(type: .streetlight, title: "Luminaria apagada", subtitle: "Frente a la plaza", date: .now.addingTimeInterval(-7200), coordinate: nil, status: .inProgress),
        Report(type: .waterLeak, title: "Fuga de agua", subtitle: "Esquina con Hidalgo", date: .now.addingTimeInterval(-86400), coordinate: nil, status: .resolved)
    ]
    return AllReportsSheet(reports: sample)
}
