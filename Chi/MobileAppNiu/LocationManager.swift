//
//  LocationManager.swift
//  MobileAppNiu
//
//  Created by 关昊 on 6/10/2024.
//

import Foundation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject{
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    
    private let locationManager = CLLocationManager()
    
    
    private let geocoder = CLGeocoder()
    @Published var locationDescription: String = "Unknown"
    
    
    
    override init(){
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation() // remember to update info.plist
        locationManager.delegate = self
    }
    
    
    // 反向地理编码方法
    func reverseGeocodeLocation(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                self.locationDescription = "Unknown place"
                return
            }
            
            // 解析地标信息
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

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:
                         [CLLocation]){
        guard let location = locations.last else{return}
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        
        // 反向地理编码
        reverseGeocodeLocation(location: location)
    }
}
