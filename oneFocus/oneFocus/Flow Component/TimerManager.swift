//
//  TimerManager.swift
//  oneFocus
//
//  Created by Samuel Rojas on 10/28/24.
//

import Foundation
import Combine
import UserNotifications

class TimerManager: ObservableObject {
    static let shared = TimerManager()

    @Published var timeRemaining: Int = 1500
    @Published var isActive = false
    @Published var isPaused: Bool = false
    @Published var selectedTime: Int = 1500 {
        didSet {
            if !isActive && mode == .work{
                timeRemaining = selectedTime
            }
        }
    }
    @Published var selectedBreakTime: Int = 300 {
        didSet {
            if !isActive && mode == .rest {
                timeRemaining = selectedBreakTime
            }
        }
    }
    
    @Published var mode: TimerMode = .work

    var timer: Timer?

    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var modeString: String {
        switch mode {
        case .work:
            return "Work"
        case .rest:
            return "Rest"
        }
    }

    func startTimer() {
        if isPaused {
            isActive = true
            isPaused = false
        } else if !isActive {
            timeRemaining = mode == .work ? selectedTime : selectedBreakTime
            isActive = true
            isPaused = false
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timerEnded()
            }
        }
    }
    
    func timerEnded() {
        if mode == .work {
            sendNotification(title: "Break Time", body: "Time to take a break!")
            mode = .rest
            timeRemaining = selectedBreakTime
        } else {
            sendNotification(title: "Work Time", body: "Time to Focus!")
            mode = .work
            timeRemaining = selectedTime
        }
        startTimer()
    }

    func pauseTimer() {
        isActive = false
        isPaused = true
        timer?.invalidate()
    }

    func resetTimer() {
        isActive = false
        isPaused = false
        timer?.invalidate()
        mode = .work
        timeRemaining = selectedTime
    }
    
    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification request: \(error)")
            }
        }
    }
    
    enum TimerMode {
        case work
        case rest
    }
}
