//
//  MobileAppNiuApp.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
 struct MobileAppNiuApp: App {
  // register app delegate for Firebase setup
     @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
     @StateObject var manager = HealthManager()
     
  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .environmentObject(manager)
      }
    }
  }
}
