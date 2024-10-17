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
    static let shared = LocationManager() // 单例实例
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
    private var currentLocationName: String = "" // 用于存储当前地名
    private var previousLocationName: String = "" // 用于存储上一个地名

    private override init() { // 防止外部初始化
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
    
    // 反向地理编码
    func reverseGeocodeLocation(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self.locationDescription = "Unknown place"
                return
            }
            
            if let name = placemark.name {
                self.locationDescription = name
                self.currentLocationName = name // 存储当前地名
                
                // 检查位置变化
                self.checkLocationChange()
            }
        }
    }
    
    private func checkLocationChange() {
        // 仅在地名发生变化时检查
        if currentLocationName != previousLocationName {
            previousLocationName = currentLocationName // 更新上一个地名
            
            // 检查当前地点名称是否包含"park"或"garden"
            if currentLocationName.lowercased().contains("park") || currentLocationName.lowercased().contains("garden") {
                if !isInGreenSpace { // 如果刚刚进入绿地
                    isInGreenSpace = true
                    startGreenSpaceTimer()
                }
            } else {
                if isInGreenSpace { // 如果刚刚离开绿地
                    isInGreenSpace = false
                    stopGreenSpaceTimer()
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
