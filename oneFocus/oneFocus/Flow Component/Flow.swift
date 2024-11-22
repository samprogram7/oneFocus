//
//  Flow.swift
//  oneFocus
//
//  Created by Samuel Rojas on 10/28/24.
//

import SwiftUI

struct Flow: View {
    
    @ObservedObject var timerManager = TimerManager.shared
    @FocusState private var isTaskFieldFocused: Bool
    @State private var timer: Timer? = nil
    @State private var tasks = [String]() {
        didSet{
            saveTasks()
        }
    }
    @State private var userTask: String = ""
    @State private var currentEditIndex: Int? = nil
    @State private var editedTask: String = ""
    
    //Options of Times for the user
    @State private var times = [1500, 1800, 2100, 2700, 3000, 3600, 5400]
    
    //For Animations
    @State private var isHoveredAddTask = false
    @State private var isHoveredAddTaskButton = false
    @State private var isHoveredTimer = false
    @State private var isHoveredStartBtn = false
    @State private var isHoveredResetBtn = false
    
    
    
    var body: some View {
        ScrollView{
            VStack {
                
                // Minimalistic To-Do Heading
                Text("Flow")
                    .font(.system(size: 20, weight: .semibold, design: .rounded)) // Adjusted font size
                    .foregroundColor(Color.primary)
                    .padding(.top, 15) // Adjusted padding
                    .padding(.bottom, 5)
                    .multilineTextAlignment(.center)
                
//                //Display Current Mode
//                Text(timerManager.modeString)
//                    .font(.headline)
//                    .padding(.bottom, 5)
                    
                
                // Task Input Section
                taskInputSection
                
                // Task List Section
                taskListSection
                
                
                
                // Timer Section
                timerSection
                
                
                NavigationLink(destination: MainView().frame(width: 350, height: 420, alignment: .center)){
                    Text("Back")
                }
                
            }
            .padding()
            .frame(width: 300) // Set a smaller width for the menu bar app
            .background(Color(NSColor.windowBackgroundColor)) // Minimal background color
            .cornerRadius(12) // Rounded corners for the window
            .shadow(radius: 5) // Optional shadow for better visibility
        }
        .onAppear{
            loadTasks()
        }
    }
    
    // Task Input Section
    private var taskInputSection: some View {
        HStack {
            TextField("Task...", text: $userTask)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .frame(height: 30) // Smaller height
                .padding(.leading, 10)
                .scaleEffect(isHoveredAddTask ? 1.06 : 1.0)
                .onHover{ hovered in
                    withAnimation(.easeInOut){
                        isHoveredAddTask = hovered
                    }
                }
                .focused($isTaskFieldFocused)
            
            Button(action: {
                withAnimation(.spring()) {
                    addTask()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18)) // Smaller icon
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 10)
            .scaleEffect(isHoveredAddTaskButton ? 1.2 : 1.0)
            .onHover{ hovered in
                withAnimation(.easeInOut){
                    isHoveredAddTaskButton = hovered
                }
            }
        }
        
        .padding(.vertical, 5) // Reduced vertical padding
    }
    
    
   
    
    // Task List Section
    //.enumerated() creates a sequence of key-value pairs
    private var taskListSection: some View {
        VStack(spacing: 7) { // Reduced spacing between tasks
            ForEach(Array(tasks.enumerated()), id: \.element) { index, task in
                HStack {
                    if currentEditIndex == index {
                        taskEditView(index: index)
                    } else {
                        taskDisplayView(index: index, task: task)
                    }
                }
                .padding(8) // Reduced padding
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                .animation(.easeInOut(duration: 1.2), value: tasks)
            }
        }
        .padding(.horizontal, 10)
    }
    
    // Timer Section
    private var timerSection: some View {
        VStack(spacing: 15) { // Reduced spacing
            // Display Time
            Text("\(timerManager.modeString): \(timerManager.timeString)")
                .font(.title) // Adjusted font size
                .padding()
                .border(Color.black, width: 3)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(7)
                .animation(.easeIn, value: timerManager.isActive)
                .scaleEffect(isHoveredTimer ? 0.9: 1)
                .onHover { timerHover in
                    withAnimation(.easeIn(duration: 0.2)){
                        isHoveredTimer = timerHover
                    }
                }
            
            Picker("Work Duration", selection: $timerManager.selectedTime) {
                ForEach(times, id: \.self) { timeRange in
                    Text("\(timeRange / 60)")
                }
            }
            .pickerStyle(MenuPickerStyle()) // Minimal Picker Style
            .frame(width: 115, height: 20)
            .disabled(timerManager.isActive && timerManager.mode == .rest)
            
            // Timer Controls
            HStack(spacing: 15) { // Reduced spacing
                Button(action: {
                    if timerManager.isActive {
                        timerManager.pauseTimer()
                    } else {
                        timerManager.startTimer()
                    }
                }) {
                    Text(timerManager.isActive ? "Pause" : (timerManager.isPaused ? "Resume" : "Start"))
                        .font(.subheadline) // Smaller font size
                        .padding(6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isHoveredStartBtn ? 1.2 : 1.0)
                .onHover{ hoverStart in
                    withAnimation(.easeInOut(duration: 0.6)){
                        isHoveredStartBtn = hoverStart
                    }
                }
                
                Button(action: {
                    timerManager.resetTimer()
                }) {
                    Text("Reset")
                        .font(.subheadline) // Smaller font size
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.red)
                        .cornerRadius(8)
                        .clipped()
                        
                        
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isHoveredResetBtn ? 1.2 : 1.0)
                .onHover{ hoverReset in
                    withAnimation(.easeInOut(duration: 0.6)){
                        isHoveredResetBtn = hoverReset
                    }
                }
            }
            
        }
        .padding(.vertical,30)
    
    }
    
    // Task Display View
    private func taskDisplayView(index: Int, task: String) -> some View {
        HStack {
            Text(task)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
            
            // Edit Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentEditIndex = index
                    editedTask = task
                }
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18)) // Smaller icon size
            }
            .padding(.horizontal, 6)
            
            // Delete Button
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    deleteTask(at: index)
                }
            }) {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .font(.system(size: 18)) // Smaller icon size
            }
            .padding(.horizontal, 5)
            
        }
    }
    
    // Task Edit View
    private func taskEditView(index: Int) -> some View {
        HStack {
            TextField("Edit Task", text: $editedTask)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .frame(height: 30) // Smaller height
            
            Button(action: {
                withAnimation(.easeInOut) {
                    tasks[index] = editedTask
                    currentEditIndex = nil
                }
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // Add Task
    func addTask() {
        guard !userTask.isEmpty else { return }
        tasks.append(userTask)
        userTask = ""
        isTaskFieldFocused = false
    }
    
    // Delete Task
    func deleteTask(at index: Int) {
        tasks.remove(at: index)
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        return timeString
    }
    
    func startTimer() {
        timerManager.timeRemaining = timerManager.selectedTime
        timerManager.isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerManager.timeRemaining > 0 {
                timerManager.timeRemaining -= 1
            } else {
                timerManager.resetTimer()
            }
        }
    }
    
    func resumeTimer() {
        
    }

    
    func pauseTimer() {
        timerManager.isActive = false
        timer?.invalidate()
    }
    
    func resetTimer() {
        timerManager.isActive = false
        timer?.invalidate()
        timerManager.timeRemaining = timerManager.selectedTime
    }
    
    func saveTasks() {
        if let encodedData = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedData, forKey: "tasks")
        }
    }

    func loadTasks() {
        if let savedData = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([String].self, from: savedData) {
            tasks = decodedTasks
        }
    }

}

#Preview {
    Flow()
    
}
