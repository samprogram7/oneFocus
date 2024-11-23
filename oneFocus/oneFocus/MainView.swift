//
//  MainView.swift
//  oneFocus
//
//  Created by Samuel Rojas on 11/21/24.
//

import SwiftUI
import Foundation
import Combine

struct MainView: View {
    @State private var isFlowActive = false
    @State private var isSearchActive = false
    @State private var isHovered = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Title with animation
                Text("oneFocus")
                    .font(.largeTitle)
                    .fontDesign(.serif)
                    .bold()
                    .padding(.top)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovered)
                
                Spacer()
                
                // Feature buttons in the middle
                VStack(spacing: 20) {
                    // Flow button
                    NavigationLink(destination: Flow(), isActive: $isFlowActive) {
                        VStack {
                            Image(systemName: "timer")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            Text("Flow")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                                .shadow(color: .blue.opacity(0.5), radius: isFlowActive ? 15 : 5, x: 0, y: isFlowActive ? 10 : 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .scaleEffect(isFlowActive ? 0.9 : 1)
                        .rotation3DEffect(
                            .degrees(isFlowActive ? 360 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6), value: isFlowActive)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Search button
                    NavigationLink(destination: SearchView(), isActive: $isSearchActive) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            Text("QuickQuery")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                                .shadow(color: .green.opacity(0.5), radius: isSearchActive ? 15 : 5, x: 0, y: isSearchActive ? 10 : 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .scaleEffect(isSearchActive ? 0.9 : 1)
                        .rotation3DEffect(
                            .degrees(isSearchActive ? 360 : 0),
                            axis: (x: 1, y: 0, z: 0)
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6), value: isSearchActive)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Quit button with hover effect
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                                .opacity(isHovered ? 1 : 0)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }
            }
            .frame(width: AppDimensions.width, height: AppDimensions.height)
            .background(Color(NSColor.textBackgroundColor))
        }
    }
}


#Preview {
    MainView()
}
