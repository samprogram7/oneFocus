import SwiftUI
import Foundation

struct NewContextCard: View {
    @Binding var isPresented: Bool
    @State var contextTitle: String = ""
    let contextWorkType = ["Coding", "School", "Writing", "Research", "Design", "Other"]
    @State private var defaultWorkType: String = "Coding"
    let contextWorkDepth = ["Deep Work", "Shallow Work"]
    @State private var defaultWorkDepth: String = "Deep Work"
    @State var contextWorkDescription: String = ""
    var onCreateContext: (ContextCard) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New Context")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Title Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                TextField("Enter Title", text: $contextTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Work Type Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Work Type")
                    .font(.headline)
                Picker("Work Type", selection: $defaultWorkType) {
                    ForEach(contextWorkType, id: \.self) { workType in
                        Text(workType)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Work Depth Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Work Depth")
                    .font(.headline)
                Picker("Work Depth", selection: $defaultWorkDepth) {
                    ForEach(contextWorkDepth, id: \.self) { workDepth in
                        Text(workDepth)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Notes Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                TextEditor(text: $contextWorkDescription)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            // Buttons
            HStack(spacing: 16) {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                
                Button("Create") {
                    let newContext = ContextCard(
                        title: contextTitle,
                        workType: defaultWorkType,
                        workDepth: defaultWorkDepth,
                        notes: contextWorkDescription
                    )
                    onCreateContext(newContext)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(contextTitle.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}
