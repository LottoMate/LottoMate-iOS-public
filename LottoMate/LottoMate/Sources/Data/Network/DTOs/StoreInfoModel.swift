//
//  StoreInfoModel.swift
//  LottoMate
//
//  Created by Mirae on 10/8/24.
//

import Foundation
import UIKit

// MARK: - 지점 정보
struct StoreInfoModel: Codable {
    let code, message: String
    let storeInfo: StoreInfo

    enum CodingKeys: String, CodingKey {
        case code, message
        case storeInfo = "store_info"
    }
}

// MARK: - 지점 리스트 보기
struct StoreListModel: Codable {
    let code, message: String
    let storeInfo: [StoreInfo]

    enum CodingKeys: String, CodingKey {
        case code, message
        case storeInfo = "store_info"
    }
}

// MARK: - StoreInfo
struct StoreInfo: Codable {
    let name, phoneNum, addrLot, addrLat: String
    let address: String
    let drwtCount: [String]
    let drwtList: [DrwtList]
}

// MARK: - DrwtList
struct DrwtList: Codable {
    let type, prizeMoney, lottoRndNum, drwtDate: String
    
    var typeText: String {
        switch type {
        case "L645":
            return "로또 1등"
        case "L720":
            return "연금복권 1등"
        case "S500":
            return "스피또 500 1등"
        case "S1000":
            return "스피또 1000 1등"
        case "S2000":
            return "스피또 2000 1등"
        default:
            return "1등"
        }
    }
    
    var backgroundColor: UIColor {
        switch type {
        case "L645":
            return .green5
        case "L720":
            return .blue5
        case "S500":
            return .peach5
        case "S1000":
            return .peach5
        case "S2000":
            return .peach5
        default:
            return .green5
        }
    }
}

