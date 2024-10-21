//
//  MobileAppNiuApp.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift



@main
 struct MobileAppNiuApp: App {
     // register app delegate for Firebase setup
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
     
     @StateObject var healthManager = HealthManager.shared
     var locationManager = LocationManager.shared

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .environmentObject(healthManager)
              .environmentObject(locationManager)
              .preferredColorScheme(.light)
              .onAppear {
                  // Force the app to be in portrait mode when it launches
                  UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                  AppDelegate.orientationLock = .portrait
              }
      }
    }
  }
}



class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey :
                                                                        Any]? = nil) -> Bool{
        FirebaseApp.configure()
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options:
                     [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            // Lock the app to portrait orientation
            return AppDelegate.orientationLock
    }
}
