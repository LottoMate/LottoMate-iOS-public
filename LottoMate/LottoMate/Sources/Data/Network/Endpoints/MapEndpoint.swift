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
        case .getStore(let storeNo):
            let store = makeMockStores(centerLat: mockDefaultLat, centerLot: mockDefaultLot)
                .first { $0.storeNo == storeNo } ?? makeMockStores(centerLat: mockDefaultLat, centerLot: mockDefaultLot)[0]
            return makeMockStoreListData(stores: [store], page: 1, size: 1, totalElements: 1)

        case let .getStoreList(boundary, type, page, size, _, _, _):
            let center = mockCenter(from: boundary)
            let filteredStores = makeMockStores(centerLat: center.lat, centerLot: center.lot)
                .filter { mockStore($0, supports: type) }
            let safePage = max(page, 1)
            let safeSize = max(size, 1)
            let startIndex = (safePage - 1) * safeSize
            let pagedStores = Array(filteredStores.dropFirst(startIndex).prefix(safeSize))

            return makeMockStoreListData(
                stores: pagedStores,
                page: safePage,
                size: safeSize,
                totalElements: filteredStores.count
            )

        case .toggleStoreLikeStatus, .checkStoreLikeStatus:
            return Data("{}".utf8)
        }
    }
}

private let mockDefaultLat = 37.5664991184072
private let mockDefaultLot = 126.968555570622

private func mockCenter(from boundary: MapBoundary) -> (lat: Double, lot: Double) {
    let lat = (boundary.leftLat + boundary.rightLat) / 2
    let lot = (boundary.leftLot + boundary.rightLot) / 2

    guard lat.isFinite, lot.isFinite, lat != 0, lot != 0 else {
        return (mockDefaultLat, mockDefaultLot)
    }

    return (lat, lot)
}

private func makeMockStores(centerLat: Double, centerLot: Double) -> [StoreDetailInfo] {
    return [
        StoreDetailInfo(
            storeNo: 1001,
            storeNm: "행운복권",
            storeTel: "02-111-2222",
            storeAddr: "서울 중구 새문안로 16 인근",
            addrLot: centerLot,
            addrLat: centerLat,
            lottoTypeList: ["L645", "L720", "S2000"],
            distance: "0.1km",
            lottoInfos: [
                LottoInfo(lottoType: "L645", place: 1, lottoJackpot: 2_300_000_000, drwNum: 1160),
                LottoInfo(lottoType: "L720", place: 2, lottoJackpot: 1_200_000_000, drwNum: 260)
            ]
        ),
        StoreDetailInfo(
            storeNo: 1002,
            storeNm: "로또명당",
            storeTel: "02-333-4444",
            storeAddr: "서울 중구 세종대로 110 인근",
            addrLot: centerLot + 0.0011,
            addrLat: centerLat + 0.0007,
            lottoTypeList: ["L645", "S1000"],
            distance: "0.2km",
            lottoInfos: [
                LottoInfo(lottoType: "L645", place: 2, lottoJackpot: 450_000_000, drwNum: 1158)
            ]
        ),
        StoreDetailInfo(
            storeNo: 1003,
            storeNm: "복권천국",
            storeTel: "02-555-6666",
            storeAddr: "서울 종로구 새문안로 92 인근",
            addrLot: centerLot - 0.0010,
            addrLat: centerLat - 0.0009,
            lottoTypeList: ["L720", "S2000"],
            distance: "0.2km",
            lottoInfos: [
                LottoInfo(lottoType: "L720", place: 1, lottoJackpot: 2_500_000_000, drwNum: 258)
            ]
        ),
        StoreDetailInfo(
            storeNo: 1004,
            storeNm: "황금복권",
            storeTel: "02-777-8888",
            storeAddr: "서울 서대문구 통일로 135 인근",
            addrLot: centerLot - 0.0004,
            addrLat: centerLat + 0.0014,
            lottoTypeList: ["L645", "L720"],
            distance: "0.3km",
            lottoInfos: [
                LottoInfo(lottoType: "L645", place: 3, lottoJackpot: 15_000_000, drwNum: 1157),
                LottoInfo(lottoType: "L720", place: 2, lottoJackpot: 100_000_000, drwNum: 257)
            ]
        ),
        StoreDetailInfo(
            storeNo: 1005,
            storeNm: "드림티켓",
            storeTel: "02-999-0000",
            storeAddr: "서울 중구 정동길 21 인근",
            addrLot: centerLot + 0.0015,
            addrLat: centerLat - 0.0012,
            lottoTypeList: ["S500", "S1000", "S2000"],
            distance: "0.3km",
            lottoInfos: [
                LottoInfo(lottoType: "S2000", place: 1, lottoJackpot: 1_000_000_000, drwNum: 64)
            ]
        )
    ]
}

private func mockStore(_ store: StoreDetailInfo, supports type: Int?) -> Bool {
    guard let type, type != 0 else { return true }

    let typeList = Set(store.lottoTypeList)

    switch type {
    case 1:
        return typeList.contains("L645")
    case 2:
        return typeList.contains("L720")
    case 3:
        return typeList.contains { $0.hasPrefix("S") }
    case 4:
        return typeList.contains("L645") || typeList.contains("L720")
    case 5:
        return typeList.contains("L645") || typeList.contains { $0.hasPrefix("S") }
    case 6:
        return typeList.contains("L720") || typeList.contains { $0.hasPrefix("S") }
    default:
        return true
    }
}

private func makeMockStoreListData(stores: [StoreDetailInfo], page: Int, size: Int, totalElements: Int) -> Data {
    let totalPages = max(Int(ceil(Double(totalElements) / Double(size))), 1)
    let response = StoreListResponse(
        message: "Success",
        code: 200,
        storeInfo: StorePagingInfo(
            pageNum: page,
            pageSize: size,
            totalPages: totalPages,
            totalElements: totalElements,
            content: stores
        )
    )

    do {
        return try JSONEncoder().encode(response)
    } catch {
        return Data("{}".utf8)
    }
}
