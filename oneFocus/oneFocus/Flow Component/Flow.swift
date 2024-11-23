//
//  Flow.swift
//  oneFocus
//
//  Created by Samuel Rojas on 10/28/24.
//

import SwiftUI

struct AppDimensions {
   static let width: CGFloat = 300
   static let height: CGFloat = 400
}

struct ContentContainer<Content: View>: View {
   let content: Content
   
   init(@ViewBuilder content: () -> Content) {
       self.content = content()
   }
   
   var body: some View {
       VStack {
           content
       }
       .frame(width: AppDimensions.width, height: AppDimensions.height)
       .background(Color(NSColor.textBackgroundColor))
   }
}

struct Flow: View {
   @ObservedObject var timerManager = TimerManager.shared
   @FocusState private var isTaskFieldFocused: Bool
   @State private var timer: Timer? = nil
   @State private var tasks = [String]() {
       didSet {
           saveTasks()
       }
   }
   @State private var userTask: String = ""
   @State private var currentEditIndex: Int? = nil
   @State private var editedTask: String = ""
   @State private var times = [1500, 1800, 2100, 2700, 3000, 3600, 5400]
   
   @State private var isHoveredAddTask = false
   @State private var isHoveredAddTaskButton = false
   @State private var isHoveredTimer = false
   @State private var isHoveredStartBtn = false
   @State private var isHoveredResetBtn = false
   
   var body: some View {
       ContentContainer {
           ScrollView(.vertical, showsIndicators: false) {
               VStack(spacing: 20) {
                   Text("Flow")
                       .font(.system(size: 20, weight: .semibold, design: .rounded))
                       .foregroundColor(Color.primary)
                       .padding(.top, 15)
                       .padding(.bottom, 5)
                       .multilineTextAlignment(.center)
                   
                   taskInputSection
                   taskListSection
                   timerSection
                   
                   NavigationLink(destination: MainView()) {
                       Text("Back")
                   }
               }
               .frame(maxWidth: .infinity)
               .padding(.horizontal)
           }
       }
       .frame(width: AppDimensions.width, height: AppDimensions.height)
       .onAppear {
           loadTasks()
       }
   }
   
   // Rest of your view components remain the same
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
               .frame(height: 30)
               .padding(.leading, 10)
               .scaleEffect(isHoveredAddTask ? 1.06 : 1.0)
               .onHover { hovered in
                   withAnimation(.easeInOut) {
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
                   .font(.system(size: 18))
                   .foregroundColor(.white)
                   .padding(8)
                   .background(Color.accentColor)
                   .clipShape(Circle())
           }
           .buttonStyle(PlainButtonStyle())
           .padding(.trailing, 10)
           .scaleEffect(isHoveredAddTaskButton ? 1.2 : 1.0)
           .onHover { hovered in
               withAnimation(.easeInOut) {
                   isHoveredAddTaskButton = hovered
               }
           }
       }
   }
   
   private var taskListSection: some View {
       VStack(spacing: 7) {
           ForEach(Array(tasks.enumerated()), id: \.element) { index, task in
               HStack {
                   if currentEditIndex == index {
                       taskEditView(index: index)
                   } else {
                       taskDisplayView(index: index, task: task)
                   }
               }
               .padding(8)
               .background(Color(NSColor.textBackgroundColor))
               .cornerRadius(8)
               .transition(.asymmetric(
                   insertion: .opacity.combined(with: .move(edge: .trailing)),
                   removal: .opacity.combined(with: .move(edge: .leading))
               ))
               .animation(.easeInOut(duration: 1.2), value: tasks)
           }
       }
   }
   
   private var timerSection: some View {
       VStack(spacing: 15) {
           Text("\(timerManager.modeString): \(timerManager.timeString)")
               .font(.title)
               .padding()
               .border(Color.black, width: 3)
               .background(Color(NSColor.textBackgroundColor))
               .cornerRadius(7)
               .animation(.easeIn, value: timerManager.isActive)
               .scaleEffect(isHoveredTimer ? 0.9 : 1)
               .onHover { timerHover in
                   withAnimation(.easeIn(duration: 0.2)) {
                       isHoveredTimer = timerHover
                   }
               }
           
           Picker("Work Duration", selection: $timerManager.selectedTime) {
               ForEach(times, id: \.self) { timeRange in
                   Text("\(timeRange / 60)")
               }
           }
           .pickerStyle(MenuPickerStyle())
           .frame(width: 115, height: 20)
           .disabled(timerManager.isActive && timerManager.mode == .rest)
           
           HStack(spacing: 15) {
               Button(action: {
                   if timerManager.isActive {
                       timerManager.pauseTimer()
                   } else {
                       timerManager.startTimer()
                   }
               }) {
                   Text(timerManager.isActive ? "Pause" : (timerManager.isPaused ? "Resume" : "Start"))
                       .font(.subheadline)
                       .padding(6)
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(8)
               }
               .buttonStyle(PlainButtonStyle())
               .scaleEffect(isHoveredStartBtn ? 1.2 : 1.0)
               .onHover { hoverStart in
                   withAnimation(.easeInOut(duration: 0.6)) {
                       isHoveredStartBtn = hoverStart
                   }
               }
               
               Button(action: {
                   timerManager.resetTimer()
               }) {
                   Text("Reset")
                       .font(.subheadline)
                       .foregroundStyle(.white)
                       .padding(6)
                       .background(Color.red)
                       .cornerRadius(8)
                       .clipped()
               }
               .buttonStyle(PlainButtonStyle())
               .scaleEffect(isHoveredResetBtn ? 1.2 : 1.0)
               .onHover { hoverReset in
                   withAnimation(.easeInOut(duration: 0.6)) {
                       isHoveredResetBtn = hoverReset
                   }
               }
           }
       }
       .padding(.vertical, 30)
   }
   
   // All helper functions remain the same
   private func taskDisplayView(index: Int, task: String) -> some View {
       HStack {
           Text(task)
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding(.vertical, 6)
               .padding(.horizontal, 10)
               .background(Color(NSColor.textBackgroundColor))
               .cornerRadius(8)
           
           Button(action: {
               withAnimation(.easeInOut(duration: 0.3)) {
                   currentEditIndex = index
                   editedTask = task
               }
           }) {
               Image(systemName: "pencil")
                   .foregroundColor(.yellow)
                   .font(.system(size: 18))
           }
           .padding(.horizontal, 6)
           
           Button(action: {
               withAnimation(.easeOut(duration: 0.2)) {
                   deleteTask(at: index)
               }
           }) {
               Image(systemName: "checkmark")
                   .foregroundColor(.green)
                   .font(.system(size: 18))
           }
           .padding(.horizontal, 5)
       }
   }
   
   private func taskEditView(index: Int) -> some View {
       HStack {
           TextField("Edit Task", text: $editedTask)
               .padding(8)
               .background(Color(NSColor.textBackgroundColor))
               .cornerRadius(8)
               .frame(height: 30)
           
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
   
   func addTask() {
       guard !userTask.isEmpty else { return }
       tasks.append(userTask)
       userTask = ""
       isTaskFieldFocused = false
   }
   
   func deleteTask(at index: Int) {
       tasks.remove(at: index)
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
