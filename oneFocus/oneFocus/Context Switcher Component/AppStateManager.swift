//
//  AppStateManager.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/21/24.
//


import Cocoa

class AppStateManager: ObservableObject {
    @Published var activeApplications: [RunningAppInfo] = []
    private let workspace = NSWorkspace.shared
    
    struct RunningAppInfo: Codable, Identifiable {
        let id = UUID()
        let bundleIdentifier: String
        let name: String
        var windowPosition: [String: Double]?
        
        init(app: NSRunningApplication) {
            self.bundleIdentifier = app.bundleIdentifier ?? ""
            self.name = app.localizedName ?? "Unknown"
            self.windowPosition = nil
        }
    }
    
    func captureCurrentState() {
        let runningApps = workspace.runningApplications.filter { app in
            guard let bundleId = app.bundleIdentifier else { return false }
            return !bundleId.starts(with: "com.apple") &&
                   bundleId != Bundle.main.bundleIdentifier &&
                   app.activationPolicy == .regular
        }
        
        activeApplications = runningApps.map { RunningAppInfo(app: $0) }
        
        print("Captured applications:")
            activeApplications.forEach { app in
            print("- \(app.name) (\(app.bundleIdentifier))")
        }
    }
    
    func restoreApps(from savedState: [RunningAppInfo]) {
        for appInfo in savedState {
            // Fixed method call to match correct API
            if let url = workspace.urlForApplication(withBundleIdentifier: appInfo.bundleIdentifier) {
                try? workspace.launchApplication(at: url,
                    options: [],
                    configuration: [:])
            }
        }
    }
}
