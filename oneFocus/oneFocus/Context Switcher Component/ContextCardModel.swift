//
//  ContextCardModel.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/23/24.
//

import Foundation

struct ContextCardModel: Codable, Identifiable {
    let id: UUID = UUID()
    var title: String
    var workDepth: WorkDepth
    var workType: WorkType
    var note: String
    var priority: WorkPriority
    var systemState: SystemState
}

enum WorkDepth: String, Codable, CaseIterable {
    case deep
    case shallow
    case leisure
}

enum WorkPriority: String, Codable, CaseIterable {
    case high
    case medium
    case low
}

enum WorkType: String, Codable, CaseIterable {
    case coding
    case writing
    case research
    case work
    case school
    case meeting
    case personal
    case other
}
