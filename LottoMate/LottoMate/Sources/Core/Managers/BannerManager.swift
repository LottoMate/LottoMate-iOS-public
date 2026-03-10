//
//  BannerManager.swift
//  LottoMate
//
//  Created by Mirae on 12/20/24.
//

import Foundation

class BannerManager {
    static let shared = BannerManager()
    
    private init() {}
    
    func createRandomBanner(navigationDelegate: BannerNavigationDelegate) -> BannerView {
        let allCases: [BannerType] = [
            .winningStore,
            .winnerReview,
            .getRandomLottoNumbers,
            .expandServicetoMyArea,
            .winningLottoInfo,
            .qrCodeScanner,
            .winnerGuide
        ]
        let randomType = allCases.randomElement()!
        return BannerView(bannerType: randomType, navigationDelegate: navigationDelegate)
    }
    
    // 테스트나 디버깅용으로 특정 타입의 배너를 생성하는 메서드
    func createBanner(type: BannerType, navigationDelegate: BannerNavigationDelegate) -> BannerView {
        return BannerView(bannerType: type, navigationDelegate: navigationDelegate)
    }
}
