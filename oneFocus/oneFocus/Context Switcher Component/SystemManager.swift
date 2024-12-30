//
//  SystemManager .swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/26/24.
//

import Foundation
import AppKit

class SystemManager {
    // System processes to filter out
    private let systemBundles = Set([
        "com.apple.finder",
        "com.apple.dock",
        "com.apple.systemuiserver",
        "com.apple.WindowManager",
        "com.apple.loginwindow"
    ])
    
    // Get non-system applications
    func getApplications() -> [AppState] {
        let workspace = NSWorkspace.shared
        
        // Filter out system/helper processes but allow regular apps
        return workspace.runningApplications.compactMap { app in
            guard let bundleId = app.bundleIdentifier,
                  let name = app.localizedName,
                  !systemBundles.contains(bundleId),
                  !bundleId.hasPrefix("com.apple.") || bundleId == "com.apple.Safari",
                  // Filter out helper/background processes
                  !bundleId.contains(".helper"),
                  !bundleId.contains(".Helper"),
                  !bundleId.contains(".plugin"),
                  !bundleId.contains(".Plugin"),
                  !bundleId.contains("finder"),
                  !bundleId.contains("Finder"),
                  app.activationPolicy == .regular  // Only capture regular apps that have UI
            else { return nil }
            
            return AppState(bundleId: bundleId, name: name)
        }
    }
    
    // Debug helper
    func printCurrentState() {
        let apps = getApplications()
        print("\n--- Current Running Applications ---")
        apps.forEach { app in
            print("App: \(app.name) (\(app.bundleId))")
        }
    }
    func isBrowserRunning(_ bundleId: String = "com.google.chrome") -> Bool {
        let workspace = NSWorkspace.shared
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == bundleId
        }
    }
    
    func captureChromeState() async throws -> BrowserState {
        guard isBrowserRunning() else {
            throw BrowserError.noRunningBrowser
        }
            let script = """
                tell application "Google Chrome"
                    set tabList to {}
                    repeat with w in windows
                        repeat with t in tabs of w
                            set tabInfo to {URL:URL of t, title:title of t}
                            copy tabInfo to end of tabList
                        end repeat
                    end repeat
                    return tabList
                end tell
            """
            
            let tabs = try await runAppleScript(script)
            return BrowserState(tabs: tabs, browserName: "Google Chrome")
    }
    
    func captureArcState() async throws -> BrowserState {
        let script = """
            tell application "Arc"
                set tabList to {}
                tell front window
                    set currentTabs to tabs
                    repeat with t in currentTabs
                        set tabInfo to {URL:(URL of t), title:(title of t)}
                        copy tabInfo to end of tabList
                    end repeat
                end tell
                return tabList
            end tell
        """
        
        let tabs = try await runAppleScript(script)
        return BrowserState(tabs: tabs, browserName: "Arc")
    }
    
    private func runAppleScript(_ source: String) async throws -> [TabInfo] {
            guard let script = NSAppleScript(source: source) else {
                throw BrowserError.scriptCreationFailed
            }
            
            var error: NSDictionary?
            let result = script.executeAndReturnError(&error)
            
            if let error = error {
                throw BrowserError.scriptExecutionFailed(error)
            }
            
            var tabs: [TabInfo] = []
            for i in 1...result.numberOfItems {
                if let item = result.atIndex(i),
                   let urlValue = item.atIndex(1)?.stringValue,
                   let titleValue = item.atIndex(2)?.stringValue {
                    tabs.append(TabInfo(url: urlValue, title: titleValue))
                }
            }
            
            return tabs
        }
    
    func captureFullState() async throws -> SystemState {
        let apps = getApplications()
        print("Capturing apps:", apps.map { "Name: \($0.name), Bundle: \($0.bundleId)" })
        
        // Try Arc first, if it fails (not running), try Chrome
           let browserState: BrowserState?
           do {
               if isBrowserRunning("company.thebrowser.Browser") {
                   browserState = try await captureArcState()
               } else if isBrowserRunning("com.google.Chrome") {
                   browserState = try await captureChromeState()
               } else {
                   browserState = nil
               }
           } catch {
               print("Error capturing browser state: \(error)")
               browserState = nil
           }
           
           return SystemState(
               appState: apps,
               browserState: browserState
           )
    }
        
        // Restore full system state
    func restoreState(_ state: SystemState) async throws {
        // First launch Arc if it's not running
        for app in state.appState {
            // Check if app is already running
            let isRunning = NSWorkspace.shared.runningApplications.contains { runningApp in
                runningApp.bundleIdentifier == app.bundleId
            }
            
            if !isRunning {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleId) {
                    do {
                        try NSWorkspace.shared.launchApplication(
                            at: appURL,
                            options: .withoutActivation, // Don't bring to front
                            configuration: [:]
                        )
                        print("Successfully launched: \(app.name)")
                        
                        // If it's Arc, wait a bit longer for it to fully launch
                        if app.name == "Arc" {
                            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                        } else {
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        }
                    } catch {
                        print("Error launching \(app.name): \(error)")
                    }
                }
            } else {
                print("Skipping \(app.name) - already running")
            }
        }
        
        // Then restore tabs if browser state exists
        if let browserState = state.browserState {
            let script = """
                tell application "Arc"
                    activate
                    make new window
                    tell front window
                        \(browserState.tabs.map { "open location \"\($0.url)\"" }.joined(separator: "\n                    "))
                    end tell
                end tell
            """
            
            let appleScript = NSAppleScript(source: script)
            var error: NSDictionary?
            appleScript?.executeAndReturnError(&error)
            
            if let error = error {
                throw BrowserError.scriptExecutionFailed(error)
            }
        }
    }
        
    enum BrowserError: Error {
        case scriptCreationFailed
        case scriptExecutionFailed(NSDictionary)
        case noRunningBrowser
    }
}
