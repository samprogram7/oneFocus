//
//  SearchView.swift
//  oneFocus
//
//  Created by Samuel Rojas on 11/22/24.
//

import SwiftUI


struct SearchView: View {
    @StateObject private var viewModel = QueryModels()
    @State private var searchQuery = ""
    @State private var currentModel: String = "Web"
    @Namespace private var namespace
    let searchModel = ["Web", "GPT", "Gemini", "Claude"]
    
    @State private var selectedIndex: Int = 0
    
    
    enum ModelColor {
        case web, gpt, claude, gemini
        
        var color: Color {
            switch self {
            case .web: return .gray
            case .gpt: return .green
            case . claude: return .orange
            case .gemini: return .blue
            }
        }
        
        static func getColor(for model: String) -> Color {
            switch model {
            case "Web": return ModelColor.web.color
            case "GPT": return ModelColor.gpt.color
            case "Claude": return ModelColor.claude.color
            case "Gemini": return ModelColor.gemini.color
            default: return .gray
            }
        }
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                Text("QuickQuery")
                    .font(.title)
                    .italic()
                    .padding(.top)
                
                //Model Picker
                HStack(spacing: 0) {
                      ForEach(Array(searchModel.enumerated()), id: \.element) { index, model in
                          Text(model)
                              .padding(.vertical, 8)
                              .padding(.horizontal, 16)
                              .background(
                                  ZStack {
                                      if selectedIndex == index {
                                          RoundedRectangle(cornerRadius: 8)
                                              .fill(ModelColor.getColor(for: model))
                                              .matchedGeometryEffect(id: "SelectedBackground", in: namespace)
                                      }
                                  }
                              )
                              .foregroundColor(selectedIndex == index ? .white : .primary)
                              .onTapGesture {
                                  withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                      selectedIndex = index
                                      currentModel = model
                                  }
                              }
                      }
                  }
                  .background(Color.secondary.opacity(0.2))
                  .cornerRadius(8)
                  .padding()
                
                // Custom Search Bar
                CustomSearchBar(
                    text: $searchQuery,
                    placeholder: "What can I help you with?",
                    onSubmit: {
                        if !searchQuery.isEmpty {
                            viewModel.search(query: searchQuery)
                        }
                    }
                )
                
                NavigationLink(destination: MainView().frame(width: AppDimensions.width, height: AppDimensions.height, alignment: .center)){
                    Text("Back")
                }
                
                // Results Section
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.results) { item in
                                ResultCard(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Results Section
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.results) { item in
                            ResultCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(width: AppDimensions.width, height: AppDimensions.height)
        .background(Color(NSColor.textBackgroundColor))
    }
}

// Custom Search Bar View
struct CustomSearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 18))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .onSubmit(onSubmit)
            
            // Clear button
            if !text.isEmpty {
                Button(action: {
                    withAnimation {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// Separate view for result cards
struct ResultCard: View {
    let item: SearchItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
            Text(item.snippet)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Link(item.link, destination: URL(string: item.link)!)
                .font(.caption)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#Preview {
    SearchView()
}
