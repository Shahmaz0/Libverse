//
//  myself.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 21/03/25.
//

import Foundation
import SwiftUI

// Modal View
struct AddModalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selfName: String = ""
    var onCreateShelf: (String) -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Give your shelf a name")
                    .font(.custom("Charter", size: 32))
                    .foregroundColor(Color(hex: "7C4B2D"))
                    .padding(.top, 40)
                
                // Text field with black stroke
                TextField("", text: $selfName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .frame(width: UIScreen.main.bounds.width - 80, height: 50)
                    .background(Color(hex: "FCEFD5"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                // Buttons
                HStack(spacing: 20) {
                    // Cancel button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.custom("Charter", size: 20))
                            .foregroundColor(.black)
                            .frame(width: 150, height: 50)
                            .background(Color(hex: "FCEFD5"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    
                    // Create button
                    Button(action: {
                        if !selfName.isEmpty {
                            onCreateShelf(selfName)
                            dismiss()
                        }
                    }) {
                        Text("Create")
                            .font(.custom("Charter", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 150, height: 50)
                            .background(Color(hex: "DE5B23"))
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct myshelf: View {
    @State private var showingAddModal = false
    @State private var categories: [String] = ["Favorites"]
    @State private var selectedCategory: String = "Favorites"
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Category buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(category == selectedCategory ? .white : Color(hex: "875232"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        category == selectedCategory ?
                                        Color(hex: "DE5B23") :
                                        Color(hex: "FCEFD5")
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 0)
                                            .stroke(Color(hex: "875232"), lineWidth: category == selectedCategory ? 0 : 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                }
                
                // Fixed top thick line
                Rectangle()
                    .fill(Color(hex: "C89A69"))
                    .frame(width: UIScreen.main.bounds.width, height: 28)
                    .padding(.top, 20)
                
                // Scrollable content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<20) { index in
                            // Image section
                            Image("selfbackgroun")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width - 24, height: 143)
                                .clipped()
                            
                            // Horizontal line
                            Rectangle()
                                .fill(Color(hex: "C89A69"))
                                .frame(width: UIScreen.main.bounds.width - 24, height: 12)
                        }
                    }
                }
            }
            
            // Left vertical line
            Rectangle()
                .fill(Color(hex: "C89A69"))
                .frame(width: 12, height: UIScreen.main.bounds.height - 100)
                .position(x: 6, y: (UIScreen.main.bounds.height + 150) / 2)
            
            // Right vertical line
            Rectangle()
                .fill(Color(hex: "C89A69"))
                .frame(width: 12, height: UIScreen.main.bounds.height - 100)
                .position(x: UIScreen.main.bounds.width - 6, y: (UIScreen.main.bounds.height + 150) / 2)
            
            // Add button
            Button(action: {
                showingAddModal = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color(hex: "875232"))
            }
            .position(x: UIScreen.main.bounds.width - 40, y: 20)
            
            // Search button
            Button(action: {
                // Search action here
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "875232"))
            }
            .position(x: UIScreen.main.bounds.width - 80, y: 20)
        }
        .sheet(isPresented: $showingAddModal) {
            AddModalView { newShelfName in
                categories.append(newShelfName)
                selectedCategory = newShelfName
            }
        }
    }
}

// Extension to support hex color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    myshelf()
} 
