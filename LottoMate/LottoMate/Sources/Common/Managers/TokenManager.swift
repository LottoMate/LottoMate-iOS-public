//
//  TokenManager.swift
//  LottoMate
//
//  Created by Mirae on 12/9/24.
//

import KeychainSwift

class TokenManager {
    static let shared = TokenManager()
    private let keyChain = KeychainSwift()
    
    func saveToken(_ token: String) {
        keyChain.set(token, forKey: "accessToken")
    }
    
    func getToken() -> String? {
        keyChain.get("accessToken")
    }
}

