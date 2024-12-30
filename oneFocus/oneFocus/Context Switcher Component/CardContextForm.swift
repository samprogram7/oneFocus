//
//  CardContextForma.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/23/24.
//

import SwiftUI
import Foundation
import AppKit

struct CardContextForm: View {
   @Environment(\.dismiss) var dismiss
   @Binding var contexts: [ContextCardModel]
   var systemManager = SystemManager()
   var storageManager = StorageManager()
   
   @State var contextTitle: String = ""
   @State var workDepthContextDefault = WorkDepth.shallow
   @State var worktypeContextDefault = WorkType.coding
   @State var workPriorityContextDefault = WorkPriority.medium
   @State var note = ""
   @State private var isCreating = false
   @State private var showError = false
   @State private var isHovering = false
   
   var body: some View {
       VStack(spacing: 16) {
           // Header
           Text("New Context")
               .font(.system(size: 18, weight: .bold, design: .rounded))
               .padding(.top, 12)
           
           // Main Form
           VStack(spacing: 12) {
               // Title Input
               VStack(alignment: .leading, spacing: 4) {
                   Text("Title")
                       .font(.caption)
                       .foregroundColor(.secondary)
                   TextField("", text: $contextTitle)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .overlay(
                           RoundedRectangle(cornerRadius: 6)
                               .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                       )
               }
               
               // Work Type
               Menu {
                   Picker("Type", selection: $worktypeContextDefault) {
                       ForEach(WorkType.allCases, id: \.self) { type in
                           Text(type.rawValue.capitalized).tag(type)
                       }
                   }
               } label: {
                   HStack {
                       Text("Type: \(worktypeContextDefault.rawValue.capitalized)")
                           .foregroundColor(.primary)
                       Spacer()
                       Image(systemName: "chevron.down")
                           .font(.caption)
                           .foregroundColor(.secondary)
                   }
                   .padding(8)
                   .background(Color.secondary.opacity(0.1))
                   .cornerRadius(8)
               }
               
               // Depth
               Menu {
                   Picker("Depth", selection: $workDepthContextDefault) {
                       ForEach(WorkDepth.allCases, id: \.self) { depth in
                           Text(depth.rawValue.capitalized).tag(depth)
                       }
                   }
               } label: {
                   HStack {
                       Text("Depth: \(workDepthContextDefault.rawValue.capitalized)")
                           .foregroundColor(.primary)
                       Spacer()
                       Image(systemName: "chevron.down")
                           .font(.caption)
                           .foregroundColor(.secondary)
                   }
                   .padding(8)
                   .background(Color.secondary.opacity(0.1))
                   .cornerRadius(8)
               }
               
               // Priority
               HStack(spacing: 8) {
                   ForEach(WorkPriority.allCases, id: \.self) { priority in
                       Button {
                           withAnimation(.spring()) {
                               workPriorityContextDefault = priority
                           }
                       } label: {
                           Circle()
                               .fill(priorityColor(priority))
                               .frame(width: 20, height: 20)
                               .overlay(
                                   Circle()
                                       .stroke(Color.white, lineWidth: workPriorityContextDefault == priority ? 2 : 0)
                               )
                               .shadow(color: priorityColor(priority).opacity(0.3),
                                      radius: workPriorityContextDefault == priority ? 4 : 0)
                       }
                       .buttonStyle(.plain)
                       .scaleEffect(workPriorityContextDefault == priority ? 1.1 : 1.0)
                   }
               }
               
               // Notes
               VStack(alignment: .leading, spacing: 4) {
                   Text("Notes")
                       .font(.caption)
                       .foregroundColor(.secondary)
                   TextEditor(text: $note)
                       .frame(height: 60)
                       .padding(4)
                       .background(Color.secondary.opacity(0.1))
                       .cornerRadius(8)
               }
           }
           .padding(.horizontal)
           
           // Action Buttons
           HStack(spacing: 12) {
               Button("Cancel") {
                   withAnimation {
                       dismiss()
                   }
               }
               .buttonStyle(.plain)
               .foregroundColor(.secondary)
               
               Button {
                   Task {
                       await createContext()
                   }
               } label: {
                   HStack {
                       if isCreating {
                           ProgressView()
                               .scaleEffect(0.7)
                               .padding(.trailing, 4)
                       }
                       Text(isCreating ? "Creating..." : "Create")
                   }
                   .frame(width: 100)
                   .padding(.vertical, 6)
               }
               .buttonStyle(.borderedProminent)
               .disabled(contextTitle.isEmpty || note.isEmpty || isCreating)
           }
           .padding(.bottom, 12)
       }
       .frame(width: 280)
       .background(Color(NSColor.windowBackgroundColor))
   }
   
   func priorityColor(_ priority: WorkPriority) -> Color {
       switch priority {
           case .high: return .red
           case .medium: return .orange
           case .low: return .green
       }
   }
   
    
    func createContext() async {
        isCreating = true
        do {
            let state = try await systemManager.captureFullState()
            let newContext = ContextCardModel(
                title: contextTitle,
                workDepth: workDepthContextDefault,
                workType: worktypeContextDefault,
                note: note,
                priority: workPriorityContextDefault,
                systemState: state
            )
            contexts.append(newContext)
            storageManager.saveContexts(contexts)
            dismiss()
        } catch {
            print("Error creating context: \(error)")
        }
        isCreating = false
    }
}


