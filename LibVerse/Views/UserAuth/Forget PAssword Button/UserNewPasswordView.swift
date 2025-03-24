//
//  ForgetPasswordView.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 21/03/25.
//

import Foundation
import SwiftUI

struct UserNewPasswordView: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @Binding var showMainApp: Bool
    @Binding var showUserInitialView: Bool
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 20) {
                            passwordField(
                                title: "New Password",
                                text: $newPassword,
                                showPassword: $showNewPassword,
                                placeholder: "Enter new password"
                            )
                            
                            passwordField(
                                title: "Confirm Password",
                                text: $confirmPassword,
                                showPassword: $showConfirmPassword,
                                placeholder: "Re-enter new password"
                            )
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                await forgotPassword()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            } else {
                                Text("Reset Password")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(newPassword.count >= 8 && newPassword == confirmPassword ?
                                              Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(isLoading || newPassword.count < 8 || newPassword != confirmPassword)
                        .padding(.horizontal)
                    }
                    .padding()
                }
                Spacer()
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .alert("Password Reset", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage == "Password updated successfully!" {
                        // Dismiss all sheets
                        dismiss()
                        presentationMode.wrappedValue.dismiss()
                        showUserInitialView = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .navigationBarBackButtonHidden(true)
        }
        
        private func customTextField(placeholder: String, text: Binding<String>, isSecure: Bool) -> some View {
            VStack {
                if isSecure {
                    SecureField(placeholder, text: text)
                        .padding()
                        .frame(height: 43)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.black, lineWidth: 1.25)
                        )
                } else {
                    TextField(placeholder, text: text)
                        .padding()
                        .frame(height: 43)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.black, lineWidth: 1.25)
                        )
                }
            }
        }
        
        private func forgotPassword() async {
            // Validation remains the same
            if newPassword.isEmpty || confirmPassword.isEmpty {
                alertMessage = "Please fill in both password fields"
                showAlert = true
                return
            }
            
            if newPassword != confirmPassword {
                alertMessage = "Passwords do not match"
                showAlert = true
                return
            }
            
            if newPassword.count < 8 {
                alertMessage = "Password must be at least 8 characters long"
                showAlert = true
                return
            }
            
            isLoading = true
            
            do {
                if let email = UserDefaults.standard.string(forKey: "resetEmail") {
                    try await SupabaseManager.shared.updatePassword(email: email, newPassword: newPassword)
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.removeObject(forKey: "resetEmail")
                        alertMessage = "Password updated successfully!"
                        showAlert = true
                    }
                } else {
                    alertMessage = "Error: Email not found for password reset"
                    showAlert = true
                }
            } catch {
                alertMessage = "Failed to update password: \(error.localizedDescription)"
                showAlert = true
            }
            
            isLoading = false
        }
    
    private func passwordField(title: String, text: Binding<String>, showPassword: Binding<Bool>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Courier", size: 16))
                .foregroundColor(.black)
            
            HStack {
                if showPassword.wrappedValue {
                    TextField(placeholder, text: text)
                        .font(.custom("Courier", size: 16))
                } else {
                    SecureField(placeholder, text: text)
                        .font(.custom("Courier", size: 16))
                }
                
                Button(action: {
                    showPassword.wrappedValue.toggle()
                }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(height: 43)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 1.25)
            )
        }
    }

    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    UserNewPasswordView(showMainApp: .constant(false), showUserInitialView: .constant(false))
}
