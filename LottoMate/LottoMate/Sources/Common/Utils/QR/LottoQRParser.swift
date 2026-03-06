//
//  LottoQRParser.swift
//  LottoMate
//
//  Created by Mirae on 12/24/24.
//

import Foundation

struct QRScanResult {
    let lottoDrwNo: Int
    let lottoNumbers: [[Int]]
}

enum LottoQRParser {
    static func parse(from urlString: String) -> QRScanResult? {
        print("📱 LottoQRParser - Parsing URL: \(urlString)")
        
        // Extract the parameter value after "v="
        guard let startRange = urlString.range(of: "v="),
              let parameterValue = urlString[startRange.upperBound...].components(separatedBy: "?").first else {
            return nil
        }
        
        // First 4 digits are the draw number
        guard parameterValue.count >= 4 else { return nil }
        let drwNoStr = String(parameterValue.prefix(4))
        let drwNo = Int(drwNoStr.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)) ?? 0
        
        var numbers: [[Int]] = []
        
        // Extract segments after removing the draw number
        let remainingString = String(parameterValue.dropFirst(4))
        
        // Use regex to find all segments with pattern: [qmn][0-9]+
        // This handles all three formats: q (new), m (old), and n (empty)
        let pattern = "[qmn][0-9]+"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let matches = regex?.matches(in: remainingString, options: [], range: NSRange(remainingString.startIndex..., in: remainingString)) {
            for match in matches {
                if let range = Range(match.range, in: remainingString) {
                    let segment = String(remainingString[range])
                    
                    // First character is the delimiter (q, m, or n)
                    let delimiter = segment.prefix(1)
                    let numberString = String(segment.dropFirst())
                    
                    // Skip segments with 'n' delimiter as they're meant to be empty
                    if delimiter == "n" {
                        continue
                    }
                    
                    // Parse 6 lottery numbers from the segment
                    // Each number is 2 digits, so we need to process 12 characters
                    if numberString.count >= 12 {
                        var lottoNumbers: [Int] = []
                        
                        // Process 2 digits at a time to extract the 6 numbers
                        for i in stride(from: 0, to: 12, by: 2) {
                            let startIndex = numberString.index(numberString.startIndex, offsetBy: i)
                            let endIndex = numberString.index(startIndex, offsetBy: 2, limitedBy: numberString.endIndex) ?? numberString.endIndex
                            let twoDigits = numberString[startIndex..<endIndex]
                            
                            if let number = Int(twoDigits) {
                                lottoNumbers.append(number)
                            }
                        }
                        
                        // Check if all numbers are zero
                        let allZeros = lottoNumbers.allSatisfy { $0 == 0 }
                        
                        // Only add sets with exactly 6 numbers and not all zeros
                        if lottoNumbers.count == 6 && !allZeros {
                            numbers.append(lottoNumbers)
                        }
                    }
                }
            }
        }
        
        return QRScanResult(lottoDrwNo: drwNo, lottoNumbers: numbers)
    }
}
