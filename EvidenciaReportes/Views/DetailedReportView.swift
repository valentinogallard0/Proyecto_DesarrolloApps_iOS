//
//  DetailedReportView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 22/10/25.
//

import SwiftUI

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
