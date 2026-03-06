//
//  GetStoresByLottoTypeResponse.swift
//  LottoMate
//
//  Created by Mirae on 2/20/25.
//

import Foundation

// MARK: - StoreListResponse
struct StoreListResponse: Codable {
    let message: String
    let code: Int
    let storeInfo: StorePagingInfo

    enum CodingKeys: String, CodingKey {
        case message, code
        case storeInfo = "store_info"
    }
}

// MARK: - StorePagingInfo
struct StorePagingInfo: Codable {
    let pageNum, pageSize, totalPages, totalElements: Int
    let content: [StoreDetailInfo]
}

// MARK: - 판매점 정보
struct StoreDetailInfo: Codable, Equatable {
    let storeNo: Int
    let storeNm, storeTel, storeAddr: String
    let addrLot, addrLat: Double
    let lottoTypeList: [String]
    let distance: String
    let lottoInfos: [LottoInfo]
}

// MARK: - 로또 당첨 정보
struct LottoInfo: Codable, Equatable {
    let lottoType: String
    let place: Int
    let lottoJackpot: Int?
    let drwNum: Int
}

/**
 예시 응답값
 {
     "message": "Success",
     "code": 200,
     "store_info": {
         "pageNum": 1,
         "pageSize": 10,
         "totalPages": 1,
         "totalElements": 5,
         "content": [
             {
                 "storeNo": 1133,
                 "storeNm": "신명",
                 "storeTel": "02-2663-6500",
                 "storeAddr": "서울 강서구 방화동로3길 1 1층",
                 "addrLot": 126.808444,
                 "addrLat": 37.56244,
                 "lottoTypeList": [
                     "L645",
                     "L720",
                     "S1000",
                     "S2000"
                 ]
             },
             {
                 "storeNo": 1136,
                 "storeNm": "9TO5공항점",
                 "storeTel": "02-2666-0250",
                 "storeAddr": "서울 강서구 송정로 61 1층",
                 "addrLot": 126.809859,
                 "addrLat": 37.560268,
                 "lottoTypeList": [
                     "L645",
                     "L720",
                     "S500",
                     "S1000",
                     "S2000"
                 ]
             },
             {
                 "storeNo": 1144,
                 "storeNm": "미나식품(로또판매점)",
                 "storeTel": "02-2664-6793",
                 "storeAddr": "서울 강서구 금낭화로 91 1층",
                 "addrLot": 126.810688,
                 "addrLat": 37.573512,
                 "lottoTypeList": [
                     "L645",
                     "L720",
                     "S500",
                     "S1000",
                     "S2000"
                 ]
             },
             {
                 "storeNo": 2075,
                 "storeNm": "복권명당 오복점",
                 "storeTel": "02-2662-1989",
                 "storeAddr": "서울 강서구 방화동로5길 3 1층",
                 "addrLot": 126.810248,
                 "addrLat": 37.563739,
                 "lottoTypeList": [
                     "L645",
                     "L720",
                     "S1000",
                     "S2000"
                 ]
             },
             {
                 "storeNo": 2580,
                 "storeNm": "함지박복권",
                 "storeTel": "",
                 "storeAddr": "서울 강서구 양천로 28 120호",
                 "addrLot": 126.806915,
                 "addrLat": 37.572433,
                 "lottoTypeList": [
                     "L645",
                     "L720",
                     "S500",
                     "S1000",
                     "S2000"
                 ]
             }
         ]
     }
 }
 */
