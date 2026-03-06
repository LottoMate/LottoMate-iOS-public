//
//  LottoMateError.swift
//  LottoMate
//
//  Created by Mirae on 10/22/24.
//

import Foundation

enum LottoMateError: Error {
    case noSampleStoreData
    case invalidStoreCoordinates(storeName: String)
    case failedToAddMarkers(reason: String)
    case emptyMapBoundary
}

extension LottoMateError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noSampleStoreData:
            return NSLocalizedString("No sample store data found.", comment: "")
        case .invalidStoreCoordinates(storeName: let storeName):
            return NSLocalizedString("Invalid store coordinates for \(storeName).", comment: "")
        case .failedToAddMarkers(reason: let reason):
            return NSLocalizedString("Failed to add markers: \(reason)", comment: "")
        case .emptyMapBoundary:
            return NSLocalizedString("Map boundary information is empty.", comment: "")
        }
    }
}
