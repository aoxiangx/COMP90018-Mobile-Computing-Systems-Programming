//
//  LoginView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAuth
import CryptoKit


struct LoginView: View {
    
    @State private var errorMessage : String = ""
    @State private var showAlert : Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var nonce: String?
    
    @State private var isLoading: Bool = false
    
    @AppStorage("log_Status") private var logStatus: Bool = false
/*
 Check my precious font, Dont Move and Look for Red Hat Display Bold, Regular and Roboto Regular in Console PLZ
 --------
    init(){
        for familyName in UIFont.familyNames{
            print(familyName)
            for fontName in UIFont.fontNames(forFamilyName: familyName){
                print("-- \(fontName)")
            }
        }
    }
 */
    
    var body: some View {
        
        
        ZStack(alignment : .bottom){
            
            
            LinearGradient(gradient: Gradient(stops: [
                           .init(color: Color(hex: "FFF8C9"), location: 0.0),  // 开始颜色 FFF8C9
                           .init(color: Color(hex: "EDF5FF"), location: 0.6)   // 结束颜色 EDF5FF
                       ]),
                                      startPoint: .topLeading,
                                      endPoint: .bottomTrailing)
                       .edgesIgnoringSafeArea(.all)  // 填满整个屏幕
            
            
            // login button
            VStack(alignment: .leading){
                Text("Chi")
                    .font(.custom("RedHatDisplay-Regular", size: 48))
                
                
//                SignInWithAppleButton(.signIn){ request in
//                    let nonce = randomNonceString()
//                    self.nonce = nonce
//                    request.requestedScopes = [.email, .fullName]
//                    request.nonce = sha256(nonce)
//                } onCompletion: { result in
//                    switch result{
//                    case .success(let auth):
//                        loginWithFirebase(auth)
//                    case .failure(let error):
//                        showErrorMessage(error.localizedDescription )
//                    }
//                    
//                }.frame(height: 45)
//                // 胶囊
//                    .clipShape(.capsule)
//                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white: .black)
                
                
                Button(action: {
                            // 模拟登录成功，直接将 logStatus 设置为 true
                            logStatus = true
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.system(size: 16, weight: .bold))
                        Text("Sign in with Apple")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity)  // 使按钮占据父视图的全部宽度
                    .background(colorScheme == .dark ? Color.white : Color.black)
                    .clipShape(Capsule())
                }  // 适当的内边距让按钮看起来更加美观
                
                
                
                
                
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .alert(errorMessage, isPresented: $showAlert){
        }
        .overlay{
            if isLoading{
                loadingScreen()
            }
        }
    }
    
    
    // loading screen
    @ViewBuilder
    func loadingScreen() -> some View{
        ZStack{
            Rectangle()
                .fill(.ultraThinMaterial)
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: .rect(cornerRadius: 5))
        }
    }
    
    // show error message
    func showErrorMessage(_ message:  String){
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    // login with firebase
    func loginWithFirebase(_ authorization: ASAuthorization){
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // show loding screen until finished
            isLoading = true
            
              guard let nonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                  showErrorMessage("Can't process your request!")
                  return
              }
              guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
                  showErrorMessage("Can't process your request!")
                return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                  showErrorMessage("Can't process your request!")
                return
              }
              // Initialize a Firebase credential, including the user's full name.
              let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                rawNonce: nonce,
                                                                fullName: appleIDCredential.fullName)
              // Sign in with Firebase.
              Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                  // Error. If error.code == .MissingOrInvalidNonce, make sure
                  // you're sending the SHA256-hashed nonce as a hex string with
                  // your request to Apple.
                  showErrorMessage(error.localizedDescription)
                }
                  // User is signed in to Firebase with Apple.
                  
                  // pushing user to home view
                  isLoading = false
                  logStatus = true
              }
            
            }
    }
    
    
    // code from firebase database
    private func randomNonceString(length: Int = 32) -> String {
          precondition(length > 0)
          var randomBytes = [UInt8](repeating: 0, count: length)
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }

          let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

          let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
          }

          return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
          let inputData = Data(input.utf8)
          let hashedData = SHA256.hash(data: inputData)
          let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
          }.joined()

          return hashString
    }

    
    
    
    
}

#Preview {
    ContentView()
}
