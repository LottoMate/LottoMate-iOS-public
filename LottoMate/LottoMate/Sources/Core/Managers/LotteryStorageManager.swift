//
//  LotteryStorageManager.swift
//  LottoMate
//
//  Created by AI Assistant on 1/15/25.
//

import Foundation
import RxSwift
import RxRelay

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
