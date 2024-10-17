//
//  LocationView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 6/10/2024.
//

import SwiftUI

struct LocationView: View {
    
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 10) {
            
            Divider()
                .padding(.vertical, 10)
            
            
            Text("Your Current Location")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text("Place Description:")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(locationManager.locationDescription)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
            
            Divider()
                .padding(.vertical, 10)
            
            HStack {
                Text("Latitude:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(String(format: "%.5f", locationManager.location?.coordinate.latitude ?? 0.0))
                    .font(.body)
            }
            
            HStack {
                Text("Longitude:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(String(format: "%.5f", locationManager.location?.coordinate.longitude ?? 0.0))
                    .font(.body)
            }
            
            Divider()
                .padding(.vertical, 10)
        }
    }
}

#Preview {
    LocationView()
        .environmentObject(LocationManager.shared)
}
