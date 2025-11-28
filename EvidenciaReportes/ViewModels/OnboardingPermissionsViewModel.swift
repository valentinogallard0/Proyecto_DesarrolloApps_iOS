//
//  OnboardingPermissionsViewModel.swift
//  EvidenciaReportes
//
//  Created by Codex on 30/11/25.
//

import Foundation
import CoreLocation
import UserNotifications

enum PermissionStatus: Equatable {
    case idle
    case requesting
    case granted
    case denied
    case restricted
}

final class OnboardingPermissionsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationStatus: PermissionStatus = .idle
    @Published var notificationStatus: PermissionStatus = .idle
    
    private var locationManager: CLLocationManager?
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        updateLocationStatus(CLLocationManager.authorizationStatus())
        refreshNotificationStatus()
    }
    
    func requestLocationAccess() {
        guard locationStatus != .granted else { return }
        locationStatus = .requesting
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager = manager
        manager.requestWhenInUseAuthorization()
    }
    
    func requestNotificationAccess() {
        guard notificationStatus != .granted else { return }
        notificationStatus = .requesting
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationStatus = granted ? .granted : .denied
            }
        }
    }
    
    func refreshNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.notificationStatus = .granted
                case .denied:
                    self.notificationStatus = .denied
                case .notDetermined:
                    self.notificationStatus = .idle
                @unknown default:
                    self.notificationStatus = .idle
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationStatus(manager.authorizationStatus)
    }
    
    private func updateLocationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = .granted
        case .denied:
            locationStatus = .denied
        case .restricted:
            locationStatus = .restricted
        case .notDetermined:
            locationStatus = .idle
        @unknown default:
            locationStatus = .idle
        }
    }
    
    var canFinishOnboarding: Bool {
        locationStatus != .idle && locationStatus != .requesting
    }
}
