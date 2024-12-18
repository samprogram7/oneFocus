//
//  GoogleSearchFetch.swift
//  oneFocus
//
//  Created by Samuel Rojas on 11/22/24.
//

import SwiftUI
import Foundation

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

struct GeminiResponse: Codable {
    struct Candidate: Codable {
        struct Content: Codable {
            struct Part: Codable {
                let text: String
            }
            let parts: [Part]
        }
        let content: Content
    }
    let candidates: [Candidate]
}

// View Model
class QueryModels: ObservableObject {
    @Published var results: [SearchItem] = []
    @Published var aiResponse: String? = nil
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    let apiKey = "AIzaSyC14QY4aG4LMcJyBFxrO6CQINW-n7AWktM" // Put your API key here
    let searchEngineId = "a1767236bab144997" // Put your Search Engine ID here
    let geminiApiKey = "AIzaSyDZbv7QZbbXQEJa0FmFK5edEnm6zm7jaFk"
    
    func search(query: String, model: String) {
        isLoading = true
        errorMessage = ""
        results = []
        aiResponse = nil
        
        switch model {
        case "Web":
            performWebSearch(query: query)
        case "Gemini":
            performGeminiSearch(query: query)
        default:
            performWebSearch(query: query)
        }
    }
    
    private func performWebSearch(query: String){
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
    
    
    private func performGeminiSearch(query: String) {
        let endpoint = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(geminiApiKey)")!
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": query]
                    ]
                ]
            ]
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            self.errorMessage = "Failed to create request"
            self.isLoading = false
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data recieved"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    if let text = response.candidates.first?.content.parts.first?.text {
                        self?.aiResponse = text
                    }
                } catch {
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

