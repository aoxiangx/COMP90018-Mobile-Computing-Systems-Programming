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
    private var timeInGreenSpace: TimeInterval = 0 // Used to record time spent in green space
    private var greenSpaceTimer: Timer?
    private var isInGreenSpace: Bool = false // Tracks whether in green space
    private var hasSentGreenSpaceNotification: Bool = false // Tracks whether notification has been sent
    private var currentLocationName: String = "" // Used to store the current location name
    private var previousLocationName: String = "" // Used to store the previous location name

    // Keys for UserDefaults
    private let greenSpaceTimeKey = "greenSpaceTime"
    private let lastSavedDateKey = "lastSavedDate"

    // DateFormatter for consistent date keys
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // Tracks the last date when green space time was saved
    private var lastSavedDate: Date {
        get {
            UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date ?? Calendar.current.startOfDay(for: Date())
        }
        set {
            UserDefaults.standard.set(newValue, forKey: lastSavedDateKey)
        }
    }

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
        
        scheduleDailyNotifications()
        
        // Initialize lastSavedDate and handle day change
        let storedLastSavedDate = UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date
        if let storedDate = storedLastSavedDate {
            if !Calendar.current.isDate(storedDate, inSameDayAs: Date()) {
                // Save the previous day's greenSpaceTime
                saveGreenSpaceTime(for: storedDate)
                // Reset the time
                timeInGreenSpace = 0
                lastSavedDate = Calendar.current.startOfDay(for: Date())
            }
        } else {
            lastSavedDate = Calendar.current.startOfDay(for: Date())
        }
    }
    
    private func scheduleDailyNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Remember to spend some time in nature today!"
        content.sound = .default
        
        // Define the times you want notifications to be sent (e.g., 9:00 AM, 12:00 PM, 6:00 PM)
        let times: [(hour: Int, minute: Int)] = [
            (hour: 9, minute: 0),  // 9:00 AM
            (hour: 12, minute: 0), // 12:00 PM
            (hour: 18, minute: 0)  // 6:00 PM
        ]
        
        for (index, time) in times.enumerated() {
            // Set the time for each notification
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            
            // Create the trigger for each time
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "dailyGreenSpaceReminder_\(index)",
                content: content,
                trigger: trigger
            )
            
            // Add the notification request
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule daily notification for \(time.hour):\(time.minute): \(error.localizedDescription)")
                } else {
                    print("Daily notification scheduled for \(time.hour):\(time.minute).")
                }
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
                    
                    // Send notification if not already sent
                    if !self.hasSentGreenSpaceNotification {
                        print("发送消息")
                        sendGreenSpaceNotification()
                        self.hasSentGreenSpaceNotification = true
                    }

                    isInGreenSpace = true
                    startGreenSpaceTimer()
                    
                }
            } else {
                if isInGreenSpace { // If just left green space
                    isInGreenSpace = false
                    stopGreenSpaceTimer()
                    print("离开绿地")
                    self.hasSentGreenSpaceNotification = false // Reset notification flag upon leaving green space
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
    
    private func sendGreenSpaceNotification() {
        // Get the current active scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to find root view controller.")
            return
        }
        
        let alert = UIAlertController(title: "Enjoy Your Time!", message: "You are in a green space. Take a moment to relax and enjoy the surroundings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        Task { @MainActor in
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Green Space Time Persistence
    
    private func saveGreenSpaceTime(for date: Date) {
        // Convert timeInGreenSpace to minutes
        let greenSpaceTimeInMinutes = timeInGreenSpace / 60.0
        
        // Retrieve existing dictionary or create a new one
        var greenSpaceDict = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:]
        let dateString = dateFormatter.string(from: date)
        greenSpaceDict[dateString] = greenSpaceTimeInMinutes
        UserDefaults.standard.set(greenSpaceDict, forKey: greenSpaceTimeKey)
    }
    
    /// Retrieves green space times for the last `n` days, including today.
    func getGreenSpaceTimes(forLastNDays n: Int) -> [Double] {
        var greenSpaceTimes: [Double] = []
        let greenSpaceDict = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:]
        
        for dayOffset in 0..<n {
            if let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let dateString = dateFormatter.string(from: date)
                if let time = greenSpaceDict[dateString] {
                    greenSpaceTimes.append(time)
                } else {
                    greenSpaceTimes.append(0.0) // Default to 0 if no data
                }
            } else {
                greenSpaceTimes.append(0.0) // Default to 0 if date calculation fails
            }
        }
        return greenSpaceTimes
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        
        reverseGeocodeLocation(location: location)
        
        // Check if day has changed
        let today = Calendar.current.startOfDay(for: Date())
        if today != Calendar.current.startOfDay(for: lastSavedDate) {
            // Save the previous day's greenSpaceTime
            saveGreenSpaceTime(for: lastSavedDate)
            // Reset the time
            timeInGreenSpace = 0
            // Update lastSavedDate
            lastSavedDate = today
        }
    }
}





// !!!!!! save green space time by using UserDefaults !!!!!!
//    private func startGreenSpaceTimer() {
//            stopGreenSpaceTimer() // Ensure no duplicate timer
//            timeInGreenSpace = 0 // Reset timer
//            loadSavedGreenSpaceTime() // Load previously saved time
//            greenSpaceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//                guard let self = self else { return }
//                Task {
//                    await self.updateTimeInGreenSpace()
//                }
//            }
//    }
//
//    private func stopGreenSpaceTimer() {
//        greenSpaceTimer?.invalidate()
//        greenSpaceTimer = nil
//        // Save the time when stopping the timer
//        saveGreenSpaceTime()
//    }

//    private func saveGreenSpaceTime() {
//            UserDefaults.standard.set(timeInGreenSpace, forKey: "greenSpaceTime")
//    }
//
//    private func loadSavedGreenSpaceTime() {
//        let savedTime = UserDefaults.standard.double(forKey: "greenSpaceTime")
//        timeInGreenSpace += savedTime // Add to current time
//    }
