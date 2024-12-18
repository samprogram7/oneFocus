//
//  newContextSwitcher.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/17/24.
//

import Foundation
import SwiftUI

// First, let's create an enum for work types
enum WorkType: String, CaseIterable {
    case coding = "Coding"
    case school = "School"
    case writing = "Writing"
    case research = "Research"
    case design = "Design"
    case other = "Other"
}

enum WorkDepth: String, CaseIterable {
    case deep = "Deep Work"
    case shallow = "Shallow Work"
}

struct NewContextSheet: View {
    @Binding var isPresented: Bool
    @State private var contextTitle = ""
    @State private var contextNotes = ""
    @State private var selectedWorkType = WorkType.coding
    @State private var selectedDepth = WorkDepth.deep
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, notes
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Context")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                // Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Enter context title", text: $contextTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($focusedField, equals: .title)
                }
                
                // Work Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type of Work")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Picker("Work Type", selection: $selectedWorkType) {
                        ForEach(WorkType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Work Depth Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Work Depth")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Picker("Work Depth", selection: $selectedDepth) {
                        ForEach(WorkDepth.allCases, id: \.self) { depth in
                            Text(depth.rawValue).tag(depth)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Notes Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextEditor(text: $contextNotes)
                        .font(.body)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .notes)
                }
            }
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                
                Button("Create") {
                    // Handle context creation
                    isPresented = false
                    
                    
                }
                .buttonStyle(.borderedProminent)
                .disabled(contextTitle.isEmpty)
            }
            .padding(.top)
        }
        .frame(width: 400)
        .padding(.bottom)
        .onAppear {
            focusedField = .title
        }
    }
}

