//
//  SignInViewModel.swift
//  LottoMate
//
//  Created by Mirae on 10/11/24.
//

import Foundation
import GoogleSignIn
import Moya

final class LoginViewModel {
    static let shared = LoginViewModel()
    private let provider: MoyaProvider<LottoMateEndpoint> = NetworkProviderFactory.makeProvider()
    
    func googleSignIn() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                
                if let error = error {
                    print("Error during Google Sign-In: \(error.localizedDescription)")
                    return
                }
                
                guard let signInResult = signInResult else {
                    print("No sign-in result available")
                    return
                }
                
                signInResult.user.refreshTokensIfNeeded { user, error in
                    guard error == nil else { return }
                    guard let user = user else { return }
                    
                    if let idToken = user.idToken?.tokenString {
                        // Send ID token to backend.
                        self.sendGoogleTokenToServer(idToken: idToken)
//                        TokenManager.shared.saveToken(idToken)
                    }
                    
                    _ = user.accessToken
//                    TokenManager.shared.saveToken(accessToken.tokenString)
                }
            }
        } else {
            print("googleSignIn() - No root view controller found!")
        }
    }
    
    private func sendGoogleTokenToServer(idToken: String) {
        provider.request(.googleTokenSignIn(idToken: idToken)) { result in
            switch result {
            case .success(let response):
                // JWT 토큰 응답 처리
                let statusCode = response.statusCode
                print("sendGoogleTokenToServer() statusCode - \(statusCode)")
                if let token = String(data: response.data, encoding: .utf8), !token.isEmpty {
                    //                    TokenManager.shared.saveToken(token)
                }
                
            case .failure(let error):
                print("Failed to send Google token to server: \(error.localizedDescription)")
            }
        }
    }
}
