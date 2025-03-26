//
//  SupabaseManager.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 20/03/25.
//

import Foundation
import SwiftUI
import Supabase

struct Member: Codable {
    let id: UUID?
    let email: String
    let password: String?
    let firstName: String
    let lastName: String
    var favourites: [String]
    let created_at: Date?
    
    init(id: UUID? = nil, email: String, password: String? = nil, firstName: String, lastName: String, favourites: [String] = [], created_at: Date? = nil) {
        self.id = id
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.favourites = favourites
        self.created_at = created_at
    }
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
    

    private let supabaseURL = URL(string: "https://iswzgemgctojcdnbxvjv.supabase.co")!

    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlzd3pnZW1nY3RvamNkbmJ4dmp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyMzAwODgsImV4cCI6MjA1NzgwNjA4OH0.zmATRCYC3V8_BtROa_PzmFxabWQf0NjyNSQaMrwPL7E"
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws -> AuthResponse {
        // Only handle authentication, no extra data storage yet
        let authResponse = try await client.auth.signUp(email: email, password: password)
        currentUser = authResponse.user
        
        // Store user information for later storage after OTP verification
        UserDefaults.standard.set(email, forKey: "pendingSignupEmail")
        UserDefaults.standard.set(password, forKey: "pendingSignupPassword")
        UserDefaults.standard.set(firstName, forKey: "pendingSignupFirstName")
        UserDefaults.standard.set(lastName, forKey: "pendingSignupLastName")
        
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
    
    func checkEmailExists(_ email: String) async throws -> Bool {
        let response: PostgrestResponse<[Member]> = try await SupabaseManager.shared.client
            .from("members")
            .select()
            .eq("college_email", value: email.lowercased())
            .execute()
        
        return !response.value.isEmpty
    }
    
    func verifyOTP(email: String, otp: String, completion: @escaping (Result<Session, Error>) -> Void) {
        Task {
            do {
                let response = try await client.auth.verifyOTP(email: email, token: otp, type: .email)
                
                // If OTP is verified and we have a session, save the member data to Supabase
                if let session = response.session, 
                   let pendingEmail = UserDefaults.standard.string(forKey: "pendingSignupEmail"),
                   let firstName = UserDefaults.standard.string(forKey: "pendingSignupFirstName"),
                   let lastName = UserDefaults.standard.string(forKey: "pendingSignupLastName") {
                    
                    // Create the member record in Supabase
                    try await saveMemberData(userId: session.user.id, email: pendingEmail, firstName: firstName, lastName: lastName)
                    
                    // Clear stored signup data
                    UserDefaults.standard.removeObject(forKey: "pendingSignupEmail")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupPassword")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupFirstName")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupLastName")
                }
                
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
    
    // Function to save member data to Supabase "Member" table
    func saveMemberData(userId: UUID, email: String, firstName: String, lastName: String) async throws {
        let member = Member(
            id: userId,
            email: email,
            firstName: firstName,
            lastName: lastName,
            favourites: []
        )
        
        do {
            _ = try await SupabaseManager.shared.client
                .from("Member")
                .insert(member)
                .execute()
            
            print("Member data saved successfully with ID: \(userId)")
        } catch {
            print("Error saving member data: \(error)")
            throw error
        }
    }
    
    func verifyLoginOTP(email: String, otp: String) async throws -> Session {
        let response = try await SupabaseManager.shared.client.auth.verifyOTP(
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
                try await SupabaseManager.shared.client.auth.update(user: UserAttributes(password: newPassword))
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
        try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
    }
    
    func updateFavourites(userId: UUID, bookId: UUID, isFavourite: Bool) async throws {
           // First, try to fetch the current member data
           let query = client
               .from("Member")
               .select()
               .eq("id", value: userId)
           
           do {
               let response: [Member] = try await query.execute().value
               
               // If member doesn't exist, create a new record
               if response.isEmpty {
                   let newMember = Member(
                       id: userId,
                       email: currentUser?.email ?? "",
                       firstName: "",
                       lastName: "",
                       favourites: isFavourite ? [bookId.uuidString] : []
                   )
                   
                   try await client
                       .from("Member")
                       .insert(newMember)
                       .execute()
               } else {
                   // Member exists, update their favorites
                   var member = response[0]
                   let bookIdString = bookId.uuidString
                   
                   if isFavourite {
                       if !member.favourites.contains(bookIdString) {
                           member.favourites.append(bookIdString)
                       }
                   } else {
                       member.favourites.removeAll { $0 == bookIdString }
                   }
                   
                   try await client
                       .from("Member")
                       .update(["favourites": member.favourites])
                       .eq("id", value: userId)
                       .execute()
               }
               
               print("Favourites updated successfully for user: \(userId)")
           } catch {
               print("Error updating favourites: \(error)")
               throw error
           }
       }
}

