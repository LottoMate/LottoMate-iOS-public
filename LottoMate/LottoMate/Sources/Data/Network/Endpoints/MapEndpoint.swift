//
//  MapEndPoint.swift
//  LottoMate
//
//  Created by Mirae on 2/20/25.
//

import Foundation
import Moya

// 클라에서 좌표 범위를 보내야 한다면 이용할 모델
struct MapBoundary: Encodable {
    let leftLot: Double
    let leftLat: Double
    let rightLot: Double
    let rightLat: Double
    let personLot: Double
    let personLat: Double
}

/// 선택된 복권 타입에 따라 API 요청에 사용할 type 값을 반환하는 함수
func getLotteryTypeValue(from types: [LotteryType]) -> (type: Int, title: String) {
    if types.isEmpty {
        return (0, "복권 전체")
    }
    
    let hasLotto = types.contains(.lotto)
    let hasPensionLottery = types.contains(.pensionLottery)
    let hasSpeeto = types.contains(.speeto)
    
    if hasLotto && !hasPensionLottery && !hasSpeeto {
        return (1, "로또") // 645만 선택
    } else if !hasLotto && hasPensionLottery && !hasSpeeto {
        return (2, "연금복권") // 720(연금복권)만 선택
    } else if !hasLotto && !hasPensionLottery && hasSpeeto {
        return (3, "스피또") // 스피또만 선택
    } else if hasLotto && hasPensionLottery && !hasSpeeto {
        return (4, "로또, 연금복권") // 645, 720 선택
    } else if hasLotto && !hasPensionLottery && hasSpeeto {
        return (5, "로또, 스피또") // 645, 스피또 선택
    } else if !hasLotto && hasPensionLottery && hasSpeeto {
        return (6, "연금복권, 스피또") // 720, 스피또 선택
    } else if hasLotto && hasPensionLottery && hasSpeeto {
        return (0, "복권 전체") // 모두 선택 (ALL)
    }
    
    return (0, "복권 전체")
}

enum MapEndpoint {
    /// 가게 정보 1개 조회
    case getStore(storeNo: Int)
    /**
    가게 정보 리스트 조회
     - Parameters:
         - boundary: 지도 영역 좌표 (필수)
         - type: 복권 타입 (기본값: 0 - 모두)
            1 - 645 /
            2 - 720 /
            3 - 스피또 /
            4 - 645, 720 /
            5 - 645, 스피또 /
            6 - 720, 스피또 /
            default - ALL (0)
         - page: 페이지 번호 (기본값: 1)
         - size: 페이지당 개수 (기본값: 10)
         - drwtStore: 당첨 판매점만 조회 (기본값: false)
         - dis: 거리순 정렬 (기본값: true - 가까운 순)
         - like: 찜한 판매점만 조회 (기본값: false)
     */
    case getStoreList(
        boundary: MapBoundary,
        type: Int? = nil,
        page: Int = 1,
        size: Int = 10,
        drwtStore: Bool? = nil,
        dis: Bool? = nil,
        like: Bool? = nil
    )
    /// 판매점 찜하기 (취소하기)
    case toggleStoreLikeStatus(storeNo: Int)
    /// 판매점 찜 조회
    case checkStoreLikeStatus(storeNo: Int)
}

extension MapEndpoint: TargetType {
    var baseURL: URL {
        if NetworkModeManager.shouldUseMock {
            return URL(string: "https://mock.lottomate.local")!
        }
        
        guard
            let scheme = Bundle.main.object(forInfoDictionaryKey: "ApiServerScheme") as? String,
            let host = Bundle.main.object(forInfoDictionaryKey: "ApiServerHost") as? String,
            let port = Bundle.main.object(forInfoDictionaryKey: "ApiServerPort") as? String,
            let url = URL(string: "\(scheme)://\(host):\(port)")
        else {
            fatalError("API base URL is not set correctly in Info.plist")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getStore(let storeNo):
            return "/store/\(storeNo)"
        case .getStoreList:
            return "/store/list"
        case .toggleStoreLikeStatus(let storeNo):
            return "/store/\(storeNo)/like"
        case .checkStoreLikeStatus(let storeNo):
            return "/store/\(storeNo)/like"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getStore:
            return .get
        case .getStoreList:
            return .post
        case .toggleStoreLikeStatus:
            return .post
        case .checkStoreLikeStatus:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getStore:
            return .requestPlain
            
        case let .getStoreList(boundary, type, page, size, drwtStore, dis, like):
            // Body parameters (지도 영역 좌표)
            let bodyParameters: [String: Any] = [
                "leftLot": boundary.leftLot,
                "leftLat": boundary.leftLat,
                "rightLot": boundary.rightLot,
                "rightLat": boundary.rightLat,
                "personLot": boundary.personLot,
                "personLat": boundary.personLat
            ]
            
            // URL parameters (옵션)
            var urlParameters: [String: Any] = [
                "page": page,
                "size": size
            ]
            
            // 옵션 파라미터들은 nil이 아닐 때만 추가
            if let type = type {
                urlParameters["type"] = type
            }
            
            if let drwtStore = drwtStore {
                urlParameters["drwtStore"] = drwtStore
            }
            
            if let dis = dis {
                urlParameters["dis"] = dis
            }
            
            if let like = like {
                urlParameters["like"] = like
            }
            
            return .requestCompositeParameters(
                bodyParameters: bodyParameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: urlParameters
            )
            
        case .toggleStoreLikeStatus:
            return .requestPlain
            
        case .checkStoreLikeStatus:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .getStore:
            return Data(
                """
                {
                  "message":"Success",
                  "code":200,
                  "store_info":{
                    "pageNum":1,
                    "pageSize":1,
                    "totalPages":1,
                    "totalElements":1,
                    "content":[
                      {
                        "storeNo":1001,
                        "storeNm":"행운복권방",
                        "storeTel":"02-111-2222",
                        "storeAddr":"서울 강남구 테헤란로 100",
                        "addrLot":127.0276,
                        "addrLat":37.4979,
                        "lottoTypeList":["L645","L720","S2000"],
                        "distance":"0.4km",
                        "lottoInfos":[
                          {"lottoType":"L645","place":1,"lottoJackpot":2300000000,"drwNum":1160}
                        ]
                      }
                    ]
                  }
                }
                """.utf8
            )
            
        case .getStoreList:
            return Data(
                """
                {
                  "message":"Success",
                  "code":200,
                  "store_info":{
                    "pageNum":1,
                    "pageSize":10,
                    "totalPages":1,
                    "totalElements":3,
                    "content":[
                      {
                        "storeNo":1001,
                        "storeNm":"행운복권방",
                        "storeTel":"02-111-2222",
                        "storeAddr":"서울 강남구 테헤란로 100",
                        "addrLot":127.0276,
                        "addrLat":37.4979,
                        "lottoTypeList":["L645","L720","S2000"],
                        "distance":"0.4km",
                        "lottoInfos":[
                          {"lottoType":"L645","place":1,"lottoJackpot":2300000000,"drwNum":1160},
                          {"lottoType":"L720","place":2,"lottoJackpot":1200000000,"drwNum":260}
                        ]
                      },
                      {
                        "storeNo":1002,
                        "storeNm":"로또명당",
                        "storeTel":"02-333-4444",
                        "storeAddr":"서울 서초구 서초대로 220",
                        "addrLot":127.0154,
                        "addrLat":37.4918,
                        "lottoTypeList":["L645","S1000"],
                        "distance":"1.1km",
                        "lottoInfos":[
                          {"lottoType":"L645","place":2,"lottoJackpot":450000000,"drwNum":1158}
                        ]
                      },
                      {
                        "storeNo":1003,
                        "storeNm":"복권천국",
                        "storeTel":"02-555-6666",
                        "storeAddr":"서울 송파구 송파대로 80",
                        "addrLot":127.1051,
                        "addrLat":37.5146,
                        "lottoTypeList":["L720","S2000"],
                        "distance":"2.3km",
                        "lottoInfos":[
                          {"lottoType":"L720","place":1,"lottoJackpot":2500000000,"drwNum":258}
                        ]
                      }
                    ]
                  }
                }
                """.utf8
            )
            
        case .toggleStoreLikeStatus, .checkStoreLikeStatus:
            return Data("{}".utf8)
        }
    }
}
