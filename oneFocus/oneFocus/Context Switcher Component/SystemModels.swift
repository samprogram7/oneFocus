//
//  SystemModels.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/26/24.
//

import Foundation

struct AppState: Codable {
    var bundleId: String
    var name: String
}


struct TabInfo: Codable {
    let url: String
    let title: String
}

struct BrowserState: Codable {
    let tabs: [TabInfo]
    let browserName: String
}

struct SystemState: Codable {
    let appState: [AppState]
    let browserState: BrowserState?
}

