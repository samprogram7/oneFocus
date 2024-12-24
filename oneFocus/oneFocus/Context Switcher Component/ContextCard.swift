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
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            HStack {
                Text(context.title)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                }
            }
            
            Text("Work Type: \(context.workType.rawValue.capitalized)")
            Text("Work Depth: \(context.workDepth.rawValue.capitalized)")
            Text("Priority: \(context.priority.rawValue.capitalized)")
            Text("Last Left off: \(context.note)")
                .lineLimit(2)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
    }
}
