//
//  LotteryStorageManager.swift
//  LottoMate
//
//  Created by AI Assistant on 1/15/25.
//

import Foundation
import RxSwift
import RxRelay

enum InputLotteryType: String, CaseIterable, Codable {
    case lotto = "lotto"
    case pension = "pension"
    
    var displayName: String {
        switch self {
        case .lotto:
            return "로또"
        case .pension:
            return "연금복권"
        }
    }
}

struct LotteryEntry: Codable, Identifiable {
    let id: UUID
    let type: InputLotteryType
    let round: Int
    let drawDate: String
    let numbers: [Int]
    let isWinning: Bool
    let isWinningChecked: Bool
    let createdAt: Date
    
    init(type: InputLotteryType, round: Int, drawDate: String, numbers: [Int]) {
        self.id = UUID()
        self.type = type
        self.round = round
        self.drawDate = drawDate
        self.numbers = numbers
        self.isWinning = false
        self.isWinningChecked = false
        self.createdAt = Date()
    }
    
    // 당첨 상태 업데이트를 위한 생성자
    init(from entry: LotteryEntry, isWinning: Bool, isWinningChecked: Bool) {
        self.id = entry.id
        self.type = entry.type
        self.round = entry.round
        self.drawDate = entry.drawDate
        self.numbers = entry.numbers
        self.isWinning = isWinning
        self.isWinningChecked = isWinningChecked
        self.createdAt = entry.createdAt
    }
}

class LotteryStorageManager {
    static let shared = LotteryStorageManager()
    
    private let fileName = "lottery_entries.json"
    private let entriesRelay = BehaviorRelay<[LotteryEntry]>(value: [])
    
    var entries: Observable<[LotteryEntry]> {
        return entriesRelay.asObservable()
    }
    
    var currentEntries: [LotteryEntry] {
        return entriesRelay.value
    }
    
    private init() {
        loadEntries()
    }
    
    // MARK: - File Path
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK: - Load Entries
    private func loadEntries() {
        do {
            let data = try Data(contentsOf: fileURL)
            let entries = try JSONDecoder().decode([LotteryEntry].self, from: data)
            entriesRelay.accept(entries)
        } catch {
            // 파일이 없거나 파싱 에러인 경우 빈 배열로 시작
            print("Failed to load lottery entries: \(error)")
            entriesRelay.accept([])
        }
    }
    
    // MARK: - Save Entries
    private func saveEntries() throws {
        let data = try JSONEncoder().encode(entriesRelay.value)
        try data.write(to: fileURL)
    }
    
    // MARK: - Add Entry
    func addEntry(_ entry: LotteryEntry) throws {
        var currentEntries = entriesRelay.value
        currentEntries.append(entry)
        try saveEntries()
        entriesRelay.accept(currentEntries)
    }
    
    // MARK: - Add Multiple Entries
    func addEntries(_ entries: [LotteryEntry]) throws {
        var currentEntries = entriesRelay.value
        currentEntries.append(contentsOf: entries)
        entriesRelay.accept(currentEntries)
        try saveEntries()
    }
    
    // MARK: - Update Entry
    func updateEntry(_ updatedEntry: LotteryEntry) throws {
        var currentEntries = entriesRelay.value
        if let index = currentEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            currentEntries[index] = updatedEntry
            entriesRelay.accept(currentEntries)
            try saveEntries()
        } else {
            throw LotteryStorageError.entryNotFound
        }
    }
    
    // MARK: - Delete Entry
    func deleteEntry(id: UUID) throws {
        var currentEntries = entriesRelay.value
        currentEntries.removeAll { $0.id == id }
        entriesRelay.accept(currentEntries)
        try saveEntries()
    }
    
    // MARK: - Query Methods
    func getEntries(for type: InputLotteryType) -> [LotteryEntry] {
        return entriesRelay.value.filter { $0.type == type }
    }
    
    func getEntries(for type: InputLotteryType, round: Int) -> [LotteryEntry] {
        return entriesRelay.value.filter { $0.type == type && $0.round == round }
    }
    
    func getUncheckWinningEntries() -> [LotteryEntry] {
        return entriesRelay.value.filter { !$0.isWinningChecked }
    }
    
    func getWinningEntries() -> [LotteryEntry] {
        return entriesRelay.value.filter { $0.isWinning }
    }
    
    // MARK: - Utility Methods
    func getTotalEntriesCount() -> Int {
        return entriesRelay.value.count
    }
    
    func getEntriesCount(for type: InputLotteryType) -> Int {
        return getEntries(for: type).count
    }
    
    // MARK: - Clear All Data
    func clearAllEntries() throws {
        entriesRelay.accept([])
        try saveEntries()
    }
}

// MARK: - Errors
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
