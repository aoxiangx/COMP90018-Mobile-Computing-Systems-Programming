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
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published var locationDescription: String = "Unknown"
    
    private var lastNotificationDate: Date?
    private let notificationInterval: TimeInterval = 1800 // 30min for testing
    private var timeInGreenSpace: TimeInterval = 0 // 用于记录在绿地的时间
    private var greenSpaceTimer: Timer?
    private var isInGreenSpace: Bool = false // 跟踪是否在绿地中
    
    
//    private let userId = getCurrentUserId()

    override init() {
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
    
    private func getCurrentUserId() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid // 返回当前用户的唯一 ID
        }
        return nil // 如果没有用户登录，则返回 nil
    }
    

    // 存储在绿地的时间到 Firebase
//    private func saveTimeInGreenSpaceToFirebase() {
//        let db = Storage.storage()
//        db.collection("users").document(userId).setData(["timeInGreenSpace": timeInGreenSpace]) { error in
//            if let error = error {
//                print("Error saving time to Firebase: \(error.localizedDescription)")
//            } else {
//                print("Time in green space saved successfully.")
//            }
//        }
//    }

    // 从 Firebase 加载时间
//    private func loadTimeInGreenSpaceFromFirebase() {
//        let db = Storage.storage()
//        db.collection("users").document(userId).getDocument { document, error in
//            if let document = document, document.exists {
//                if let time = document.get("timeInGreenSpace") as? TimeInterval {
//                    self.timeInGreenSpace = time
//                    print("Loaded time in green space: \(self.timeInGreenSpace) seconds")
//                }
//            } else {
//                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
//            }
//        }
//    }
    
    private func canSendNotification() -> Bool {
        if let lastDate = lastNotificationDate {
            return Date().timeIntervalSince(lastDate) > notificationInterval
        }
        return true
    }
    

    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        // 获取 key window
        guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }

        // 遍历视图控制器以找到最上面的控制器
        var topController = window.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }

    
    func sendNotification() {
            guard canSendNotification() else {
                print("Notification cooldown in effect, not sending a new notification.")
                return
            }
            
            let alert = UIAlertController(title: "Take a Break!", message: "You are near a green space. Take a moment to relax and enjoy nature.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            if let topController = getTopViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
            
            lastNotificationDate = Date()
        }

    
    // Reverse geocode
    func reverseGeocodeLocation(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self.locationDescription = "Unknown place"
                return
            }
            
            if let name = placemark.name {
                self.locationDescription = name
                
                // 检查是否在绿地
                if name.lowercased().contains("park") || name.lowercased().contains("garden") {
                    if !self.isInGreenSpace { // 如果刚刚进入绿地
                        self.isInGreenSpace = true
                        self.sendNotification()
                        self.startGreenSpaceTimer()
//                        self.saveTimeInGreenSpaceToFirebase() // 进入时保存时间
                    }
                } else {
                    if self.isInGreenSpace { // 如果刚刚离开绿地
                        self.isInGreenSpace = false
                        self.stopGreenSpaceTimer()
//                        self.saveTimeInGreenSpaceToFirebase() // 离开时保存时间
                    }
                }
            }
        }
    }
    
    private func startGreenSpaceTimer() {
        stopGreenSpaceTimer() // 确保没有重复的计时器
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
        // 不重置时间，因为要在用户再次返回时继续计时
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
