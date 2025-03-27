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
    var myBag: [String]
    var shelves: [String: [String]]? // Dictionary mapping shelf names to arrays of book IDs
    let created_at: Date?
    
    init(id: UUID? = nil, email: String, password: String? = nil, firstName: String, lastName: String, favourites: [String] = [], mybag: [String] = [], shelves: [String: [String]]? = ["Favorites": []], created_at: Date? = nil) {
        self.id = id
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.favourites = favourites
        self.myBag = mybag
        self.shelves = shelves
        self.created_at = created_at
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, password, firstName, lastName, favourites, myBag, shelves, created_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        favourites = try container.decode([String].self, forKey: .favourites)
        myBag = try container.decode([String].self, forKey: .myBag)
        created_at = try container.decodeIfPresent(Date.self, forKey: .created_at)
        
        // Special handling for shelves as JSONB
        if let shelvesObj = try? container.decodeIfPresent([String: [String]].self, forKey: .shelves) {
            shelves = shelvesObj
            print("📖 Decoded shelves directly: \(String(describing: shelves))")
        } else if let shelvesData = try? container.decodeIfPresent(Data.self, forKey: .shelves) {
            let decoder = JSONDecoder()
            shelves = try? decoder.decode([String: [String]].self, from: shelvesData)
            print("📖 Decoded shelves from Data: \(String(describing: shelves))")
        } else if let anyValue = try? container.decodeIfPresent(AnyDecodable.self, forKey: .shelves) {
            // Try to convert Any value to expected dictionary
            print("📖 Decoding shelves from AnyDecodable: \(anyValue.value)")
            if let dict = anyValue.value as? [String: [String]] {
                shelves = dict
                print("📖 Converted directly to [String: [String]]")
            } else if let dict = anyValue.value as? [String: [Any]] {
                // Convert [Any] arrays to [String] arrays
                var convertedDict: [String: [String]] = [:]
                for (key, values) in dict {
                    print("📖 Converting values for key: \(key)")
                    convertedDict[key] = values.compactMap { value in
                        if let stringValue = value as? String {
                            return stringValue
                        }
                        print("⚠️ Non-string value found: \(value)")
                        return nil
                    }
                }
                shelves = convertedDict
                print("📖 Converted from [String: [Any]] to [String: [String]]: \(convertedDict)")
            } else {
                shelves = ["Favorites": []]
                print("📖 Could not convert, using default")
            }
        } else {
            shelves = ["Favorites": []]
            print("📖 No shelves field found, using default")
        }
    }
    
    // Custom encoding to ensure shelves is properly serialized
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(favourites, forKey: .favourites)
        try container.encode(myBag, forKey: .myBag)
        try container.encodeIfPresent(created_at, forKey: .created_at)
        
        // Ensure shelves is encoded as a proper JSON object
        if let shelves = shelves {
            try container.encode(shelves, forKey: .shelves)
            print("📝 Encoded shelves as: \(shelves)")
        }
    }
}

struct AnyDecodable: Decodable {
    var value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyDecodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyDecodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyDecodable cannot decode value")
        }
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
            .from("Member")
            .select()
            .eq("email", value: email.lowercased())
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
            favourites: [],
            mybag: [],
            shelves: ["Favorites": []]  // Initialize with default Favorites shelf
        )
        
        do {
            print("📝 Saving member data to database: \(member)")
            _ = try await SupabaseManager.shared.client
                .from("Member")
                .insert(member)
                .execute()
            
            print("✅ Member data saved successfully with ID: \(userId)")
        } catch {
            print("❌ Error saving member data: \(error)")
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
    
    
    func updateMyBag(userId: UUID, bookId: UUID, addToBag: Bool) async throws {
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
                    favourites: [],
                    mybag: addToBag ? [bookId.uuidString] : []
                )
                
                try await client
                    .from("Member")
                    .insert(newMember)
                    .execute()
            } else {
                // Member exists, update their bag
                var member = response[0]
                let bookIdString = bookId.uuidString
                
                if addToBag {
                    if !member.myBag.contains(bookIdString) {
                        member.myBag.append(bookIdString)
                    }
                } else {
                    member.myBag.removeAll { $0 == bookIdString }
                }
                
                try await client
                    .from("Member")
                    .update(["myBag": member.myBag])
                    .eq("id", value: userId)
                    .execute()
            }
            
            print("MyBag updated successfully for user: \(userId)")
        } catch {
            print("Error updating myBag: \(error)")
            throw error
        }
    }
    
    func updateFavourites(userId: UUID, bookId: UUID, isFavourite: Bool) async throws {
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
   
   // Shelf Management Functions
   func fetchUserShelves(userId: UUID) async throws -> [String: [String]] {
       print("🔍 Fetching shelves for user: \(userId)")
       let query = client
           .from("Member")
           .select()
           .eq("id", value: userId)
       
       do {
           let response: [Member] = try await query.execute().value
           
           if response.isEmpty {
               print("⚠️ No member record found for user: \(userId)")
               return ["Favorites": []]
           } else {
               print("✅ Found member record for user: \(userId)")
               if let shelves = response[0].shelves {
                   print("📚 Retrieved shelves: \(shelves)")
                   return shelves
               } else {
                   print("⚠️ No shelves found for user: \(userId), returning default")
                   return ["Favorites": []]
               }
           }
       } catch {
           print("❌ Error fetching user shelves: \(error)")
           throw error
       }
   }
   
   func createShelf(userId: UUID, shelfName: String) async throws {
       print("🆕 Creating shelf: \(shelfName) for user: \(userId)")
       let query = client
           .from("Member")
           .select()
           .eq("id", value: userId)
       
       do {
           let response: [Member] = try await query.execute().value
           
           if response.isEmpty {
               print("⚠️ No member found, creating a new member with shelf: \(shelfName)")
               // Create new member with the shelf
               var initialShelves: [String: [String]] = ["Favorites": []]
               initialShelves[shelfName] = []
               
               let newMember = Member(
                   id: userId,
                   email: currentUser?.email ?? "",
                   firstName: "",
                   lastName: "",
                   favourites: [],
                   mybag: [],
                   shelves: initialShelves
               )
               
               let insertResult = try await client
                   .from("Member")
                   .insert(newMember)
                   .execute()
               
               print("✅ Created new member with shelf: \(insertResult)")
           } else {
               // Update existing member with new shelf
               var member = response[0]
               print("📊 Current member data: \(member)")
               
               var shelves = member.shelves ?? ["Favorites": []]
               print("📚 Current shelves: \(shelves)")
               
               // Only add if the shelf doesn't already exist
               if shelves[shelfName] == nil {
                   shelves[shelfName] = []
                   print("📝 Adding new shelf: \(shelfName)")
                   
                   // Make a proper Encodable update
                   member.shelves = shelves
                   
                   let updateResult = try await client
                       .from("Member")
                       .update(["shelves": shelves])
                       .eq("id", value: userId)
                       .execute()
                   
                   print("✅ Updated member with new shelf: \(updateResult)")
               } else {
                   print("⚠️ Shelf already exists: \(shelfName)")
               }
           }
           
           print("✅ Shelf created successfully for user: \(userId)")
       } catch {
           print("❌ Error creating shelf: \(error)")
           throw error
       }
   }
   
   func deleteShelf(userId: UUID, shelfName: String) async throws {
       // Don't allow deletion of Favorites shelf
       if shelfName == "Favorites" {
           throw NSError(domain: "ShelfManagement", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot delete Favorites shelf"])
       }
       
       let query = client
           .from("Member")
           .select()
           .eq("id", value: userId)
       
       do {
           let response: [Member] = try await query.execute().value
           
           if !response.isEmpty {
               var member = response[0]
               var shelves = member.shelves ?? ["Favorites": []]
               
               // Remove the shelf
               shelves.removeValue(forKey: shelfName)
               
               // Update member with modified shelves
               member.shelves = shelves
               
               let updateResult = try await client
                   .from("Member")
                   .update(["shelves": shelves])
                   .eq("id", value: userId)
                   .execute()
               
               print("✅ Shelf deleted successfully for user: \(userId)")
           }
       } catch {
           print("❌ Error deleting shelf: \(error)")
           throw error
       }
   }
   
   func addBookToShelf(userId: UUID, shelfName: String, bookId: UUID) async throws {
       print("📚 Adding book: \(bookId) to shelf: \(shelfName) for user: \(userId)")
       let query = client
           .from("Member")
           .select()
           .eq("id", value: userId)
       
       do {
           let response: [Member] = try await query.execute().value
           print("🔍 Found \(response.count) member records")
           
           if response.isEmpty {
               print("⚠️ No member found, creating a new member with book in shelf")
               // Create new member with the shelf and book
               var initialShelves: [String: [String]] = ["Favorites": []]
               initialShelves[shelfName] = [bookId.uuidString]
               
               let newMember = Member(
                   id: userId,
                   email: currentUser?.email ?? "",
                   firstName: "",
                   lastName: "",
                   favourites: [],
                   mybag: [],
                   shelves: initialShelves
               )
               
               let insertResult = try await client
                   .from("Member")
                   .insert(newMember)
                   .execute()
               
               print("✅ Created new member with book in shelf: \(insertResult)")
           } else {
               // Update existing member
               var member = response[0]
               print("📊 Current member data: \(String(describing: member.id))")
               
               var shelves = member.shelves ?? ["Favorites": []]
               print("📚 Current shelves: \(shelves)")
               
               // Create shelf if it doesn't exist
               if shelves[shelfName] == nil {
                   print("🆕 Creating new shelf: \(shelfName)")
                   shelves[shelfName] = []
               }
               
               // Add book if not already in shelf
               let bookIdString = bookId.uuidString
               if !shelves[shelfName]!.contains(bookIdString) {
                   print("📝 Adding book ID: \(bookIdString) to shelf: \(shelfName)")
                   shelves[shelfName]!.append(bookIdString)
                   
                   // Make a proper Encodable update
                   member.shelves = shelves
                   
                   let updateResult = try await client
                       .from("Member")
                       .update(["shelves": shelves])
                       .eq("id", value: userId)
                       .execute()
                   
                   print("✅ Updated member with book in shelf: \(updateResult)")
               } else {
                   print("⚠️ Book already exists in shelf: \(shelfName)")
               }
           }
           
           print("✅ Book added to shelf successfully for user: \(userId)")
       } catch {
           print("❌ Error adding book to shelf: \(error)")
           throw error
       }
   }
   
   func removeBookFromShelf(userId: UUID, shelfName: String, bookId: UUID) async throws {
       let query = client
           .from("Member")
           .select()
           .eq("id", value: userId)
       
       do {
           let response: [Member] = try await query.execute().value
           
           if !response.isEmpty {
               var member = response[0]
               var shelves = member.shelves ?? ["Favorites": []]
               
               // Remove book from shelf if it exists
               if var shelfBooks = shelves[shelfName] {
                   let bookIdString = bookId.uuidString
                   shelfBooks.removeAll { $0 == bookIdString }
                   shelves[shelfName] = shelfBooks
                   
                   // Update member with modified shelves
                   member.shelves = shelves
                   
                   let updateResult = try await client
                       .from("Member")
                       .update(["shelves": shelves])
                       .eq("id", value: userId)
                       .execute()
                   
                   print("Book removed from shelf successfully for user: \(userId)")
               }
           }
       } catch {
           print("Error removing book from shelf: \(error)")
           throw error
       }
   }
}

