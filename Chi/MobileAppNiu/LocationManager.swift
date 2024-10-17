//
//  LocationManager.swift
//  MobileAppNiu
//
//  Created by 关昊 on 6/10/2024.
//

import Foundation
import MapKit
import UserNotifications
import UIKit
import Firebase
import FirebaseAuth

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager() // Singleton instance
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published var locationDescription: String = "Unknown"
    
    private var lastNotificationDate: Date?
    private let notificationInterval: TimeInterval = 1800 // 30 minutes for testing
    private var timeInGreenSpace: TimeInterval = 0 // Used to record time spent in green space
    private var greenSpaceTimer: Timer?
    private var isInGreenSpace: Bool = false // Tracks whether in green space
    private var currentLocationName: String = "" // Used to store the current location name
    private var previousLocationName: String = "" // Used to store the previous location name

    private override init() { // Prevent external initialization
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    // Reverse geocoding
    func reverseGeocodeLocation(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self.locationDescription = "Unknown place"
                return
            }
            
            if let name = placemark.name {
                self.locationDescription = name
                self.currentLocationName = name // Store current location name
                
                // Check for location change
                self.checkLocationChange()
            }
        }
    }
    
    private func checkLocationChange() {
        // Check only when the location name changes
        if currentLocationName != previousLocationName {
            previousLocationName = currentLocationName // Update the previous location name
            
            // Check if the current location name contains "park" or "garden"
            if currentLocationName.lowercased().contains("park") || currentLocationName.lowercased().contains("garden") {
                if !isInGreenSpace { // If just entered green space
                    isInGreenSpace = true
                    startGreenSpaceTimer()
                }
            } else {
                if isInGreenSpace { // If just left green space
                    isInGreenSpace = false
                    stopGreenSpaceTimer()
                }
            }
        }
    }
    
    private func startGreenSpaceTimer() {
        stopGreenSpaceTimer() // Ensure no duplicate timer
        timeInGreenSpace = 0 // Reset timer
        greenSpaceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.updateTimeInGreenSpace()
            }
        }
    }

    private func stopGreenSpaceTimer() {
        greenSpaceTimer?.invalidate()
        greenSpaceTimer = nil
        // Do not reset time, as it should continue counting when the user returns
    }
    
    @MainActor
    private func updateTimeInGreenSpace() {
        timeInGreenSpace += 1
        print("Time spent in green space: \(timeInGreenSpace) seconds")
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        
        reverseGeocodeLocation(location: location)
    }
}
