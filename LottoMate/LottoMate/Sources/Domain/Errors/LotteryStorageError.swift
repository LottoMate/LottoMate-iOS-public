//
//  LotteryStorageError.swift
//  LottoMate
//
//  Created by Mirae on 3/10/26.
//

import Foundation

enum LotteryStorageError: Error, LocalizedError {
    case entryNotFound
    case saveError
    case loadError
    
    var errorDescription: String? {
        switch self {
        case .entryNotFound:
            return "해당 복권 번호를 찾을 수 없습니다."
        case .saveError:
            return "복권 번호 저장에 실패했습니다."
        case .loadError:
            return "복권 번호 불러오기에 실패했습니다."
        }
    }
}
