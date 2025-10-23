// Reusable view for displaying a report summary
//  EvidenciaReportes
//  Creado para refactorización

import SwiftUI

struct ReportCardView: View {
    let report: Report
    var showStatus: Bool = false
    var showDate: Bool = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: report.type.icon)
                .foregroundStyle(report.type.color)
                .reportIconBackground(report.type.color.opacity(0.15))
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(report.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer()
                    if showDate {
                        Text(DateUtils.relativeString(for: report.date))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                }
                if !report.subtitle.isEmpty {
                    Text(report.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if showStatus {
                Spacer(minLength: 8)
                Text(report.status.rawValue)
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(report.status.color.opacity(0.15), in: Capsule())
                    .foregroundStyle(report.status.color)
            }
        }
        .padding(12)
        .cardStyle()
    }
}

#Preview {
    let report = Report(type: .pothole, title: "Bache grande", subtitle: "Av. Constitución #123", date: .now.addingTimeInterval(-3600), coordinate: nil, status: .new)
    return ReportCardView(report: report, showStatus: true, showDate: true)
}
