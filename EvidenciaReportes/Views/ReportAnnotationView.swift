//
//  ReportAnnotationView.swift
//  EvidenciaReportes
//
//  Created by Assistant on 24/09/25.
//

import SwiftUI

struct ReportAnnotationView: View {
    let report: Report
    var showsTitle: Bool = true
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(report.status.color)
                    .frame(width: 30, height: 30)
                    .shadow(color: report.status.color.opacity(0.25), radius: 3, x: 0, y: 1)
                Circle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 30, height: 30)
                Image(systemName: report.type.icon)
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            if showsTitle {
                Text(report.title)
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(report.status.color.opacity(0.9), in: Capsule())
            }
        }
    }
}

#Preview {
    ReportAnnotationView(report: Report(type: .pothole, title: "Bache", subtitle: "Centro", date: .now, coordinate: nil, status: .new))
}
