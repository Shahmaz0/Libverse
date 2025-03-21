//
//  ForgetPasswordEmailView.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 21/03/25.
//

import Foundation
import SwiftUI

struct ForgotPasswordEmailView: View {
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var navigateToOTP = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Text("Forgot Password")
                                .font(.custom("Courier New", size: 25))
                                .bold()
                                .frame(width: 287, alignment: .center)
                            
                            Text("Enter your email address to receive a verification code")
                                .font(.custom("Courier", size: 16))
                                .frame(width: 350)
                                .multilineTextAlignment(.center)
                        }
                        
                        customTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress, autocapitalization: .none)
                        
                        Button(action: sendResetEmail) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            } else {
                                Text("Send Code")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(!email.isEmpty ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(email.isEmpty || isLoading)
                        .padding(.horizontal)
                    }
                    .padding()
                }
                Spacer()
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .alert("Alert", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(isPresented: $navigateToOTP) {
                ForgotPasswordOTPView(email: email)
            }
        }
    }
    
    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, autocapitalization: UITextAutocapitalizationType = .words) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
            }
            TextField("", text: text)
                .padding()
                .frame(height: 43)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1.25)
                )
        }
    }
    
    private func sendResetEmail() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email address"
            showAlert = true
            return
        }

        isLoading = true
        Task {
            do {
                try await SupabaseManager.shared.resetPasswordForEmail(email)
                DispatchQueue.main.async {
                    // Store the email in UserDefaults
                    UserDefaults.standard.set(email, forKey: "resetEmail")
                    isLoading = false
                    alertMessage = "Password reset instructions sent to your email"
                    showAlert = true
                    navigateToOTP = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Error sending reset email: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
