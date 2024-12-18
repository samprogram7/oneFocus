//
//  ContextSwitcherView.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/17/24.
//

import SwiftUI

struct ContextSwitcherView: View {
    @State private var isAddingContext = false
    @State private var searchText = ""
    @State private var selectedContext: String?
    @State private var isHovered = false
    
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
                VStack(spacing: 10) {
                    // Active Context Card (if any)
                    if let selectedContext = selectedContext {
                        activeContextCard(context: selectedContext)
                    }
                    
                    // Other Contexts
                    ForEach(["Bug Fix", "Feature Dev", "Documentation"], id: \.self) { context in
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
            NewContextSheet(isPresented: $isAddingContext)
        }
    }
    
    private func contextCard(context: String) -> some View {
        Button(action: { selectedContext = context }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(context)
                        .font(.headline)
                    Text("2 apps · 3 tabs")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("1h 30m")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedContext == context ? Color.indigo : Color.gray.opacity(0.1))
            )
            .foregroundColor(selectedContext == context ? .white : .primary)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func activeContextCard(context: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Active Context")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Image(systemName: "checkmark.circle.fill")
            }
            Text(context)
                .font(.headline)
            HStack {
                Text("2 apps · 3 tabs")
                Spacer()
                Text("1h 30m")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.indigo)
        )
        .foregroundColor(.white)
    }
    
}


