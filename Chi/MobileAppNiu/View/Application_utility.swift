//
//  Application_utility.swift
//  MobileAppNiu
//
//  Created by 关昊 on 7/10/2024.
//

import Foundation
import SwiftUI
import UIKit
final class Applicaiton_utility {
    static var rootViewController: UIViewController {
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        return root
    }
}
