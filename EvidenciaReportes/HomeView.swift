//
//  HomeView.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 02/09/25.
//
import SwiftUI

struct HomeView: View {
    
    @State private var searchText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                
                // Barra de búsqueda con botón
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Buscar ubicación...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                    Button(action: {
                        // Acción de búsqueda
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)

                // Mapa ilustrativo
                Image("map")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .padding(.horizontal)

                // Tarjeta de calidad del aire
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calidad del Aire")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack(spacing: 16) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Índice: 42")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            Text("Buena calidad del aire")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                .padding(.horizontal)

                // Botón para subir reporte
                Button(action: {
                    // Acción para subir reporte
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                        Text("Subir Reporte")
                            .font(.headline)
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    HomeView()
}
