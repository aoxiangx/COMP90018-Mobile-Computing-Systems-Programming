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
import SwiftUI

@MainActor
class LocationManager: NSObject, ObservableObject {
    
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    
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
    
    
    // start date and end date for green space time
    
    // Keys for UserDefaults
    private let greenSpaceTimeKey = "greenSpaceTime"
    private let lastSavedDateKey = "lastSavedDate"

    // DateFormatter for consistent date keys
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // "yyyy-MM-dd-HH" save HH
        formatter.dateFormat = "yyyy-MM-dd-HH"
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
    // save green space time end
    
    // location update timer
    private var locationUpdateTimer: Timer? // control update frequency
    

    private override init() { // Prevent external initialization
        super.init()
        if logStatus {
                startUpdatingLocationIfNeeded()
        }
        
        // Initialize lastSavedDate and handle day change
        let storedLastSavedDate = UserDefaults.standard.object(forKey: lastSavedDateKey) as? Date
        if let storedDate = storedLastSavedDate {
            if !Calendar.current.isDate(storedDate, inSameDayAs: Date()) {
                // Save the previous day's greenSpaceTime
//                saveGreenSpaceTime(for: storedDate)
                
                let hour = Calendar.current.component(.hour, from: storedDate)
                saveGreenSpaceTime(for: lastSavedDate, hour: hour)
                
                
                // Reset the time
                timeInGreenSpace = 0
                lastSavedDate = Calendar.current.startOfDay(for: Date())
            }
        } else {
            lastSavedDate = Calendar.current.startOfDay(for: Date())
        }
        
        // listen to the log status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogStatusChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
        
    }
    
    private func saveGreenSpaceTime(for date: Date, hour: Int) {
        // Convert timeInGreenSpace to minutes
        let greenSpaceTimeInMinutes = timeInGreenSpace
        
        // Retrieve existing dictionary or create a new one
        var greenSpaceDict = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:]
        let dateString = dateFormatter.string(from: date) + "-\(hour)"
        greenSpaceDict[dateString] = greenSpaceTimeInMinutes
        UserDefaults.standard.set(greenSpaceDict, forKey: greenSpaceTimeKey)
    }
    
    
    @objc private func handleLogStatusChange() {
            if logStatus {
                startUpdatingLocationIfNeeded()
            } else {
                stopUpdatingLocation()
            }
    }
    
    private func startUpdatingLocationIfNeeded() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true // allow background mode
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
    }
    
    
    private func stopUpdatingLocation() {
            locationManager.stopUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = false
    }
    
    private func scheduleDailyNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Remember to spend some time in nature today!"
        content.sound = .default
        
    
        let times: [(hour: Int, minute: Int)] = [
            (hour: 9, minute: 0),    // 9:00 AM
            (hour: 12, minute: 0),   // 12:00 PM
//            (hour: 12, minute: 45),  // 12:45 PM
//            (hour: 13, minute: 20),  // 1:20 PM
//            (hour: 13, minute: 25),  // 1:30 PM
//            (hour: 14, minute: 0),   // 2:00 PM
//            (hour: 14, minute: 30),  // 2:30 PM
//            (hour: 15, minute: 0),   // 3:00 PM
//            (hour: 15, minute: 15),  // 3:15 PM
//            (hour: 15, minute: 30),  // 3:30 PM
//            (hour: 15, minute: 45),  // 3:45 PM
//            (hour: 16, minute: 0),   // 4:00 PM
//            (hour: 16, minute: 15),  // 4:15 PM
//            (hour: 16, minute: 30),  // 4:30 PM
//            (hour: 16, minute: 45),  // 4:45 PM
            (hour: 18, minute: 0)    // 6:00 PM
        ]
        
        for (index, time) in times.enumerated() {
            
            var dateComponents = DateComponents()
            dateComponents.hour = time.hour
            dateComponents.minute = time.minute
            
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            
            let request = UNNotificationRequest(
                identifier: "dailyGreenSpaceReminder_\(index)",
                content: content,
                trigger: trigger
            )
            
            
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
//            print(placemark)
            if let name = placemark.name {
                self.locationDescription = name
                self.currentLocationName = name // Store current location name
                
                // Check for location change
                self.checkLocationChange()
            }
        }
    }
    
    private let greenSpaceKeywords = [
        "park",
        "garden",
        "square",
        "lawn",
        "memorial",
        "playground",
        "zoo",
        "reserve",
        "forest",
        "wetland"
    ]
    
    private func checkLocationChange() {
        // Check only when the location name changes
        if currentLocationName != previousLocationName {
            previousLocationName = currentLocationName // Update the previous location name
            
            // Check if the current location name contains any green space keywords
            if greenSpaceKeywords.contains(where: { currentLocationName.lowercased().contains($0) }) {
                if !isInGreenSpace { // If just entered green space
                    
                    // Read today's stored green space time and continue timing
                    let dateString = dateFormatter.string(from: Date())
                    let storedTime = UserDefaults.standard.double(forKey: dateString)
                    
                    timeInGreenSpace = storedTime // If there's no stored value, storedTime will be 0

                    // Send notification if not already sent
                    if !self.hasSentGreenSpaceNotification {
//                        print("发送消息")
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
                    
                    // Save today's green space time
                    saveTodayGreenSpaceTime()
                    
//                    print("离开绿地")
                    self.hasSentGreenSpaceNotification = false // Reset notification flag upon leaving green space
                }
            }
        }
    }

    private func saveTodayGreenSpaceTime() {
        // Save today's green space time to the dictionary and synchronize it
        var greenSpaceDict = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:] // Retrieve existing data or create a new dictionary
        let dateString = dateFormatter.string(from: Date()) // Format the current date to string
        greenSpaceDict[dateString] = timeInGreenSpace // Update the dictionary with today's green space time
        UserDefaults.standard.set(greenSpaceDict, forKey: greenSpaceTimeKey) // Save the updated dictionary to UserDefaults
    }

    private func startGreenSpaceTimer() {
        stopGreenSpaceTimer() // Ensure no duplicate timers are running
        
        // Read the existing green space time for today
        let dateString = dateFormatter.string(from: Date()) // Format the current date to string
        let storedTime = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:] // Retrieve stored time data
        timeInGreenSpace = storedTime[dateString] ?? 0.0 // Initialize today's green space time
        
        // Schedule a timer that updates the green space time every second
        greenSpaceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return } // Ensure self is not nil
            Task {
                await self.updateTimeInGreenSpace() // Update the time in green space asynchronously
            }
        }
    }

    
    private func stopGreenSpaceTimer() {
        greenSpaceTimer?.invalidate()
        greenSpaceTimer = nil
        // Do not reset time, as it should continue counting when the user returns
    }
    
//    @MainActor
//    private func updateTimeInGreenSpace() {
//        timeInGreenSpace += 1
////        print("Time spent in green space: \(timeInGreenSpace) seconds")
//        
//        // 每隔一分钟保存一次
//        if timeInGreenSpace.truncatingRemainder(dividingBy: 60) == 0 {
//            saveTodayGreenSpaceTime()
//        }
//    }
    
    
    @MainActor
    private func updateTimeInGreenSpace() {
        timeInGreenSpace += 1
//        let currentHour = Calendar.current.component(.hour, from: Date())
//        let dateString = dateFormatter.string(from: Date()) + "-\(currentHour)"
//        
//        print("Time spent in green space: \(timeInGreenSpace) seconds")
        
        // one min, save once
//        if timeInGreenSpace.truncatingRemainder(dividingBy: 60) == 0 {
//            saveTodayGreenSpaceTime()
//        }
    }
    
//    private func sendGreenSpaceNotification() {
//        // Get the current active scene
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let rootViewController = windowScene.windows.first?.rootViewController else {
//            print("Unable to find root view controller.")
//            return
//        }
//        
//        let alert = UIAlertController(title: "Enjoy Your Time!", message: "You are in a green space. Take a moment to relax and enjoy the surroundings.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        
//        Task { @MainActor in
//            rootViewController.present(alert, animated: true, completion: nil)
//        }
//    }

    private func sendGreenSpaceNotification() {
        // Get the current active scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to find root view controller.")
            return
        }

        // Create a toast-like view with improved styling
        let toastView = UIView(frame: CGRect(x: rootViewController.view.frame.size.width / 2 - 150,
                                             y: rootViewController.view.frame.size.height - 150,
                                             width: 300, height: 50))
        toastView.backgroundColor = UIColor.white
        toastView.layer.cornerRadius = 12
        toastView.clipsToBounds = true

        // Set border with green color from Constants
        toastView.layer.borderWidth = 2
        toastView.layer.borderColor = UIColor(
            red: 193 / 255,
            green: 242 / 255,
            blue: 215 / 255,
            alpha: 1.0
        ).cgColor

        // Add a label to the toast view with enhanced styling
        let label = UILabel(frame: CGRect(x: 10, y: 5, width: 280, height: 40))
        label.text = "You are in a green space. Take a moment to relax!"
//        label.textColor = UIColor(
//                red: 0.6,
//                green: 0.61,
//                blue: 0.61,
//                alpha: 1.0
//            ) // Use gray4 from Constants
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Roboto", size: 16) ?? UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 2
        toastView.addSubview(label)

        // Add shadow to the toastView for a more elevated look
//        toastView.layer.shadowColor = UIColor.black.cgColor
//        toastView.layer.shadowOpacity = 0.3
//        toastView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        toastView.layer.shadowRadius = 4

        // Add the toast view to the root view controller's view
        rootViewController.view.addSubview(toastView)

        // Animate the appearance and disappearance of the toast view
        toastView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            toastView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 3.0, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        }
    }




    
    
    
    
    
//    func getGreenSpaceTimes(forLastNDays n: Int) -> [Double] {
//        var greenSpaceTimes: [Double] = [] // Array to hold green space times
//        let greenSpaceDict = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:] // Retrieve stored data from UserDefaults
//        
//        let calendar = Calendar.current // Get the current calendar
//        
//        switch n {
//        case 1: // Return data for the past day (24 hours)
//            for hour in 0..<24 {
//                if let date = calendar.date(byAdding: .hour, value: -hour, to: Date()) {
//                    let dateString = dateFormatter.string(from: date) // Format the date to string
//                    greenSpaceTimes.append(greenSpaceDict[dateString] ?? 0.0) // Add each hour's data
//                } else {
//                    greenSpaceTimes.append(0.0) // Default to 0 if date calculation fails
//                }
//            }
//        
//        case 7: // Return data for the past week (7 days)
//            for dayOffset in 0..<7 {
//                var dailyTotalTime: Double = 0.0 // Initialize daily total time
//                for hour in 0..<24 {
//                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()),
//                       let hourDate = calendar.date(byAdding: .hour, value: -hour, to: date) {
//                        let dateString = dateFormatter.string(from: hourDate) // Format the date to string
//                        dailyTotalTime += greenSpaceDict[dateString] ?? 0.0 // Accumulate each hour's data for the day
//                    }
//                }
//                greenSpaceTimes.append(dailyTotalTime) // Add the total time for the day
//            }
//        
//        case 30: // Return data for the past month (each day's 24 hours data)
//            let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 0 // Get number of days in the current month
//            for dayOffset in 0..<30 {
//                var dailyTotalTime: Double = 0.0 // Initialize daily total time
//                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
//                    for hour in 0..<24 {
//                        if let hourDate = calendar.date(byAdding: .hour, value: -hour, to: date) {
//                            let dateString = dateFormatter.string(from: hourDate) // Format the date to string
//                            dailyTotalTime += greenSpaceDict[dateString] ?? 0.0 // Accumulate each hour's data for the day
//                        }
//                    }
//                }
//                greenSpaceTimes.append(dailyTotalTime) // Add the total time for the day
//            }
//        
//        case 180: // Return data for the past six months
//            for monthOffset in 0..<6 {
//                if let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
//                    var monthlyTotalTime: Double = 0.0 // Initialize monthly total time
//                    let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 0 // Get number of days in the month
//                    
//                    for day in 1...daysInMonth {
//                        if let specificDate = calendar.date(bySetting: .day, value: day, of: date) {
//                            for hour in 0..<24 {
//                                if let hourDate = calendar.date(byAdding: .hour, value: -hour, to: specificDate) {
//                                    let dateString = dateFormatter.string(from: hourDate) // Format the date to string
//                                    monthlyTotalTime += greenSpaceDict[dateString] ?? 0.0 // Accumulate total time for the month
//                                }
//                            }
//                        }
//                    }
//                    greenSpaceTimes.append(monthlyTotalTime) // Add the total time for the month
//                }
//            }
//        
//        case 365: // Return data for the past year
//            for monthOffset in 0..<12 {
//                if let date = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
//                    var monthlyTotalTime: Double = 0.0 // Initialize monthly total time
//                    let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 0 // Get number of days in the month
//                    
//                    for day in 1...daysInMonth {
//                        if let specificDate = calendar.date(bySetting: .day, value: day, of: date) {
//                            for hour in 0..<24 {
//                                if let hourDate = calendar.date(byAdding: .hour, value: -hour, to: specificDate) {
//                                    let dateString = dateFormatter.string(from: hourDate) // Format the date to string
//                                    monthlyTotalTime += greenSpaceDict[dateString] ?? 0.0 // Accumulate total time for the month
//                                }
//                            }
//                        }
//                    }
//                    greenSpaceTimes.append(monthlyTotalTime) // Add the total time for the month
//                }
//            }
//        
//        default:
//            break // No support for unsupported n values
//        }
//        
//        // Convert time to minutes
//        return greenSpaceTimes.map { $0 / 60.0 } // Return the times in minutes
//    }
    func getGreenSpaceTimes(forLastNDays n: Int) -> [Double] {
        var greenSpaceTimes: [Double] = [] // Array to hold green space times
        let greenSpaceDict = UserDefaults.standard.dictionary(forKey: greenSpaceTimeKey) as? [String: Double] ?? [:] // Retrieve stored data from UserDefaults
        
        let calendar = Calendar.current // Get the current calendar
        
        switch n {
        case 1: // Return data for the past day (24 hours)
            let startOfDay = calendar.startOfDay(for: Date()) // Get the start of the current day (0:00)
            for hour in 0..<24 {
                if let date = calendar.date(byAdding: .hour, value: hour, to: startOfDay) {
                    let dateString = dateFormatter.string(from: date) // Format the date to string
                    let greenSpaceTime = greenSpaceDict[dateString] ?? 0.0
                    greenSpaceTimes.append(greenSpaceTime) // Add each hour's data
//                    print("Date: \(dateString), GreenSpaceTime (seconds): \(greenSpaceTime)")
                } else {
                    greenSpaceTimes.append(0.0) // Default to 0 if date calculation fails
                }
            }
        case 7: // Return data for the past week (7 days)
            for dayOffset in 0..<7 {
                var dailyTotalTime: Double = 0.0 // Initialize daily total time
                for hour in 0..<24 {
                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()),
                       let hourDate = calendar.date(byAdding: .hour, value: -hour, to: date) {
                        let dateString = dateFormatter.string(from: hourDate) // Format the date to string
                        let greenSpaceTime = greenSpaceDict[dateString] ?? 0.0
                        dailyTotalTime += greenSpaceTime // Accumulate each hour's data for the day
//                        print("Date: \(dateString), GreenSpaceTime (seconds): \(greenSpaceTime)")
                    }
                }
                greenSpaceTimes.append(dailyTotalTime) // Add the total time for the day
            }
            greenSpaceTimes.reverse() // Reverse the array to get data in the correct order
        
        case 30: // Return data for the past month (each day's 24 hours data)
//            let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 0 // Get number of days in the current month
            for dayOffset in 0..<30 {
                var dailyTotalTime: Double = 0.0 // Initialize daily total time
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                    for hour in 0..<24 {
                        if let hourDate = calendar.date(byAdding: .hour, value: -hour, to: date) {
                            let dateString = dateFormatter.string(from: hourDate) // Format the date to string
                            let greenSpaceTime = greenSpaceDict[dateString] ?? 0.0
                            dailyTotalTime += greenSpaceTime // Accumulate each hour's data for the day
//                            print("Date: \(dateString), GreenSpaceTime (seconds): \(greenSpaceTime)")
                        }
                    }
                }
                greenSpaceTimes.append(dailyTotalTime) // Add the total time for the day
            }
            greenSpaceTimes.reverse()
        
        case 180: // Return data for the past six months
            let currentDate = Date()
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!

            for monthOffset in 0..<6 {
                if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: currentMonthStart) {
                    // Get the start and end of this month
                    let monthComponents = calendar.dateComponents([.year, .month], from: monthDate)
                    let startOfMonth = calendar.date(from: monthComponents)!
                    let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
                    
                    var monthlyTotalTime: Double = 0.0
                    
                    // Debug print for month boundaries
//                    print("Processing month: \(calendar.component(.month, from: monthDate))")
//                    print("Month start: \(dateFormatter.string(from: startOfMonth))")
//                    print("Month end: \(dateFormatter.string(from: nextMonth))")
                    
                    // Iterate through the green space dictionary
                    for (dateString, time) in greenSpaceDict {
                        if let recordDate = dateFormatter.date(from: dateString),
                           recordDate >= startOfMonth && recordDate < nextMonth {
                            monthlyTotalTime += time
//                            print("Including record - Month: \(calendar.component(.month, from: recordDate)), Date: \(dateString), Time: \(time)")
                        }
                    }
                    
                    // Convert to hours if needed and append
                    greenSpaceTimes.append(monthlyTotalTime)
                }
            }

            // Reverse the array to get chronological order
            greenSpaceTimes.reverse()
        
        case 365: // Return data for the past year
            let currentDate = Date()
            let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
            for monthOffset in 0..<12 {
                if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: currentMonthStart) {
                    let (startOfMonth, endOfMonth) = getMonthBoundaries(for: monthDate)
                    var monthlyTotalTime: Double = 0.0
                    
                    // Debug prints for month boundaries
//                    print("\nProcessing Month: \(calendar.component(.month, from: monthDate))")
//                    print("Start: \(dateFormatter.string(from: startOfMonth))")
//                    print("End: \(dateFormatter.string(from: endOfMonth))")
                    
                    // Iterate through the dictionary entries
                    for (dateString, time) in greenSpaceDict {
                        if let recordDate = dateFormatter.date(from: dateString),
                           recordDate >= startOfMonth && recordDate < endOfMonth {
                            monthlyTotalTime += time
                            if time != 0 {
                                print("Including - Date: \(dateString), Time: \(time)")
                            }
                        }
                    }
                    
                    // Store the monthly total
                    greenSpaceTimes.append(monthlyTotalTime)
//                    print("Monthly Total (seconds): \(monthlyTotalTime)")
                }
            }
            greenSpaceTimes.reverse()
        
        default:
            break // No support for unsupported n values
        }
        
        // Convert time to minutes
        return greenSpaceTimes.map { $0 / 60.0 } // Return the times in minutes
    }
    
//    func getMonthBoundaries(for date: Date) -> (start: Date, end: Date)? {
//        let calendar = Calendar.current
//        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
//              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
//            return nil
//        }
//        return (startOfMonth, endOfMonth)
//    }
    func getMonthBoundaries(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let monthComponents = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: monthComponents)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        return (startOfMonth, nextMonth)
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
        let hour = Calendar.current.component(.hour, from: lastSavedDate)
    
        
        if today != Calendar.current.startOfDay(for: lastSavedDate) {
            // Save the previous day's greenSpaceTime
//            saveGreenSpaceTime(for: lastSavedDate)
            saveGreenSpaceTime(for: lastSavedDate, hour: hour)
            // Reset the time
            timeInGreenSpace = 0
            // Update lastSavedDate
            lastSavedDate = today
        }
        
        // keep update green space time while the app running at the backmode
        if isInGreenSpace {
            updateTimeInGreenSpace()
        }
        
        // test get green space times
        // print(getGreenSpaceTimes(forLastNDays: 180))
        
    }
}
