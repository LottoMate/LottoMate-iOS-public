//
//  String+Extensions.swift
//  LottoMate
//
//  Created by Mirae on 12/25/24.
//

import Foundation

extension String {
    var reformatDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        } else {
            return ""
        }
    }
}
