//
//  LoginView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var vm: AuthViewModel

    init(sessionManager: SessionManager) {
        _vm = StateObject(wrappedValue: AuthViewModel(
            authService: DemoAuthService(), // Cambia por tu servicio real luego
            sessionManager: sessionManager
        ))
    }

    var body: some View {
        VStack(spacing: 24) {
            // Logo / título
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 56, weight: .regular))
                Text("CiudadActiva")
                    .font(.largeTitle).bold()
                Text("Inicia sesión para continuar")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            // Formulario
            VStack(spacing: 14) {
                TextField("Correo", text: $vm.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                SecureField("Contraseña", text: $vm.password)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }

                Button(action: vm.signIn) {
                    HStack {
                        if vm.isLoading { ProgressView() }
                        Text("Entrar")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .disabled(vm.isLoading || !vm.isFormValid)
                .buttonStyle(.borderedProminent)

                Button("¿Olvidaste tu contraseña?") {
                    // Navega a recuperar contraseña (pendiente)
                }
                .font(.footnote)
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(
            LinearGradient(colors: [.gray.opacity(0.05), .blue.opacity(0.08)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    LoginView(sessionManager: SessionManager())
}
