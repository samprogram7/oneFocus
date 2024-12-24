//
//  SystemStateManager.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/23/24.
//

import Foundation
import AppKit

class SystemStateManager {
    private let browserBundleIds = [
        "com.apple.Safari",
        "com.google.Chrome"
    ]
    
    private let ideBundleIds = [
        "com.microsoft.VSCode",
        "com.apple.dt.Xcode"
    ]
    
    func captureRunningApplications() -> [CapturedApp] {
        let workspace = NSWorkspace.shared
        return workspace.runningApplications
            .compactMap { app in
                guard let bundleId = app.bundleIdentifier,
                      let name = app.localizedName,
                      !bundleId.contains("com.apple.") || bundleId == "com.apple.Safari"
                else { return nil }
                
                return CapturedApp(
                    bundleId: bundleId,
                    name: name,
                    windowState: nil
                )
            }
    }
    
    func captureBrowserTabs() async throws -> [TabInfo] {
        let script = NSAppleScript(source: """
            tell application "Safari"
                set tabList to {}
                tell window 1
                    set tabCount to count tabs
                    repeat with t from 1 to tabCount
                        set tabInfo to {URL:URL of tab t, title:name of tab t}
                        copy tabInfo to end of tabList
                    end repeat
                end tell
                return tabList
            end tell
        """)
        
        var error: NSDictionary?
        guard let result = script?.executeAndReturnError(&error) else {
            // For now, return empty if script fails
            return []
        }
        
        // For testing, return a mock tab
        return [TabInfo(url: "example.com", title: "Example Tab")]
    }
    
    func captureIDEState() -> IDEState? {
        let workspace = NSWorkspace.shared
        let runningIDEs = workspace.runningApplications
            .filter { app in
                guard let bundleId = app.bundleIdentifier else { return false }
                return ideBundleIds.contains(bundleId)
            }
        
        guard let ide = runningIDEs.first,
              let bundleId = ide.bundleIdentifier else {
            return nil
        }
        
        return IDEState(
            editor: bundleId,
            openFiles: [],
            currentFile: nil
        )
    }
    
    func captureCurrentState() async throws -> SystemState {
        let apps = captureRunningApplications()
        let tabs = try await captureBrowserTabs()
        let ideState = captureIDEState()
        
        return SystemState(
            applications: apps,
            browserTabs: tabs,
            ideState: ideState
        )
    }
}

