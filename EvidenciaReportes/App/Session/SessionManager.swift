//
//  SessionManager.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import Foundation
import Combine

@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var session: UserSession?

    private let storageKey = "user.session.v1"

    init() {
        load()
    }

    func set(session: UserSession) {
        self.session = session
        persist()
    }

    func clear() {
        self.session = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func persist() {
        guard let session else { return }
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let sess = try? JSONDecoder().decode(UserSession.self, from: data) else { return }
        self.session = sess
    }

    var isAuthenticated: Bool { session != nil }
}
