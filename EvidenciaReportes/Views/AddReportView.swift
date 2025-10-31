//
//  AddReportView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 23/09/25.
//

import SwiftUI
import MapKit
import CoreLocation
import PhotosUI

struct AddReportView: View {
    let center: CLLocationCoordinate2D
    var onSave: (Report) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var type: ReportType = .pothole
    @State private var titleText: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @State private var region: MKCoordinateRegion
    
    @State private var imageData: Data? = nil
    @State private var showCamera: Bool = false
    
    @State private var address: String? = nil
    @State private var isGeocoding: Bool = false
    @State private var skipReverseGeocode = false
    private let geocoder = CLGeocoder()
    @StateObject private var search = SearchHelper()
    
    init(center: CLLocationCoordinate2D, initialType: ReportType? = nil, onSave: @escaping (Report) -> Void) {
        self.center = center
        self.onSave = onSave
        _type = State(initialValue: initialType ?? .pothole)
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        ))
    }
    
    private func jpegData(from image: UIImage, quality: CGFloat = 0.85) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(ReportType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }
                
                Section("Detalle") {
                    TextField("Título", text: $titleText)
                    TextField("Descripción (opcional)", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Foto") {
                    VStack(alignment: .leading, spacing: 12) {
                        if let imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(12)
                                .overlay(alignment: .topTrailing) {
                                    Button(role: .destructive) { self.imageData = nil } label: {
                                        Image(systemName: "trash")
                                            .padding(8)
                                            .background(.ultraThinMaterial, in: Circle())
                                    }
                                    .padding(8)
                                }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.secondary.opacity(0.08))
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                    Text("Agrega una foto como evidencia")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(height: 120)
                        }

                        HStack(spacing: 12) {
                            PhotosPicker(selection: Binding(get: { nil }, set: { newItem in
                                guard let item = newItem else { return }
                                Task {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        await MainActor.run { self.imageData = data }
                                    }
                                }
                            })) {
                                Image(systemName: "photo")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(.thinMaterial, in: Circle())
                            }
                            .buttonStyle(.plain)

                            Button {
                                showCamera = true
                            } label: {
                                Image(systemName: "camera")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.accentColor, in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section("Ubicación") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Buscar dirección o lugar", text: $search.query)
                            .textFieldStyle(.roundedBorder)
                            .padding(.bottom, 4)
                        
                        if !search.query.isEmpty && !search.results.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(search.results.enumerated()), id: \.offset) { index, item in
                                    Button {
                                        selectSuggestion(item)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.title)
                                                .font(.subheadline)
                                            if !item.subtitle.isEmpty {
                                                Text(item.subtitle)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if index < search.results.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2))
                            )
                        }
                        
                        MapReader { proxy in
                            Map(initialPosition: .region(region)) {
                                if let coord = selectedCoordinate {
                                    Annotation("Ubicación", coordinate: coord) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(.red)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .simultaneousGesture(
                                SpatialTapGesture().onEnded { value in
                                    guard let coord = proxy.convert(value.location, from: .local) else { return }
                                    skipReverseGeocode = false
                                    withAnimation {
                                        selectedCoordinate = coord
                                    }
                                }
                            )
                            .overlay(alignment: .topLeading) {
                                Text("Toca el mapa para colocar el pin")
                                    .font(.caption)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .padding(8)
                            }
                        }
                        
                        if selectedCoordinate == nil {
                            Text("Selecciona un punto en el mapa para continuar.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                Text("Ubicación seleccionada")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button(role: .destructive) { selectedCoordinate = nil } label: {
                                    Label("Quitar pin", systemImage: "xmark.circle")
                                }
                                .font(.caption)
                            }
                        }
                        
                        if isGeocoding {
                            Label("Obteniendo dirección…", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if let address {
                            Label(address, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Nuevo reporte")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let newReport = Report(
                            type: type,
                            title: titleText.isEmpty ? type.rawValue : titleText,
                            subtitle: descriptionText,
                            date: .now,
                            coordinate: selectedCoordinate,
                            address: address,
                            status: .new,
                            imageData: imageData
                        )
                        onSave(newReport)
                        dismiss()
                    }
                    .disabled(titleText.isEmpty || selectedCoordinate == nil)
                }
            }
            .onChange(of: selectedCoordinate) { coord in
                geocoder.cancelGeocode()
                
                guard let coord = coord else {
                    isGeocoding = false
                    address = nil
                    skipReverseGeocode = false
                    return
                }
                
                if skipReverseGeocode {
                    skipReverseGeocode = false
                    return
                }
                
                address = nil
                isGeocoding = true
                let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                    DispatchQueue.main.async {
                        isGeocoding = false
                        if let p = placemarks?.first {
                            let parts = [p.name, p.thoroughfare, p.subThoroughfare, p.locality, p.administrativeArea]
                                .compactMap { $0 }
                                .filter { !$0.isEmpty }
                            address = parts.joined(separator: ", ")
                        } else {
                            address = nil
                        }
                    }
                }
            }
            .onAppear {
                search.updateRegion(region)
            }
            .onChange(of: region.center) { _ in
                search.updateRegion(region)
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    if let image, let data = jpegData(from: image) {
                        self.imageData = data
                    }
                }
            }
        }
    }
    
    private func selectSuggestion(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let mkSearch = MKLocalSearch(request: request)
        mkSearch.start { response, error in
            guard let item = response?.mapItems.first else { return }
            let coord = item.placemark.coordinate
            skipReverseGeocode = true
            selectedCoordinate = coord
            address = formatAddress(from: item.placemark)
            withAnimation {
                region.center = coord
                region.span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            }
            // Limpiar sugerencias y query
            self.search.query = ""
            self.search.results = []
        }
    }
    
    private func formatAddress(from placemark: MKPlacemark) -> String {
        let parts = [placemark.name, placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.administrativeArea]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return parts.joined(separator: ", ")
    }
}

final class SearchHelper: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var query: String = "" { didSet { completer.queryFragment = query } }
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func updateRegion(_ region: MKCoordinateRegion) {
        completer.region = region
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }
}

// Allow observing Optional<CLLocationCoordinate2D> with .onChange by making it Equatable
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
