//
//  SupabaseManager.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 20/03/25.
//

import Foundation
import SwiftUI
import Supabase

struct BorrowedBook: Identifiable, Codable{
    let id: UUID
    let title: String
    let author: String
    let daysRemaining: Int
    let isOverdue: Bool
}

struct Member: Codable {
    let id: UUID?
    let email: String
    let password: String?
    var firstName: String
    var lastName: String
    var favourites: [String]
    var enrollmentNumber: String?
    var myBag: [String]
    var shelves: [String: [String]]?
    let created_at: Date?
    var fines: Double
    var borrowedBooks: [BorrowedBook]
    var borrowingHistory: [BookIssue]?
    
    // Update the initializer to include borrowingHistory
    init(
        id: UUID? = nil,
        email: String,
        password: String? = nil,
        firstName: String,
        lastName: String,
        favourites: [String] = [],
        myBag: [String] = [],
        shelves: [String: [String]]? = ["Favorites": []],
        created_at: Date? = nil,
        enrollmentNumber: String? = nil,
        fines: Double = 0.0,
        borrowedBooks: [BorrowedBook] = [],
        borrowingHistory: [BookIssue]? = nil
    ) {
        self.id = id
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.favourites = favourites
        self.myBag = myBag
        self.shelves = shelves
        self.created_at = created_at
        self.enrollmentNumber = enrollmentNumber
        self.fines = fines
        self.borrowedBooks = borrowedBooks
        self.borrowingHistory = borrowingHistory
    }
    
    // Update the CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, email, password, firstName, lastName, favourites, myBag, shelves, created_at, enrollmentNumber, fines, borrowedBooks, borrowingHistory
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
        enrollmentNumber = try container.decodeIfPresent(String.self, forKey: .enrollmentNumber)
        
        // Initialize the missing properties
        fines = try container.decodeIfPresent(Double.self, forKey: .fines) ?? 0.0
        borrowedBooks = try container.decodeIfPresent([BorrowedBook].self, forKey: .borrowedBooks) ?? []
        borrowingHistory = try container.decodeIfPresent([BookIssue].self, forKey: .borrowingHistory)
        
        
        
        // Special handling for shelves as JSONB
        if let shelvesObj = try? container.decodeIfPresent([String: [String]].self, forKey: .shelves) {
            shelves = shelvesObj
            print("📖 Decoded shelves directly: \(String(describing: shelves))")
        } else if let shelvesData = try? container.decodeIfPresent(Data.self, forKey: .shelves) {
            let decoder = JSONDecoder()
            shelves = try? decoder.decode([String: [String]].self, from: shelvesData)
            print("📖 Decoded shelves from Data: \(String(describing: shelves))")
        } else if let anyValue = try? container.decodeIfPresent(AnyDecodable.self, forKey: .shelves) {
            print("📖 Decoding shelves from AnyDecodable: \(anyValue.value)")
            if let dict = anyValue.value as? [String: [String]] {
                shelves = dict
                print("📖 Converted directly to [String: [String]]")
            } else if let dict = anyValue.value as? [String: [Any]] {
                var convertedDict: [String: [String]] = [:]
                for (key, values) in dict {
                    print("📖 Converting values for key: \(key)")
                    convertedDict[key] = values.compactMap { $0 as? String }
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
        try container.encodeIfPresent(enrollmentNumber, forKey: .enrollmentNumber)
        try container.encode(fines, forKey: .fines)
        try container.encode(borrowedBooks, forKey: .borrowedBooks)
        try container.encodeIfPresent(borrowingHistory, forKey: .borrowingHistory)
        
        if let shelves = shelves {
            try container.encode(shelves, forKey: .shelves)
            print("📝 Encoded shelves as: \(shelves)")
        }
    }
}

struct AnyCodable: Codable {
    var value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
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
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let value as Bool:
            try container.encode(value)
        case let value as Int:
            try container.encode(value)
        case let value as Double:
            try container.encode(value)
        case let value as String:
            try container.encode(value)
        case let value as [Any?]:
            try container.encode(value.map { AnyCodable($0 ?? NSNull()) })
        case let value as [String: Any?]:
            try container.encode(value.mapValues { AnyCodable($0 ?? NSNull()) })
        case is NSNull:
            try container.encodeNil()
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable cannot encode value"))
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

struct LoginCredentials {
    let email: String
    let password: String
}

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    @Published var client: SupabaseClient
    @Published var currentUser: User?
    @Published var currentSession: Session?
    @Published var currentMember: Member?
    
    private let supabaseURL = URL(string: "https://iswzgemgctojcdnbxvjv.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlzd3pnZW1nY3RvamNkbmJ4dmp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyMzAwODgsImV4cCI6MjA1NzgwNjA4OH0.zmATRCYC3V8_BtROa_PzmFxabWQf0NjyNSQaMrwPL7E"
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, firstName: String, lastName: String, enrollmentNumber: String?) async throws -> AuthResponse {
        let authResponse = try await client.auth.signUp(email: email, password: password)
        currentUser = authResponse.user
        
        UserDefaults.standard.set(email, forKey: "pendingSignupEmail")
        UserDefaults.standard.set(password, forKey: "pendingSignupPassword")
        UserDefaults.standard.set(firstName, forKey: "pendingSignupFirstName")
        UserDefaults.standard.set(lastName, forKey: "pendingSignupLastName")
        UserDefaults.standard.set(enrollmentNumber, forKey: "pendingSignupEnrollmentNumber")
        
        return authResponse
    }
    
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(email: email, password: password)
        try await client.auth.signOut() // Sign out temporarily to force OTP
        try await client.auth.signInWithOTP(email: email)
        
        UserDefaults.standard.set(email, forKey: "pendingLoginEmail")
        UserDefaults.standard.set(password, forKey: "pendingLoginPassword")
        
        DispatchQueue.main.async {
            self.currentUser = session.user
            self.currentSession = session
        }
        
        await fetchCurrentMember()
        print("User ID: \(session.user.id)")
        return session
    }
    
    func signOut() async throws {
        do {
            // Sign out from Supabase authentication
            try await client.auth.signOut()
            
            // Clear user data
            DispatchQueue.main.async {
                self.currentUser = nil
                self.currentSession = nil
                self.currentMember = nil
            }
            
            // Clear any stored credentials
            UserDefaults.standard.removeObject(forKey: "pendingLoginEmail")
            UserDefaults.standard.removeObject(forKey: "pendingLoginPassword")
            UserDefaults.standard.removeObject(forKey: "pendingSignupEmail")
            UserDefaults.standard.removeObject(forKey: "pendingSignupPassword")
            UserDefaults.standard.removeObject(forKey: "pendingSignupFirstName")
            UserDefaults.standard.removeObject(forKey: "pendingSignupLastName")
            UserDefaults.standard.removeObject(forKey: "resetEmail")
            UserDefaults.standard.removeObject(forKey: "resetOTP")
            
            // Post notification for user logout
            NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
            
            print("User signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            throw error
        }
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
                
                if let session = response.session,
                   let pendingEmail = UserDefaults.standard.string(forKey: "pendingSignupEmail"),
                   let firstName = UserDefaults.standard.string(forKey: "pendingSignupFirstName"),
                   let lastName = UserDefaults.standard.string(forKey: "pendingSignupLastName") {
                    
                    let enrollmentNumber = UserDefaults.standard.string(forKey: "pendingSignupEnrollmentNumber")
                    
                    try await saveMemberData(
                        userId: session.user.id,
                        email: pendingEmail,
                        firstName: firstName,
                        lastName: lastName,
                        enrollmentNumber: enrollmentNumber
                    )
                    
                    UserDefaults.standard.removeObject(forKey: "pendingSignupEmail")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupPassword")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupFirstName")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupLastName")
                    UserDefaults.standard.removeObject(forKey: "pendingSignupEnrollmentNumber")
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
    
    func verifyLoginOTP(email: String, otp: String) async throws -> Session {
        let response = try await client.auth.verifyOTP(email: email, token: otp, type: .email)
        
        if let storedPassword = UserDefaults.standard.string(forKey: "pendingLoginPassword") {
            let session = try await client.auth.signIn(email: email, password: storedPassword)
            
            UserDefaults.standard.removeObject(forKey: "pendingLoginEmail")
            UserDefaults.standard.removeObject(forKey: "pendingLoginPassword")
            
            DispatchQueue.main.async {
                self.currentUser = session.user
                self.currentSession = session
            }
            
            await fetchCurrentMember()
            return session
        } else {
            throw NSError(domain: "Login", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login credentials not found"])
        }
    }
    
    // MARK: - Member Data Management
    
    func saveMemberData(userId: UUID, email: String, firstName: String, lastName: String, enrollmentNumber: String?) async throws {
        let member = Member(
            id: userId,
            email: email,
            firstName: firstName,
            lastName: lastName,
            favourites: [],
            myBag: [],
            shelves: ["Favorites": []],
            created_at: Date(),
            enrollmentNumber: enrollmentNumber
        )
        
        do {
            print("📝 Saving member data to database: \(member)")
            _ = try await client
                .from("Member")
                .insert(member)
                .execute()
            
            print("✅ Member data saved successfully with ID: \(userId)")
        } catch {
            print("❌ Error saving member data: \(error)")
            throw error
        }
    }
    
    func verifyLoginOTP(email: String, otp: String) async throws -> Session? {
        do {
            // First verify the OTP
            let otpResponse = try await client.auth.verifyOTP(
                email: email,
                token: otp,
                type: .email
            )
            
            // If OTP verification was successful and we have stored credentials
            if let storedPassword = UserDefaults.standard.string(forKey: "pendingLoginPassword") {
                // Sign in with email and password
                let authResponse = try await client.auth.signIn(
                    email: email,
                    password: storedPassword
                )
                
                // Get the session from the response
                let session = authResponse
                
                // Clear stored credentials
                UserDefaults.standard.removeObject(forKey: "pendingLoginEmail")
                UserDefaults.standard.removeObject(forKey: "pendingLoginPassword")
                
                // Update the current user and session
                DispatchQueue.main.async {
                    self.currentUser = session.user
                    self.currentSession = session
                }
                
                // Fetch member data after login
                await fetchCurrentMember()
                
                return session
            } else {
                // No stored credentials found
                throw NSError(domain: "Login", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login credentials not found"])
            }
        } catch {
            // Handle any errors that occurred
            print("Error during OTP verification or login: \(error.localizedDescription)")
            throw error
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
    
    func checkEmailExists(_ email: String) async throws -> Bool {
        let response: PostgrestResponse<[Member]> = try await client
            .from("Member")
            .select()
            .eq("email", value: email.lowercased())
            .execute()
        
        return !response.value.isEmpty
    }
    
    // MARK: - Password Management
    
    func resetPasswordForEmail(_ email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    func updatePassword(email: String, newPassword: String) async throws {
        if let otp = UserDefaults.standard.string(forKey: "resetOTP") {
            let session = try await client.auth.verifyOTP(email: email, token: otp, type: .recovery)
            
            if session.user != nil {
                try await client.auth.update(user: UserAttributes(password: newPassword))
                UserDefaults.standard.removeObject(forKey: "resetOTP")
            } else {
                throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid OTP"])
            }
        } else {
            throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "OTP not found"])
        }
    }
    
    // MARK: - Book Management
    
    func updateMyBag(userId: UUID, bookId: UUID, addToBag: Bool) async throws {
        let query = client
            .from("Member")
            .select()
            .eq("id", value: userId)
        
        do {
            let response: [Member] = try await query.execute().value
            
            if response.isEmpty {
                let newMember = Member(
                    id: userId,
                    email: currentUser?.email ?? "",
                    firstName: "",
                    lastName: "",
                    favourites: [],
                    myBag: addToBag ? [bookId.uuidString] : [],
                    shelves: ["Favorites": []]
                )
                
                try await client.from("Member").insert(newMember).execute()
            } else {
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
            
            if response.isEmpty {
                let newMember = Member(
                    id: userId,
                    email: currentUser?.email ?? "",
                    firstName: "",
                    lastName: "",
                    favourites: isFavourite ? [bookId.uuidString] : [],
                    myBag: [],
                    shelves: ["Favorites": []],
                    created_at: Date()
                )
                
                try await client.from("Member").insert(newMember).execute()
            } else {
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
    
    // MARK: - Shelf Management
    
    func fetchUserShelves(userId: UUID) async throws -> [String: [String]] {
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        if response.isEmpty {
            return ["Favorites": []]
        } else {
            return response[0].shelves ?? ["Favorites": []]
        }
    }
    
    func createShelf(userId: UUID, shelfName: String) async throws {
        let query = client
            .from("Member")
            .select()
            .eq("id", value: userId)
        
        do {
            let response: [Member] = try await query.execute().value
            
            if response.isEmpty {
                var initialShelves: [String: [String]] = ["Favorites": []]
                initialShelves[shelfName] = []
                
                let newMember = Member(
                    id: userId,
                    email: currentUser?.email ?? "",
                    firstName: "",
                    lastName: "",
                    favourites: [],
                    myBag: [],
                    shelves: initialShelves,
                    created_at: Date()
                )
                
                try await client.from("Member").insert(newMember).execute()
            } else {
                var member = response[0]
                var shelves = member.shelves ?? ["Favorites": []]
                
                if shelves[shelfName] == nil {
                    shelves[shelfName] = []
                    member.shelves = shelves
                    
                    try await client
                        .from("Member")
                        .update(["shelves": shelves])
                        .eq("id", value: userId)
                        .execute()
                }
            }
        } catch {
            throw error
        }
    }
    
    func deleteShelf(userId: UUID, shelfName: String) async throws {
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
                
                shelves.removeValue(forKey: shelfName)
                member.shelves = shelves
                
                try await client
                    .from("Member")
                    .update(["shelves": shelves])
                    .eq("id", value: userId)
                    .execute()
            }
        } catch {
            throw error
        }
    }
    
    func addBookToShelf(userId: UUID, shelfName: String, bookId: UUID) async throws {
        let query = client
            .from("Member")
            .select()
            .eq("id", value: userId)
        
        do {
            let response: [Member] = try await query.execute().value
            
            if response.isEmpty {
                var initialShelves: [String: [String]] = ["Favorites": []]
                initialShelves[shelfName] = [bookId.uuidString]
                
                let newMember = Member(
                    id: userId,
                    email: currentUser?.email ?? "",
                    firstName: "",
                    lastName: "",
                    favourites: [],
                    myBag: [],
                    shelves: initialShelves,
                    created_at: Date()
                )
                
                try await client.from("Member").insert(newMember).execute()
            } else {
                var member = response[0]
                var shelves = member.shelves ?? ["Favorites": []]
                
                if shelves[shelfName] == nil {
                    shelves[shelfName] = []
                }
                
                let bookIdString = bookId.uuidString
                if !shelves[shelfName]!.contains(bookIdString) {
                    shelves[shelfName]!.append(bookIdString)
                    member.shelves = shelves
                    
                    try await client
                        .from("Member")
                        .update(["shelves": shelves])
                        .eq("id", value: userId)
                        .execute()
                }
            }
        } catch {
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
                
                if var shelfBooks = shelves[shelfName] {
                    let bookIdString = bookId.uuidString
                    shelfBooks.removeAll { $0 == bookIdString }
                    shelves[shelfName] = shelfBooks
                    member.shelves = shelves
                    
                    try await client
                        .from("Member")
                        .update(["shelves": shelves])
                        .eq("id", value: userId)
                        .execute()
                }
            }
        } catch {
            throw error
        }
    }
    
    func updateProfile(userId: UUID, firstName: String, lastName: String, enrollmentNumber: String?) async throws {
        do {
            var updates: [String: AnyCodable] = [
                "firstName": AnyCodable(firstName),
                "lastName": AnyCodable(lastName)
            ]
            
            if let enrollmentNumber = enrollmentNumber {
                updates["enrollmentNumber"] = AnyCodable(enrollmentNumber)
            }
            
            try await client
                .from("Member")
                .update(updates)
                .eq("id", value: userId)
                .execute()
            
            // Update the current member in memory
            if var updatedMember = currentMember {
                updatedMember.firstName = firstName
                updatedMember.lastName = lastName
                updatedMember.enrollmentNumber = enrollmentNumber
                
                DispatchQueue.main.async {
                    self.currentMember = updatedMember
                }
            }
            
            print("✅ Profile updated successfully for user: \(userId)")
        } catch {
            print("❌ Error updating profile: \(error)")
            throw error
        }
    }
    
    func fetchBorrowingHistory(for memberId: UUID) async throws -> [BookIssue] {
        do {
            let response: [BookIssue] = try await client
                .from("BookIssue")
                .select()
                .eq("memberId", value: memberId)
                .order("issueDate", ascending: false)
                .execute()
                .value
            
            return response.map { $0.updateStatus() }
        } catch {
            print("Error fetching borrowing history: \(error)")
            throw error
        }
    }

    // Update the fetchCurrentMember method
    func fetchCurrentMember() async {
        guard let userId = currentUser?.id else {
            print("Cannot fetch member: User not logged in")
            return
        }
        
        do {
            // Fetch member data
            let response: [Member] = try await client
                .from("Member")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            // Fetch borrowing history
            let borrowingHistory = try await fetchBorrowingHistory(for: userId)
            
            if var member = response.first {
                member.borrowingHistory = borrowingHistory
                DispatchQueue.main.async {
                    self.currentMember = member
                    print("Current member data loaded: \(member.firstName) \(member.lastName)")
                }
            } else {
                print("No member record found for user ID: \(userId)")
            }
        } catch {
            print("Error fetching member data: \(error)")
        }
    }
}
