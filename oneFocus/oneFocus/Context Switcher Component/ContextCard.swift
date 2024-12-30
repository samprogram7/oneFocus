//
//  ContextCard.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/23/24.
//

import SwiftUI

struct ContextCard: View {
    var context: ContextCardModel
    let onDelete: () -> Void
    var systemManager = SystemManager()
    @State private var isRestoring = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(context.workType.rawValue.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // Priority indicator
                Circle()
                    .fill(priorityColor)
                    .frame(width: 12, height: 12)
                
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red.opacity(0.8))
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            // Work details
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(context.workDepth.rawValue.capitalized)
                        .font(.system(size: 14))
                } icon: {
                    Image(systemName: "arrow.down.right.circle.fill")
                        .foregroundColor(.blue)
                }
                
                Label {
                    Text(context.note)
                        .font(.system(size: 14))
                        .lineLimit(2)
                } icon: {
                    Image(systemName: "note.text")
                        .foregroundColor(.purple)
                }
            }
            
            if isRestoring {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Restoring context...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(isPressed ? 0.3 : 0), lineWidth: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
                isRestoring = true
            }
            
            Task {
                do {
                    try await systemManager.restoreState(context.systemState)
                } catch {
                    print("Error restoring state: \(error)")
                }
                
                withAnimation {
                    isRestoring = false
                    isPressed = false
                }
            }
        }
    }
    
    private var priorityColor: Color {
        switch context.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
}
