//
//  ContextSwitcherView.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/17/24.
//

import SwiftUI

struct ContextSwitcherView: View {
    @StateObject private var contextManager = ContextManager()
    @State private var isAddingContext = false
    @State private var searchText = ""
    @State private var isHovered = false
    
    var filteredContexts: [ContextCard] {
        if searchText.isEmpty {
            return contextManager.contexts
        }
        return contextManager.contexts.filter { context in
            context.title.localizedCaseInsensitiveContains(searchText) ||
            context.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Header with Title and Search
            VStack(spacing: 10) {
                Text("Context Switcher")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .bold()
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search contexts...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding(.top)
            
            // Context List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(contextManager.contexts) { context in
                        contextCard(context: context)
                    }
                }
            }
            
            // Add New Context Button
            Button(action: { isAddingContext = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Context")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.indigo)
                        .shadow(color: .indigo.opacity(0.3), radius: isHovered ? 10 : 5)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
            
            NavigationLink(destination: MainView()) {
                Text("Back")
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .frame(width: AppDimensions.width, height: AppDimensions.height)
        .background(Color(NSColor.textBackgroundColor))
        .sheet(isPresented: $isAddingContext) {
            NewContextCard(
                isPresented: $isAddingContext,
                onCreateContext: { newContext in
                    contextManager.createContext(title: newContext.title, workType: newContext.workType, workDepth: newContext.workDepth, notes: newContext.notes)
                }
            )
        }
    }
    
    private func contextCard(context: ContextCard) -> some View {
        Button(action: { toggleContextActive(context) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.title)
                        .font(.headline)
                    HStack {
                        Text(context.workType)
                            .font(.caption)
                        Text("•")
                        Text(context.workDepth)
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                    
                    if !context.notes.isEmpty {
                        Text(context.notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                Spacer()
                
                if context.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(context.isActive ? Color.indigo : Color.gray.opacity(0.1))
            )
            .foregroundColor(context.isActive ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleContextActive(_ context: ContextCard) {
        contextManager.switchToContext(context)
    }
}
