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
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Set a New Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Create a secure password for your account")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 30)
                
                Spacer()
                
                VStack(spacing: 20) {
                    passwordField(title: "New Password", text: $newPassword, showPassword: $showNewPassword, placeholder: "Enter new password")
                    
                    passwordField(title: "Confirm Password", text: $confirmPassword, showPassword: $showConfirmPassword, placeholder: "Re-enter new password")
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await forgotPassword()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Reset Password")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(minWidth: 120, maxWidth: 280)
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(newPassword.count >= 8 && newPassword == confirmPassword ? Color.blue : Color.gray)
                .cornerRadius(12)
                .disabled(isLoading || newPassword.count < 8 || newPassword != confirmPassword)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func passwordField(title: String, text: Binding<String>, showPassword: Binding<Bool>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                if showPassword.wrappedValue {
                    TextField(placeholder, text: text)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                } else {
                    SecureField(placeholder, text: text)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showPassword.wrappedValue.toggle()
                }) {
                    Image(systemName: showPassword.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    private func forgotPassword() async {
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
            // Get email from UserDefaults
            if let email = UserDefaults.standard.string(forKey: "resetEmail") {
                try await SupabaseManager.shared.updatePassword(email: email, newPassword: newPassword)
                
                DispatchQueue.main.async {
                    // Clear stored email
                    UserDefaults.standard.removeObject(forKey: "resetEmail")
                    
                    alertMessage = "Password updated successfully!"
                    showAlert = true
                    dismiss()
                    // Navigate to login page
                    showUserInitialView = false
                    showMainApp = false
                }
            } else {
                alertMessage = "Error: Email not found for password reset"
                showAlert = true
            }
        } catch {
            DispatchQueue.main.async {
                alertMessage = "Failed to update password: \(error.localizedDescription)"
                showAlert = true
            }
        }
        
        isLoading = false
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    UserNewPasswordView(showMainApp: .constant(false), showUserInitialView: .constant(false))
}
