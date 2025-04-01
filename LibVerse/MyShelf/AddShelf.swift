//
//  AddShelf.swift
//  LibVerse
//
//  Created by Piyush on 31/03/25.
//

import Foundation
import SwiftUI

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
            
                TextField("Hello World", text: $selfName)
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
