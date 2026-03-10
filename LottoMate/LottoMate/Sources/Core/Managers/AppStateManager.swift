//
//  AppStateManager.swift
//  LottoMate
//
//  Created by Mirae on 2/19/25.
//

import Foundation

class AppStateManager {
    static let shared = AppStateManager()
    private init() {}
    
    var isFirstLaunch: Bool {
        let hasLaunchBefore = UserDefaults.standard.bool(forKey: "hasLaunchBefore")
        
        if !hasLaunchBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchBefore")
            return true
        }
        return false
    }
}
