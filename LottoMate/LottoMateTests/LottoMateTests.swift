//
//  LottoMateTests.swift
//  LottoMateTests
//
//  Created by Mirae on 7/23/24.
//

import XCTest
import RxSwift
import CoreLocation
import NMapsMap
@testable import LottoMate

final class LottoMateTests: XCTestCase {
    var viewController: MapViewController?
    var reactor: MapViewReactor?
    var disposeBag: DisposeBag?
//    var scheduler: TestScheduler?

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewController = MapViewController()
        reactor = MapViewReactor()
        viewController?.reactor = reactor
        disposeBag = DisposeBag()
//        scheduler = TestScheduler(initialClock: 0)
        
        // Load the view hierarchy
        viewController?.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        viewController = nil
        reactor = nil
        disposeBag = nil
//        scheduler = nil
        try super.tearDownWithError()
    }

    func testUpdateMarker() throws {
        guard let viewController = viewController else {
            XCTFail("ViewController is nil")
            return
        }
        
        // 서울시청
        let location1 = CLLocation(latitude: 37.550263, longitude: 126.9970831)
        // N서울타워
        let location2 = CLLocation(latitude: 37.5511694, longitude: 126.9882266)
        
        XCTAssertNil(viewController.currentMarker)
        
        viewController.updateMarker(at: location1)
        
        XCTAssertNotNil(viewController.currentMarker)
        XCTAssertEqual(viewController.currentMarker?.position.lat, location1.coordinate.latitude)
        XCTAssertEqual(viewController.currentMarker?.position.lng, location1.coordinate.longitude)
        
        let firstMarker = viewController.currentMarker
        
        viewController.updateMarker(at: location2)
        
        XCTAssertNotNil(viewController.currentMarker)
        XCTAssertNotEqual(viewController.currentMarker, firstMarker)
        XCTAssertEqual(viewController.currentMarker?.position.lat, location2.coordinate.latitude)
        XCTAssertEqual(viewController.currentMarker?.position.lng, location2.coordinate.longitude)
    }
}

final class LottoMatePureLogicTests: XCTestCase {
    func testGetLotteryTypeValue_WhenEmpty_ReturnsAll() {
        let result = getLotteryTypeValue(from: [])
        XCTAssertEqual(result.type, 0)
        XCTAssertEqual(result.title, "복권 전체")
    }
    
    func testGetLotteryTypeValue_WhenLottoAndPension_ReturnsExpectedType() {
        let result = getLotteryTypeValue(from: [.lotto, .pensionLottery])
        XCTAssertEqual(result.type, 4)
        XCTAssertEqual(result.title, "로또, 연금복권")
    }
    
    func testAppVersionManager_CheckUpdateType() {
        let forced = AppVersionManager.checkUpdateType(
            currentVersion: "1.0.0",
            forceUpdateVersion: "1.0.1",
            recommendedVersion: "1.0.3"
        )
        XCTAssertEqual(forced, .forced)
        
        let recommended = AppVersionManager.checkUpdateType(
            currentVersion: "1.0.2",
            forceUpdateVersion: "1.0.1",
            recommendedVersion: "1.0.3"
        )
        XCTAssertEqual(recommended, .recommended)
        
        let none = AppVersionManager.checkUpdateType(
            currentVersion: "1.0.4",
            forceUpdateVersion: "1.0.1",
            recommendedVersion: "1.0.3"
        )
        XCTAssertEqual(none, .none)
    }
    
    func testMockSampleData_LottoHome_DecodesSuccessfully() throws {
        let data = LottoMateEndpoint.getLottoHome.sampleData
        let decoded = try JSONDecoder().decode(LatestLotteryWinningInfoModel.self, from: data)
        
        XCTAssertEqual(decoded.code, 200)
        XCTAssertEqual(decoded.the645.lottoType, "L645")
    }
    
    func testMockSampleData_MapStoreList_DecodesSuccessfully() throws {
        let boundary = MapBoundary(
            leftLot: 126.9,
            leftLat: 37.4,
            rightLot: 127.2,
            rightLat: 37.6,
            personLot: 127.0,
            personLat: 37.5
        )
        let data = MapEndpoint.getStoreList(boundary: boundary).sampleData
        let decoded = try JSONDecoder().decode(StoreListResponse.self, from: data)
        
        XCTAssertEqual(decoded.code, 200)
        XCTAssertFalse(decoded.storeInfo.content.isEmpty)
    }
    
    func testMockSampleData_ReviewList_DecodesSuccessfully() throws {
        let data = WinningReviewEndpoint.getWinningReviewList(reviewNos: [1, 2, 3]).sampleData
        let decoded = try JSONDecoder().decode([WinningReviewListResponse].self, from: data)
        
        XCTAssertFalse(decoded.isEmpty)
        XCTAssertEqual(decoded.first?.reviewNo, 1201)
    }
}
