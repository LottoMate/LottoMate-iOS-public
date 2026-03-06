//
//  SampleData.swift
//  LottoMate
//
//  Created by Mirae on 8/3/24.
//  임시 픽커뷰에서 사용중

import Foundation

struct SampleDrawInfo {
    let drawNumber: Int
    let drawDate: String
    
    static var sampleData = [
        SampleDrawInfo(drawNumber: 1126, drawDate: "2024.06.29"),
        SampleDrawInfo(drawNumber: 1125, drawDate: "2024.06.22"),
        SampleDrawInfo(drawNumber: 1124, drawDate: "2024.06.15"),
        SampleDrawInfo(drawNumber: 1123, drawDate: "2024.06.08"),
        SampleDrawInfo(drawNumber: 1122, drawDate: "2024.06.01"),
    ]
}

struct SampleHtmlDoc {
    static var sampleData = 
    """
<div><br></div>
<div><span style="font-size: 14pt;">▶ 당첨되신 걸 어떻게 알게 되셨고, 또 알았을 때 기분이 어떠셨나요?&nbsp;</span></div>
<div><span style="font-size: 14pt;">-&gt; 매주 퇴근길에 로또복권과 연금복권을 구매하고 있습니다. 회사에서 안 좋은 일이 있어서 퇴근길에 술을 마셔야겠다는 생각이 들었습니다. 혼자 설렁탕집으로 가는 길에 복권판매점이 보였고, 평소처럼 로또복권과 연금복권을 구매했습니다. 며칠 후, 자주 가는 복권판매점에 방문해서 연금복권 당첨번호를 확인했는데 끝자리 번호만 일치한 걸 보고 7등에 당첨이 됐다고 생각했습니다. 판매점주에게 복권으로 교환을 요청했는데, 깜짝 놀란 목소리로 1등에 당첨됐다고 알려줬습니다. 다시 확인해 보니 1, 2등 동시에 당첨된 것이었고, 기분이 너무 좋았습니다. 기쁜 마음에 가족들에게 당첨 사실을 알렸습니다. 남들과 마찬가지로 막연하게 언젠가 당첨될 거로 생각했는데, 큰 행운이 저에게 찾아와서 감사한 마음입니다. 처음에는 당첨금을 일시불로 못 받는 거에 대해 아쉬움이 있었는데, 노후를 생각해 보니 연금식으로 받는 게 더 좋다고 생각이 들었습니다.</span></div>
<div><br></div>
<div><span style="font-size: 14pt;">▶ 최근 기억에 남는 꿈이 있으신가요?</span></div>
<div><span style="font-size: 14pt;">-&gt; 꿈을 꾸지 않았습니다.</span></div>
<div><br></div>
<div><span style="font-size: 14pt;">▶ 평소에 어떤 복권을 자주 구매하시나요?</span></div>
<div><span style="font-size: 14pt;">-&gt; 주로 로또복권과 연금복권을 구매합니다.</span></div>
<div><span style="font-size: 14pt;">&nbsp;</span></div>
<div><span style="font-size: 14pt;">▶ 당첨금은 어디에 사용하실 계획인가요?</span></div>
<div><span style="font-size: 14pt;">-&gt; 더 넓은 집으로 이사할 계획입니다.</span></div>

<div><span style="font-size: 14pt;"><br></span></div>
<div style="text-align: center;" align="center"><span style="font-size: 14pt;"><img src="/img/board/content/1723164312758.jpg" title="1723164312758.jpg"><br style="clear:both;"><br></span></div><div style="text-align: center;" align="center"></div><div style="text-align: center;"><span style="font-size: 18.6667px;"><img src="/img/board/content/1723164320613.jpg" title="1723164320613.jpg"><br style="clear:both;"><br></span></div>
"""
}

struct SampleSpeetoStoreModel: Identifiable {
    let id = UUID()
    let prizeTier: SpeetoPrizeTier
    let storeName: String
    let round: Int
    let prizePaymentDate: String
    
}

struct SampleSpeetoData {
    static var sampleData2000: [SampleSpeetoStoreModel] = [
        SampleSpeetoStoreModel(prizeTier: .firstPrize, storeName: "야단법석", round: 53, prizePaymentDate: "2024-06-05"),
        SampleSpeetoStoreModel(prizeTier: .firstPrize, storeName: "진짜진짜진짜진짜진짜긴복권판매점명한줄처리되는지확인", round: 53, prizePaymentDate: "2024-05-22"),
        
        SampleSpeetoStoreModel(prizeTier: .secondPrize, storeName: "로또나라", round: 53, prizePaymentDate: "2024-06-26"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "8888로또", round: 53, prizePaymentDate: "2024-06-26"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "천하면당 사당점", round: 53, prizePaymentDate: "2024-06-24"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "진짜진짜진짜진짜진짜긴복권판매점명한줄처리되는지확인", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
        SampleSpeetoStoreModel(prizeTier: .secondPrize,storeName: "판매점명", round: 53, prizePaymentDate: "YYYY-MM-DD"),
    ]
}

struct StoreInfoSampleData {
    static var drwtList: [DrwtList] = [
        DrwtList(type: "L720", prizeMoney: "25억원", lottoRndNum: "6102", drwtDate: ""),
        DrwtList(type: "S2000", prizeMoney: "24억원", lottoRndNum: "52", drwtDate: ""),
        DrwtList(type: "L645", prizeMoney: "23억원", lottoRndNum: "5016", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "22억원", lottoRndNum: "5999", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "21억원", lottoRndNum: "4102", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "20억원", lottoRndNum: "111", drwtDate: ""),
        DrwtList(type: "S2000", prizeMoney: "25억원", lottoRndNum: "222", drwtDate: ""),
        DrwtList(type: "S2000", prizeMoney: "24억원", lottoRndNum: "333", drwtDate: ""),
        DrwtList(type: "L645", prizeMoney: "23억원", lottoRndNum: "444", drwtDate: ""),
        DrwtList(type: "S2000", prizeMoney: "22억원", lottoRndNum: "555", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "21억원", lottoRndNum: "666", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "25억원", lottoRndNum: "777", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "24억원", lottoRndNum: "888", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "21억원", lottoRndNum: "666", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "25억원", lottoRndNum: "777", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "24억원", lottoRndNum: "888", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "21억원", lottoRndNum: "666", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "25억원", lottoRndNum: "777", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "24억원", lottoRndNum: "888", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "21억원", lottoRndNum: "666", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "25억원", lottoRndNum: "777", drwtDate: ""),
        DrwtList(type: "L720", prizeMoney: "24억원", lottoRndNum: "888", drwtDate: ""),
    ]
}

// MARK: 내 로또 내역 샘플 데이터
struct LotteryResponse: Codable {
   let response: LotteryResults
}

enum MyLotteryNumberType: String, Codable {
   case lotto645 = "L645"
   case lotto720 = "L720"
}

struct LotteryResults: Codable {
   let lotteryResults: [LotteryResult]
}

struct LotteryResult: Codable {
   let type: MyLotteryNumberType
   let round: String
   let numbers: [Int]
   let drawDate: String
}

// MARK: 샘플 JSON 데이터 로드
class JSONLoader {
    static func loadStoreInfo() -> StoreInfoModel? {
        guard let url = Bundle.main.url(forResource: "StoreInfoSampleData", withExtension: "json") else {
            print("loadStoreInfo - JSON file not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let storeInfo = try decoder.decode(StoreInfoModel.self, from: data)
            return storeInfo
        } catch {
            print("loadStoreInfo - Error decoding JSON: \(error)")
            return nil
        }
    }
    
    static func loadStoreList() -> StoreListModel? {
        guard let url = Bundle.main.url(forResource: "StoreInfoSampleData", withExtension: "json") else {
            print("loadStoreList - JSON file not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let storeInfo = try decoder.decode(StoreListModel.self, from: data)
            return storeInfo
        } catch {
            print("loadStoreInfo - Error decoding JSON: \(error)")
            return nil
        }
    }
    
    static func loadMyLottoNumbers() -> LotteryResponse? {
        guard let url = Bundle.main.url(forResource: "MyLottoNumbersSampleData", withExtension: "json") else {
            print("loadMyLottoNumbers - JSON file not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let lotteryResponse = try decoder.decode(LotteryResponse.self, from: data)
            return lotteryResponse
        } catch {
            print(print("loadMyLottoNumbers - Error decoding JSON: \(error)"))
            return nil
        }
    }
}


