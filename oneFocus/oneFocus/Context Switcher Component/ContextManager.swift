//
//  ContextManager.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/21/24.
//


import Foundation

class ContextManager: ObservableObject {
    @Published var contexts: [ContextCard] = []
    private let appStateManager = AppStateManager()
    private var timer: Timer?
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupport = paths[0].appendingPathComponent("oneFocus")
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent("contexts.json")
    }
    
    init() {
        loadContexts()
    }
    
    func saveContexts() {
        do {
            let data = try JSONEncoder().encode(contexts)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save contexts: \(error)")
        }
    }
    
    private func loadContexts() {
        do {
            let data = try Data(contentsOf: fileURL)
            contexts = try JSONDecoder().decode([ContextCard].self, from: data)
        } catch {
            contexts = []
        }
    }
    
    func createContext(title: String, workType: String, workDepth: String, notes: String) {
        var newContext = ContextCard(title: title, workType: workType, workDepth: workDepth, notes: notes)
        appStateManager.captureCurrentState()
        newContext.applications = appStateManager.activeApplications
        
        contexts.append(newContext)
        saveContexts()
    }
    
    func switchToContext(_ context: ContextCard) {
        // Deactivate current context and save its state
        if let activeIndex = contexts.firstIndex(where: { $0.isActive }) {
            contexts[activeIndex].isActive = false
            appStateManager.captureCurrentState()
            contexts[activeIndex].applications = appStateManager.activeApplications
        }
        
        // Activate new context
        if let newIndex = contexts.firstIndex(where: { $0.id == context.id }) {
            contexts[newIndex].isActive = true
            contexts[newIndex].lastAccessed = Date()
            appStateManager.restoreApps(from: context.applications)
            startTimeTracking()
        }
        
        saveContexts()
    }
    
    private func startTimeTracking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let activeIndex = self.contexts.firstIndex(where: { $0.isActive }) else { return }
            self.contexts[activeIndex].timeSpent += 1
            self.saveContexts()
        }
    }
}
