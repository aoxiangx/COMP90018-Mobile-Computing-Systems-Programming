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
    
    
    //
    @State private var errorMessage : String = ""
    @State private var showAlert : Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var nonce: String?
    
    @State private var isLoading: Bool = false
    
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        ZStack(alignment : .bottom){
            GeometryReader {
                let size = $0.size
//                Image(.BG)
//                    .resizable()
//                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
//                    .offset(y: -60 )
//                    .frame(width: size.width, height: size.height)
                LinearGradient(
                        gradient: Gradient(colors: [
                            Color
                            .yellow.opacity(0.55),
                            .yellow.opacity(0.5),
                            .yellow.opacity(0.4),
                            .yellow.opacity(0.3),
                            .yellow.opacity(0.2),
                            .yellow.opacity(0.1),
                            .yellow.opacity(0.1),
                            .yellow.opacity(0.1),
                            .clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: size.width, height: size.height)
            }
            .ignoresSafeArea()
            
            // login button
            VStack(alignment: .leading){
                Text("niuniu")
                
                // apple login button
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
                
                
                // fake button for login without apple developer account
                
                Button(action: {
                                // 模拟登录成功，直接将 logStatus 设置为 true
                                logStatus = true
                            }) {
                                HStack {
                                    Image(systemName: "applelogo")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Sign in with Click")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                .frame(height: 45)
                                .frame(maxWidth: .infinity)
                                .background(colorScheme == .dark ? Color.white : Color.black)
                                .clipShape(Capsule())
                            }
                
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding()
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
