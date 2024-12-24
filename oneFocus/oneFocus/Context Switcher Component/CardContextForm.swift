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
    let stateManager = SystemStateManager()
    
    @State var contextTitle: String = ""
    @State var workDepthContextDefault = WorkDepth.shallow
    @State var worktypeContextDefault = WorkType.coding
    @State var workPriorityContextDefault = WorkPriority.medium
    @State var note = ""
    
    func createContext() async {
        do {
            let state = try await stateManager.captureCurrentState()
            let newContext = ContextCardModel(
                title: contextTitle,
                workDepth: workDepthContextDefault,
                workType: worktypeContextDefault,
                note: note,
                priority: workPriorityContextDefault,
                systemState: state
            )
            contexts.append(newContext)
            dismiss()
        } catch {
            print("Fialed to caputure state: \(error)")
        }
    }
    
    var body: some View {
        Form {
            TextField("Title", text: $contextTitle)
            
            Picker("Type", selection: $worktypeContextDefault){
                ForEach(WorkType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                }
            }
            
            Picker("Depth", selection: $workDepthContextDefault){
                ForEach(WorkDepth.allCases, id: \.self) { depth in
                    Text(depth.rawValue.capitalized)
                }
            }
            
            Picker("Priority", selection: $workPriorityContextDefault){
                ForEach(WorkPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue.capitalized)
                }
            }
            
            TextEditor(text: $note)
                .frame(height: 100)
                .border(Color.black)
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction){
                Button("Create"){
                    Task {
                            do {
                                let state = try await stateManager.captureCurrentState()
                                
                                // Print captured applications
                                print("\n--- Running Applications ---")
                                state.applications.forEach { app in
                                    print("App: \(app.name) (\(app.bundleId))")
                                }
                                
                                // Print browser tabs
                                print("\n--- Browser Tabs ---")
                                state.browserTabs.forEach { tab in
                                    print("Tab: \(tab.title) - \(tab.url)")
                                }
                                
                                // Print IDE state
                                print("\n--- IDE State ---")
                                if let ide = state.ideState {
                                    print("Editor: \(ide.editor)")
                                    print("Current file: \(ide.currentFile ?? "None")")
                                    print("Open files: \(ide.openFiles)")
                                } else {
                                    print("No IDE detected")
                                }
                            } catch {
                                print("Error capturing state: \(error)")
                            }
                        }
                }
                .disabled(contextTitle.isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

