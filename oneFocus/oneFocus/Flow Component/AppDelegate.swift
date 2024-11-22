//
//  AppDelegate.swift
//  oneFocus
//
//  Created by Samuel Rojas on 10/28/24.
//

import Cocoa
import SwiftUI
import Combine
import UserNotifications

//Delegates the app config
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Flow"

        // Observe changes to the timerManager's timeString
        TimerManager.shared.$timeRemaining
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)

        TimerManager.shared.$isActive
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)
        
        TimerManager.shared.$mode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)

        // Create the popover content
        let contentView = MainView()
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient

        // Set up the status bar button action
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications authroization: \(error)")
            } else if granted {
                print("Notifications permission granted.")
            } else {
                print("Notifications permission denied.")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }

    func updateStatusItemTitle() {
        if TimerManager.shared.isActive {
            let modeSymbol = TimerManager.shared.mode == .work ? "🎧" : "🏖️"
            statusItem.button?.title = "\(modeSymbol) \(TimerManager.shared.timeString)"
        } else {
            statusItem.button?.title = "oneFocus"
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didDeliver notification: UNNotification) {
        print("Notification delivered: \(notification.request.content.title)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, shouldPresent notification: UNNotification) -> Bool {
        // Return true to show notification even when app is in foreground
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification even when the app is in the foreground
        completionHandler([.banner, .sound])
    }
    
    
//    func application(_ app: NSApplication, open url: URL, options: [NSApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
//            return false
//        }
//
//        if let code = queryItems.first(where: { $0.name == "code" })?.value {
//            exchangeAuthorizationCodeForAccessToken(code: code)
//        }
//
//        return true
//    }

    
    
//    func exchangeAuthorizationCodeForAccessToken(code: String) {
//        let tokenUrl = URL(string: "https://api.notion.com/v1/oauth/token")!
//        var request = URLRequest(url: tokenUrl)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        //Add This
//        let clientId = "126d872b-594c-80ea-b1ae-0037bc5635cd"
//
//        //Add this
//        let clientSecret = "secret_m8OmX486sRuDBFi8fB9gi2VHJEaZDvd5QBFOT0FHu3P"
//
//        //Add this
//        let redirectUri = "https://api.notion.com/v1/oauth/authorize?client_id=126d872b-594c-80ea-b1ae-0037bc5635cd&response_type=code&owner=user&redirect_uri=https%3A%2F%2Fonefocus%2F%2Fnotion-auth"
//        let bodyParams = [
//            "grant_type": "authorization_code",
//            "code": code,
//            "redirect_uri": redirectUri,
//            "client_id": clientId,
//            "client_secret": clientSecret
//        ]
//
//        let bodyString = bodyParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
//        request.httpBody = bodyString.data(using: .utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//
//            if let data = data {
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                       let accessToken = json["access_token"] as? String {
//                        // Save the access token for making future requests
//                        print("Access Token: \(accessToken)")
//                    }
//                } catch {
//                    print("Failed to parse response: \(error)")
//                }
//            }
//        }
//
//        task.resume()
//    }
    
   


    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

//
