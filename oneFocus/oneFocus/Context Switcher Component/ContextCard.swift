//
//  ContextCard.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/21/24.
//

import Foundation

struct ContextCard: Identifiable, Codable {
    let id: UUID
    var title: String
    var workType: String
    var workDepth: String
    var notes: String
    var timeSpent: TimeInterval
    var isActive: Bool
    var applications: [AppStateManager.RunningAppInfo]
    var created: Date
    var lastAccessed: Date
    
    init(title: String, workType: String, workDepth: String, notes: String) {
        self.id = UUID()
        self.title = title
        self.workType = workType
        self.workDepth = workDepth
        self.notes = notes
        self.timeSpent = 0
        self.isActive = false
        self.applications = []
        self.created = Date()
        self.lastAccessed = Date()
    }
}
