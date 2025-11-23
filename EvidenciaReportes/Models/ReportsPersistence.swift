//
//  ReportsPersistence.swift
//  EvidenciaReportes
//
//  Created by Assistant on 09/10/25.
//

import Foundation

struct ReportsPersistence {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documentsDirectory.appendingPathComponent("reports.json")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func loadReports() -> [Report] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([Report].self, from: data)
        } catch {
            print("⚠️ No se pudieron cargar los reportes: \(error)")
            return []
        }
    }
    
    func saveReports(_ reports: [Report]) {
        do {
            let data = try encoder.encode(reports)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("⚠️ No se pudieron guardar los reportes: \(error)")
        }
    }
}
