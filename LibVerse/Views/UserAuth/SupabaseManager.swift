//
//  SupabaseManager.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 20/03/25.
//

import Foundation
import SwiftUI
import Supabase

struct UserData: Codable {
    let id: UUID
    let fullName: String
    let email: String
    let contactNumber: String
}

// Login credentials model
struct LoginCredentials {
    let email: String
    let password: String
}


import SwiftUI
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    @Published var client: SupabaseClient
    @Published var currentUser: User?
    @Published var currentSession: Session?
    
    private let supabaseURL = URL(string: "https://ghpqzceylrmteqwqbopv.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdocHF6Y2V5bHJtdGVxd3Fib3B2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxNjYzNzYsImV4cCI6MjA1NDc0MjM3Nn0.duY-f0-9pprTdouAqwPojMbw05PuOW3B5tok3w9zxOA"
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    func signUp(email: String, password: String) async throws -> AuthResponse {
        // Only handle authentication, no extra data storage
        let authResponse = try await client.auth.signUp(email: email, password: password)
        currentUser = authResponse.user
        return authResponse
    }
    
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(email: email, password: password)
        try await client.auth.signOut() // Sign out temporarily to force OTP
                try await client.auth.signInWithOTP(email: email)
                
                // Store email for OTP verification
                UserDefaults.standard.set(email, forKey: "pendingLoginEmail")
                UserDefaults.standard.set(password, forKey: "pendingLoginPassword")
                
        
        DispatchQueue.main.async {
            self.currentUser = session.user
            self.currentSession = session
        }
        
        print("User ID: \(session.user.id)")
        return session
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
    }
    
    func verifyOTP(email: String, otp: String, completion: @escaping (Result<Session, Error>) -> Void) {
        Task {
            do {
                let response = try await client.auth.verifyOTP(email: email, token: otp, type: .email)
                DispatchQueue.main.async {
                    completion(.success(response.session!))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func verifyLoginOTP(email: String, otp: String) async throws -> Session {
            let response = try await client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .email
            )
            
            // If OTP is verified, complete login with stored credentials
            if let storedPassword = UserDefaults.standard.string(forKey: "pendingLoginPassword") {
                let session = try await client.auth.signIn(email: email, password: storedPassword)
                
                // Clear stored credentials
                UserDefaults.standard.removeObject(forKey: "pendingLoginEmail")
                UserDefaults.standard.removeObject(forKey: "pendingLoginPassword")
                
                DispatchQueue.main.async {
                    self.currentUser = session.user
                    self.currentSession = session
                }
                
                return session
            } else {
                throw NSError(domain: "Login", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login credentials not found"])
            }
        }
    
   

    func verifyPasswordReset(token: String, newPassword: String) async throws {
        // First verify the token
        let session = try await client.auth.verifyOTP(
            email: currentUser?.email ?? "",
            token: token,
            type: .recovery
        )
        
        // If session is valid, update the password
        if session.user != nil {
            try await client.auth.update(user: UserAttributes(
                password: newPassword
            ))
        } else {
            throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token"])
        }
    }
    
    func updatePassword(email: String, newPassword: String) async throws {
        // First verify the OTP
        if let otp = UserDefaults.standard.string(forKey: "resetOTP") {
            let session = try await client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .recovery
            )
            
            // If OTP is verified, update the password
            if session.user != nil {
                try await client.auth.update(user: UserAttributes(password: newPassword))
                // Clear the OTP after successful update
                UserDefaults.standard.removeObject(forKey: "resetOTP")
            } else {
                throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid OTP"])
            }
        } else {
            throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "OTP not found"])
        }
    }
    
    func resetPasswordForEmail(_ email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
}
