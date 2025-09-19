//
//  UserSession.swift
//  EvidenciaReportes
//
//  Created by Valentino De Paola Gallardo on 19/09/25.
//

import Foundation

enum UserRole: String, Codable, Equatable {
    case user
    case admin
}

struct UserSession: Codable, Equatable {
    let userId: String
    let email: String
    let issuedAt: Date
    let token: String
    let role: UserRole        // <-- NUEVO
}
