//
//  SpeetoType.swift
//  LottoMate
//
//  Created by Mirae on 3/10/26.
//

import Foundation

enum SpeetoType: String {
    case s500 = "S500"  // API 값을 rawValue로 사용
    case s1000 = "S1000"
    case s2000 = "S2000"
    
    var displayName: String {
        switch self {
        case .s500: return "스피또 500"
        case .s1000: return "스피또 1000"
        case .s2000: return "스피또 2000"
        }
    }
    
    var buttonText: String {
        switch self {
        case .s500: return "500"
        case .s1000: return "1000"
        case .s2000: return "2000"
        }
    }
    
    // the500 등 기존 값으로도 접근 가능하도록 정적 프로퍼티 제공 (필요한 경우)
    static let the500 = SpeetoType.s500
    static let the1000 = SpeetoType.s1000
    static let the2000 = SpeetoType.s2000
}
