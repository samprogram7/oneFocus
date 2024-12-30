//
//  StorageManager.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/28/24.
//

import Foundation

class StorageManager {
    private let fileManager = FileManager.default
    
    // Get the documents directory URL
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // URL for contexts file
    private var contextsFileURL: URL {
        documentsDirectory.appendingPathComponent("contexts.json")
    }
    
    // Save contexts to file
    func saveContexts(_ contexts: [ContextCardModel]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(contexts)
            try data.write(to: contextsFileURL)
        } catch {
            print("Error saving contexts: \(error)")
        }
    }
    
    // Load contexts from file
    func loadContexts() -> [ContextCardModel] {
        do {
            let data = try Data(contentsOf: contextsFileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([ContextCardModel].self, from: data)
        } catch {
            print("Error loading contexts: \(error)")
            return []
        }
    }
}
