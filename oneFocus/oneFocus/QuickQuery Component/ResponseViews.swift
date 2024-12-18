//
//  ResponseViews.swift
//  oneFocus
//
//  Created by Samuel Rojas on 12/4/24.
//
import SwiftUI
import Foundation

struct ResponseSegment: Identifiable {
    let id = UUID()
    let content: String
    let isCode: Bool
}

struct AIResponseView: View {
    let response: String
    
    var body: some View {
        let segments = parseResponse(response)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(segments) { segment in
                    if segment.isCode {
                        CodeBlockView(code: segment.content)
                    } else {
                        Text(segment.content)
                            .padding(.horizontal)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
    }
    
    // Helper function to parse response
    private func parseResponse(_ text: String) -> [ResponseSegment] {
        var segments: [ResponseSegment] = []
        let codeBlockRegex = try! NSRegularExpression(pattern: "```([\\s\\S]*?)```", options: [])
        let nsString = text as NSString
        var lastIndex = 0
        
        let matches = codeBlockRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        for match in matches {
            // Add text before code block
            if match.range.location > lastIndex {
                let textRange = NSRange(location: lastIndex, length: match.range.location - lastIndex)
                segments.append(ResponseSegment(
                    content: nsString.substring(with: textRange),
                    isCode: false
                ))
            }
            
            // Add code block
            let codeContent = nsString.substring(with: match.range)
                .replacingOccurrences(of: "```", with: "") // Remove markdown code indicators
                .trimmingCharacters(in: .whitespacesAndNewlines)
            segments.append(ResponseSegment(
                content: codeContent,
                isCode: true
            ))
            
            lastIndex = match.range.location + match.range.length
        }
        
        // Add remaining text after last code block
        if lastIndex < text.count {
            let remainingText = nsString.substring(from: lastIndex)
            segments.append(ResponseSegment(
                content: remainingText,
                isCode: false
            ))
        }
        
        return segments
    }
}

struct CodeBlockView: View {
    let code: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Code")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            HighlightedCodeText(code: code)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.textBackgroundColor).opacity(0.8))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct HighlightedCodeText: View {
    var code: String
    
    var body: some View {
        let attributedString = highlightCode(code)
        Text(AttributedString(attributedString))
            .font(.system(.body, design: .monospaced))
    }
    
    private func highlightCode(_ input: String) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: input)
            
            // Define patterns and their colors
            let patterns: [(pattern: String, color: NSColor)] = [
                ("\".*?\"", .systemRed),                    // Strings
                ("//.*", .systemGray),                      // Comments
                ("\\b(func|let|var|if|else|guard|return|class|struct)\\b", .systemPurple), // Keywords
                ("\\b(String|Int|Double|Bool|Array)\\b", .systemBlue), // Types
                ("\\b\\d+\\b", .systemOrange)              // Numbers
            ]
            
            // Apply highlighting
            for (pattern, color) in patterns {
                do {
                    let regex = try NSRegularExpression(pattern: pattern)
                    let range = NSRange(location: 0, length: input.utf16.count)
                    let matches = regex.matches(in: input, range: range)
                    
                    for match in matches {
                        attributedString.addAttribute(.foregroundColor,
                                                    value: color,
                                                    range: match.range)
                    }
                } catch {
                    print("Regex error: \(error)")
                }
            }
            
            return attributedString
        }
}
