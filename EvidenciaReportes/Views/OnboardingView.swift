//
//  OnboardingView.swift
//  EvidenciaReportes
//
//  Created by Codex on 30/11/25.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void
    
    @StateObject private var viewModel = OnboardingViewModel()
    @StateObject private var permissions = OnboardingPermissionsViewModel()
    
    var body: some View {
        VStack(spacing: 28) {
            HStack {
                Spacer()
                if !viewModel.isOnLastPage {
                    Button("Saltar") {
                        onFinish()
                    }
                    .font(.subheadline.weight(.semibold))
                }
            }
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(Array(viewModel.slides.enumerated()), id: \.offset) { index, slide in
                    VStack(spacing: 18) {
                        Image(systemName: slide.systemImage)
                            .font(.system(size: 64, weight: .light))
                            .foregroundStyle(.white)
                            .frame(width: 120, height: 120)
                            .background(
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                        Text(slide.title)
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text(slide.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
                permissionsSlide.tag(viewModel.slides.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            if viewModel.isOnLastPage {
                permissionsSection
                Button(action: onFinish) {
                    Text("Comenzar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OnboardingPrimaryButtonStyle())
                .disabled(!permissions.canFinishOnboarding)
                
                if !permissions.canFinishOnboarding {
                    Text("Por favor responde a los permisos para continuar.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                Button {
                    withAnimation {
                        viewModel.advance()
                    }
                } label: {
                    Text("Continuar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OnboardingPrimaryButtonStyle())
            }
        }
        .padding(24)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .animation(.easeInOut, value: viewModel.currentPage)
    }
    
    private var permissionsSlide: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white)
                .frame(width: 120, height: 120)
                .background(
                    Circle()
                        .fill(LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
            Text("Permisos")
                .font(.title2.weight(.semibold))
            Text("Antes de empezar necesitamos tu autorización para mostrarte reportes cercanos y enviarte avisos importantes.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var permissionsSection: some View {
        VStack(spacing: 12) {
            permissionCard(
                icon: "location.circle.fill",
                title: "Ubicación",
                description: "Usamos tu ubicación para centrar el mapa y mostrarte reportes cercanos.",
                status: permissions.locationStatus
            ) {
                permissions.requestLocationAccess()
            }
            
            permissionCard(
                icon: "bell.badge.fill",
                title: "Notificaciones",
                description: "Recibe actualizaciones cuando cambie el estado de tus reportes.",
                status: permissions.notificationStatus
            ) {
                permissions.requestNotificationAccess()
            }
        }
    }
    
    @ViewBuilder
    private func permissionCard(icon: String, title: String, description: String, status: PermissionStatus, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                Spacer()
                Text(statusText(for: status))
                    .font(.caption)
                    .foregroundStyle(statusColor(for: status))
            }
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(action: action) {
                Text(status == .granted ? "Permiso activo" : "Administrar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(OnboardingSecondaryButtonStyle())
            .disabled(status == .granted)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 4)
        )
    }
    
    private func statusText(for status: PermissionStatus) -> String {
        switch status {
        case .idle: return "Sin solicitar"
        case .requesting: return "Solicitando…"
        case .granted: return "Concedido"
        case .denied: return "Denegado"
        case .restricted: return "Restringido"
        }
    }
    
    private func statusColor(for status: PermissionStatus) -> Color {
        switch status {
        case .granted: return .green
        case .denied, .restricted: return .red
        case .requesting: return .orange
        case .idle: return .secondary
        }
    }
}

private struct OnboardingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

private struct OnboardingSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.12 : 0.18))
            )
            .foregroundColor(.accentColor)
    }
}

#Preview {
    OnboardingView(onFinish: { })
}
