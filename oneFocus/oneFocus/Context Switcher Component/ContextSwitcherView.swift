//
//  ContextSwitcherView.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/17/24.
//

import SwiftUI

struct ContextSwitcherView: View {
    @State var shouldPresentForm: Bool = false
    @State private var searchText = ""
    @State private var isHovered = false
    @State private var contexts: [ContextCardModel] = []
    private let storageManager = StorageManager()
    var body: some View {
        VStack(spacing: 15) {
            // Header with Title and Search
            VStack(spacing: 10) {
                Text("Context Switcher")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .bold()
                    .padding()
                
                // Add New Context Button
                Button(action: {
                    shouldPresentForm = true
                }) {
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
                .padding()
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isHovered ? 1.02 : 1.0)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }
                .sheet(isPresented: $shouldPresentForm){
                    CardContextForm(contexts: $contexts)
                }
                //Rendering The Context Cards
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(contexts) { context in
                            ContextCard(
                                context: context,
                                onDelete: {
                                    // Remove the context from the array
                                        if let index = contexts.firstIndex(where: { $0.id == context.id }) {
                                            contexts.remove(at: index)
                                        }
                                    }
                            )
                            
                        }
                    }
                    .padding(.horizontal)
                }
                
                NavigationLink(destination: MainView()) {
                    Text("Back")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .padding(.horizontal)
            .frame(width: AppDimensions.width, height: AppDimensions.height)
            .background(Color(NSColor.textBackgroundColor))
        }
        .onAppear{
            contexts = storageManager.loadContexts()
        }
    }
}
