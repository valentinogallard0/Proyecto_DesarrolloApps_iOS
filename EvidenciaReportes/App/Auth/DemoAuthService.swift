//
//  DemoAuthService.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import Foundation

final class DemoAuthService: AuthService {
    func signIn(email: String, password: String) async throws -> UserSession {
        try await Task.sleep(nanoseconds: 500_000_000) // simula red

        // Credenciales de ejemplo (puedes cambiarlas a tu gusto)
        // Usuario:
        //   email: user@demo.com  password: 123456
        // Admin:
        //   email: admin@demo.com password: 123456

        let normalized = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard password == "123456",
              normalized == "user@demo.com" || normalized == "admin@demo.com"
        else {
            throw AuthError.invalidCredentials
        }

        let role: UserRole = (normalized == "admin@demo.com") ? .admin : .user

        return UserSession(
            userId: UUID().uuidString,
            email: normalized,
            issuedAt: Date(),
            token: UUID().uuidString.replacingOccurrences(of: "-", with: ""),
            role: role
        )
    }

    func signOut() async { /* no-op en demo */ }
}

