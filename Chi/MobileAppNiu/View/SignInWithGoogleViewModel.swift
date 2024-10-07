//
//  SignInWithGoogleViewModel.swift
//  MobileAppNiu
//
//  Created by 关昊 on 7/10/2024.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

class SignInWithGoogleViewModel: ObservableObject{
    
    @Published var isLoginSuccessed = false
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Applicaiton_utility.rootViewController){ user, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard
                let user = user?.user,
                let idToken = user.idToken else {return}
            
                let accessToken = user.accessToken
            
                let cridential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
                Auth.auth().signIn(with: cridential) { res, error in
                if let error = error {
                    print (error.localizedDescription)
                    return
                }
                    
                guard let user = res?.user else { return }
                print (user)
                
                    
                self.logStatus = true
            }

        }
    }
}
