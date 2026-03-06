//
//  BannerType.swift
//  LottoMate
//
//  Created by Mirae on 12/18/24.
//

import UIKit

typealias BannerAction = () -> Void

enum BannerType {
    case winningStore
    case winnerReview
    case getRandomLottoNumbers
    case expandServicetoMyArea
    case winningLottoInfo
    case qrCodeScanner
    case winnerGuide
    // TODO: 투표 관련 배너는 투표 서비스가 제외되어 제거함
    
    var configuration: BannerConfiguration {
        switch self {
        case .winningStore:
            return BannerConfiguration(
                backgroundColor: .yellow5,
                title: "행운의 1등 로또\r어디서 샀을까?",
                body: "당첨 판매점 보러가기",
                imageName: "banner_map",
                imageSize: (124, 78)
            )
        case .winnerReview:
            return BannerConfiguration(
                backgroundColor: .peach5,
                title: "로또 1등 당첨\r기 받아가요",
                body: "당첨자 후기 보러가기",
                imageName: "banner_confetti",
                imageSize: (124, 78)
            )
        case .winnerGuide:
            return BannerConfiguration(
                backgroundColor: .blue5,
                title: "로또 당첨이 됐다면\r이렇게 하세요",
                body: "당첨 가이드 보러가기",
                imageName:  "banner_winners",
                imageSize: (124, 78)
            )
        case .winningLottoInfo:
            return BannerConfiguration(
                backgroundColor: .green5,
                title: "두구두구두구\r로또 당첨 발표",
                body: "당첨 로또 정보 확인하기",
                imageName: "banner_winningInfo",
                imageSize: (124, 78)
            )
        case .qrCodeScanner:
            return BannerConfiguration(
                backgroundColor: .blue10,
                title: "내 로또 당첨 결과\r빠르게 보고 싶다면?",
                body: "QR로 당첨 확인하기",
                imageName: "banner_QRcode",
                imageSize: (124, 78)
            )
        case .getRandomLottoNumbers:
            return BannerConfiguration(
                backgroundColor: .yellow10,
                title: "나만의 로또 번호를\r뽑아봐요!",
                body: "로또 번호 뽑으러 가기",
                imageName: "banner_cart",
                imageSize: (124, 78)
            )
        case .expandServicetoMyArea:
            return BannerConfiguration(
                backgroundColor: .peach10,
                title: "우리 동네 로또 명당\r알고 싶어요",
                body: "지도 오픈 요청하기",
                imageName: "banner_myTown",
                imageSize: (124, 78)
            )
        }
    }
}

struct BannerConfiguration {
    let backgroundColor: UIColor
    let title: String
    let body: String
    let imageName: String?
    let imageSize: (width: Double, height: Double)
}
