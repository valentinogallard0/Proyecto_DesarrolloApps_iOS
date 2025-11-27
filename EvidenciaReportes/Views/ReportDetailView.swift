import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct ReportDetailView: View {
    let report: Report
    @Environment(\.dismiss) private var dismiss
    @State private var fullScreenImage: UIImage? = nil

    private var relativeDate: String {
        let df = RelativeDateTimeFormatter()
        df.unitsStyle = .full
        return df.localizedString(for: report.date, relativeTo: .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    if let data = report.imageData, let uiImage = UIImage(data: data) {
                        Button {
                            fullScreenImage = uiImage
                        } label: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .bottomTrailing) {
                                    Label("Ver completa", systemImage: "arrow.up.left.and.arrow.down.right")
                                        .font(.caption.bold())
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .padding(10)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    if let coord = report.coordinate {
                        mapPreview(coord)
                    }
                    details
                }
                .padding(16)
            }
            .navigationTitle("Detalle del reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { fullScreenImage != nil },
            set: { if !$0 { fullScreenImage = nil } }
        )) {
            if let image = fullScreenImage {
                FullscreenReportImageView(image: image)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle().fill(report.type.color.opacity(0.15))
                Image(systemName: report.type.icon)
                    .foregroundStyle(report.type.color)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(report.title)
                    .font(.headline)
                Text(relativeDate)
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

    private func mapPreview(_ coord: CLLocationCoordinate2D) -> some View {
        let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004))
        return VStack(alignment: .leading, spacing: 8) {
            Map(initialPosition: .region(region)) {
                Annotation(report.title, coordinate: coord) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(.red)
                        .shadow(radius: 2)
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                openInMaps(coord)
            } label: {
                Label("Abrir en Mapas", systemImage: "map")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !report.subtitle.isEmpty {
                Label(report.subtitle, systemImage: "mappin.and.ellipse")
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Label(report.type.rawValue, systemImage: "tag")
                Divider()
                Label(report.status.rawValue, systemImage: "flag")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private func openInMaps(_ coord: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coord)
        let item = MKMapItem(placemark: placemark)
        item.name = report.title
        item.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coord),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        ])
    }
}

private struct FullscreenReportImageView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .ignoresSafeArea()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    let sample = Report(
        type: .pothole,
        title: "Bache grande",
        subtitle: "Av. Constitución #123",
        date: .now.addingTimeInterval(-3600),
        coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        status: .inProgress
    )
    return ReportDetailView(report: sample)
}
