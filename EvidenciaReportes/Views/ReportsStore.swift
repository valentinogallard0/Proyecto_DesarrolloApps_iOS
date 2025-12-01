//
//  ReportsStore.swift
//  EvidenciaReportes
//
//  Created by Assistant on 24/09/25.
//

import CoreLocation
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class ReportsStore: ObservableObject {
    @Published private(set) var reports: [Report] = []
    
    private let context: ModelContext
    
    private static let sampleReports: [Report] = [
        Report(type: .pothole, title: "Bache grande", subtitle: "Av. Constitución #123",
               date: .now.addingTimeInterval(-3600),
               coordinate: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161), status: .inProgress),
        Report(type: .streetlight, title: "Luminaria fundida", subtitle: "Parque Fundidora",
               date: .now.addingTimeInterval(-7200),
               coordinate: CLLocationCoordinate2D(latitude: 25.675, longitude: -100.285), status: .new),
        Report(type: .waterLeak, title: "Fuga visible", subtitle: "Col. Centro",
               date: .now.addingTimeInterval(-10800),
               coordinate: CLLocationCoordinate2D(latitude: 25.671, longitude: -100.309), status: .resolved)
    ]
    
    init(context: ModelContext) {
        self.context = context
        loadReports()
    }
    
    func add(_ report: Report) {
        context.insert(ReportRecord(report: report))
        saveContext()
        reports.insert(report, at: 0)
    }
    
    func reload() {
        loadReports()
    }
    
    private func loadReports() {
        let descriptor = FetchDescriptor<ReportRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            var records = try context.fetch(descriptor)
            if records.isEmpty {
                seedInitialData()
                records = try context.fetch(descriptor)
            }
            reports = records.map(Report.init(record:))
        } catch {
            print("⚠️ Error al cargar reportes con SwiftData: \(error)")
            reports = []
        }
    }
    
    private func seedInitialData() {
        for report in Self.sampleReports {
            context.insert(ReportRecord(report: report))
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("⚠️ Error al guardar cambios en SwiftData: \(error)")
        }
    }
}
