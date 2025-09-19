//
//  AuthViewModel.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authService: AuthService
    private let sessionManager: SessionManager

    init(authService: AuthService, sessionManager: SessionManager) {
        self.authService = authService
        self.sessionManager = sessionManager
    }

    var isFormValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    func signIn() {
        errorMessage = nil
        guard isFormValid else {
            errorMessage = "Verifica tu correo y contraseña (mín. 6 caracteres)."
            return
        }
        isLoading = true
        Task {
            do {
                let session = try await authService.signIn(email: email, password: password)
                sessionManager.set(session: session)
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Error al iniciar sesión."
            }
            isLoading = false
        }
    }
}

