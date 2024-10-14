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

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published var locationDescription: String = "Unknown"
    
    // Add property to track last notification time
    private var lastNotificationDate: Date?
    private let notificationInterval: TimeInterval = 1800 // 30min for testing
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    // Method to check if notification can be sent
    private func canSendNotification() -> Bool {
        if let lastDate = lastNotificationDate {
            // Check if the current time is at least 1 second after the last notification (for testing)
            return Date().timeIntervalSince(lastDate) > notificationInterval
        }
        return true // If lastNotificationDate is nil, allow notification
    }
    
    // Method to show an alert as a notification
    private func showAlert(title: String, message: String) {
        // 获取当前活动的视图控制器
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let topController = windowScene.windows.first?.rootViewController {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Method to send notification and update last notification time
    func sendNotification() {
        guard canSendNotification() else {
            print("Notification cooldown in effect, not sending a new notification.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Take a Break!"
        content.body = "You are near a green space. Take a moment to relax and enjoy nature."
        content.sound = .default
        
        // Display an alert instead of a local notification
        showAlert(title: content.title, message: content.body)

        // Record the time the notification was sent
        lastNotificationDate = Date()
        print("Notification sent: \(content.title) - \(content.body)")
    }
    
    // Search for nearby green spaces like parks or gardens
    func searchForGreenSpaces() {
        guard let location = location else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "garden, park"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Error searching for gardens or parks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Iterate through search results and check if they contain "garden" or "park"
            if !response.mapItems.isEmpty {
                for item in response.mapItems {
                    if let name = item.name?.lowercased(),
                       name.contains("garden") || name.contains("park") {
                        print("Found a nearby garden or park: \(name)")
                        self.sendNotification()
                        break
                    }
                }
            }
        }
    }

    // Reverse geocode
    func reverseGeocodeLocation(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self.locationDescription = "Unknown place"
                return
            }
            
            if let name = placemark.name, let locality = placemark.locality {
                self.locationDescription = "\(name), \(locality)"
            } else if let locality = placemark.locality {
                self.locationDescription = locality
            } else {
                self.locationDescription = "Unknown place"
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        
        // Reverse geocode
        reverseGeocodeLocation(location: location)
        
        // Search for green spaces nearby
        searchForGreenSpaces()
    }
}


