//
//  AuthService.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import Foundation

protocol AuthService {
    func signIn(email: String, password: String) async throws -> UserSession
    func signOut() async
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Credenciales inválidas."
        case .network: return "Error de red. Intenta de nuevo."
        case .unknown: return "Ocurrió un error inesperado."
        }
    }
}
