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
    var body: some View {
        NavigationStack {
            VStack {
                // Title at top
                Text("oneFocus")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Spacer()
                
                // Feature buttons in the middle
                VStack(spacing: 20) {
                    // Timer button
                    NavigationLink(destination: Flow().frame(minWidth: 300, maxWidth: 300)
                        .frame(minHeight: 400, maxHeight: 400)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding()
                    ) {
                        VStack {
                            Image(systemName: "timer")
                                .font(.system(size: 30))
                            Text("Flow")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.4))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Search button
                    NavigationLink(destination: Text("Quick Query View")) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30))
                            Text("QuickQuery")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.4))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Quit button at bottom
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .foregroundStyle(.red)
                }
                .padding(.bottom)
            }
            .frame(width: 300, height: 400)
        }
    }
}

#Preview {
    MainView()
}
