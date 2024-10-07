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


//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//
//    return true
//  }
//}


@main
 struct MobileAppNiuApp: App {
  // register app delegate for Firebase setup
//     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
     
     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
     
     @StateObject var manager = HealthManager()
     @StateObject var locationManager = LocationManager()

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .environmentObject(manager)
              .environmentObject(locationManager)
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
}
