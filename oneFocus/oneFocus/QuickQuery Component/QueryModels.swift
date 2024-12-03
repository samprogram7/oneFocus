//
//  GoogleSearchFetch.swift
//  oneFocus
//
//  Created by Samuel Rojas on 11/22/24.
//

import SwiftUI

// Model for search results
struct GoogleSearchResult: Codable {
    let items: [SearchItem]
}

struct SearchItem: Codable, Identifiable {
    var id: String { link } // Using link as unique identifier
    let title: String
    let link: String
    let snippet: String
}

// View Model
class QueryModels: ObservableObject {
    @Published var results: [SearchItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    let apiKey = "AIzaSyC14QY4aG4LMcJyBFxrO6CQINW-n7AWktM" // Put your API key here
    let searchEngineId = "a1767236bab144997" // Put your Search Engine ID here
    
    func search(query: String) {
        isLoading = true
        errorMessage = ""
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/customsearch/v1?key=\(apiKey)&cx=\(searchEngineId)&q=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    let searchResult = try JSONDecoder().decode(GoogleSearchResult.self, from: data)
                    self?.results = searchResult.items
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
}
