//
//  CaptureApp.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/23/24.
//

import Foundation


struct CapturedApp: Codable {
    let bundleId: String
    let name: String
    var windowState: WindowState?
}

struct WindowState: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct SystemState: Codable {
    var applications: [CapturedApp]
    var browserTabs: [TabInfo]
    var ideState: IDEState?
}

struct TabInfo: Codable {
    let url: String
    let title: String
}

struct IDEState: Codable {
    let editor: String
    let openFiles: [String]
    let currentFile: String?
}
