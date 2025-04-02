//
//  SupabaseManager.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 20/03/25.
//

import Foundation
import SwiftUI
import Supabase

struct BorrowedBook: Identifiable, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, email, password, firstName, lastName, favourites,
             myBag, shelves, created_at, enrollmentNumber, fines,
             borrowedBooks, borrowingHistory
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
        fines = try container.decodeIfPresent(Double.self, forKey: .fines) ?? 0.0
        borrowedBooks = try container.decodeIfPresent([BorrowedBook].self, forKey: .borrowedBooks) ?? []
        borrowingHistory = try container.decodeIfPresent([BookIssue].self, forKey: .borrowingHistory)
        
        // Handle shelves decoding
        if let shelvesObj = try? container.decodeIfPresent([String: [String]].self, forKey: .shelves) {
            shelves = shelvesObj
        } else if let shelvesData = try? container.decodeIfPresent(Data.self, forKey: .shelves) {
            shelves = try? JSONDecoder().decode([String: [String]].self, from: shelvesData)
        } else if let anyValue = try? container.decodeIfPresent(AnyDecodable.self, forKey: .shelves) {
            if let dict = anyValue.value as? [String: [String]] {
                shelves = dict
            } else if let dict = anyValue.value as? [String: [Any]] {
                shelves = dict.mapValues { $0.compactMap { $0 as? String } }
            } else {
                shelves = ["Favorites": []]
            }
        } else {
            shelves = ["Favorites": []]
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
        case let value as Bool: try container.encode(value)
        case let value as Int: try container.encode(value)
        case let value as Double: try container.encode(value)
        case let value as String: try container.encode(value)
        case let value as [Any?]: try container.encode(value.map { AnyCodable($0 ?? NSNull()) })
        case let value as [String: Any?]: try container.encode(value.mapValues { AnyCodable($0 ?? NSNull()) })
        case is NSNull: try container.encodeNil()
        default: throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable cannot encode value"))
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

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    @Published var client: SupabaseClient
    @Published var currentUser: User?
    @Published var currentSession: Session?
    @Published var currentMember: Member?
    
    private let supabaseURL = URL(string: "https://iswzgemgctojcdnbxvjv.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlzd3pnZW1nY3RvamNkbmJ4dmp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyMzAwODgsImV4cCI6MjA1NzgwNjA4OH0.zmATRCYC3V8_BtROa_PzmFxabWQf0NjyNSQaMrwPL7E"
    
    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, firstName: String, lastName: String, enrollmentNumber: String?) async throws -> AuthResponse {
        print("🔄 Starting sign up process for: \(email)")
        let authResponse = try await client.auth.signUp(email: email, password: password)
        currentUser = authResponse.user
        
        UserDefaults.standard.set(email, forKey: "pendingSignupEmail")
        UserDefaults.standard.set(password, forKey: "pendingSignupPassword")
        UserDefaults.standard.set(firstName, forKey: "pendingSignupFirstName")
        UserDefaults.standard.set(lastName, forKey: "pendingSignupLastName")
        UserDefaults.standard.set(enrollmentNumber, forKey: "pendingSignupEnrollmentNumber")
        
        print("✅ Sign up successful, waiting for OTP verification")
        return authResponse
    }
    
    func signIn(email: String, password: String) async throws -> Session {
        print("🔄 Starting sign in process for: \(email)")
        let session = try await client.auth.signIn(email: email, password: password)
        
        UserDefaults.standard.set(email, forKey: "pendingLoginEmail")
        UserDefaults.standard.set(password, forKey: "pendingLoginPassword")
        
        DispatchQueue.main.async {
            self.currentUser = session.user
            self.currentSession = session
        }
        
        await fetchCurrentMember()
        print("✅ Sign in successful for user: \(session.user.id)")
        return session
    }
    
    func signOut() async throws {
        print("🔄 Starting sign out process")
        try await client.auth.signOut()
        
        DispatchQueue.main.async {
            self.currentUser = nil
            self.currentSession = nil
            self.currentMember = nil
        }
        
        UserDefaults.standard.removeObject(forKey: "pendingLoginEmail")
        UserDefaults.standard.removeObject(forKey: "pendingLoginPassword")
        UserDefaults.standard.removeObject(forKey: "pendingSignupEmail")
        UserDefaults.standard.removeObject(forKey: "pendingSignupPassword")
        UserDefaults.standard.removeObject(forKey: "pendingSignupFirstName")
        UserDefaults.standard.removeObject(forKey: "pendingSignupLastName")
        UserDefaults.standard.removeObject(forKey: "resetEmail")
        UserDefaults.standard.removeObject(forKey: "resetOTP")
        
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
        print("✅ Sign out successful")
    }
    
    func verifyOTP(email: String, otp: String, completion: @escaping (Result<Session, Error>) -> Void) {
        print("🔄 Verifying OTP for: \(email)")
        Task {
            do {
                let response = try await client.auth.verifyOTP(email: email, token: otp, type: .email)
                
                // Handle signup flow
                if UserDefaults.standard.string(forKey: "pendingSignupEmail") != nil {
                    guard let session = response.session else {
                        throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No session returned"])
                    }
                    
                    let pendingEmail = UserDefaults.standard.string(forKey: "pendingSignupEmail") ?? email
                    let firstName = UserDefaults.standard.string(forKey: "pendingSignupFirstName") ?? ""
                    let lastName = UserDefaults.standard.string(forKey: "pendingSignupLastName") ?? ""
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
                    
                    DispatchQueue.main.async {
                        self.currentUser = session.user
                        self.currentSession = session
                        completion(.success(session))
                    }
                    
                    await fetchCurrentMember()
                }
                // Handle login flow
                else if let session = response.session {
                    DispatchQueue.main.async {
                        self.currentUser = session.user
                        self.currentSession = session
                        completion(.success(session))
                    }
                    await fetchCurrentMember()
                } else {
                    throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No session returned"])
                }
            } catch {
                print("❌ OTP verification failed: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Member Data Management
    
    func saveMemberData(userId: UUID, email: String, firstName: String, lastName: String, enrollmentNumber: String?) async throws {
        print("🔄 Saving member data for: \(email)")
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
            let result = try await client
                .from("Member")
                .insert(member)
                .execute()
            
            print("✅ Member data saved successfully for user: \(userId)")
            print("Supabase response: \(result)")
        } catch {
            print("❌ Error saving member data: \(error)")
            throw error
        }
    }
    
    func fetchCurrentMember() async {
        guard let userId = currentUser?.id else {
            print("⚠️ Cannot fetch member: No current user")
            return
        }
        
        print("🔄 Fetching member data for: \(userId)")
        do {
            let response: [Member] = try await client
                .from("Member")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            let borrowingHistory = try await fetchBorrowingHistory(for: userId)
            
            if var member = response.first {
                member.borrowingHistory = borrowingHistory
                DispatchQueue.main.async {
                    self.currentMember = member
                    print("✅ Current member loaded: \(member.firstName) \(member.lastName)")
                }
            } else {
                print("⚠️ No member record found for user: \(userId)")
            }
        } catch {
            print("❌ Error fetching member data: \(error)")
        }
    }
    
    // MARK: - Password Management
    
    func resetPasswordForEmail(_ email: String) async throws {
        print("🔄 Starting password reset for: \(email)")
        try await client.auth.resetPasswordForEmail(email)
        print("✅ Password reset email sent to: \(email)")
    }
    
    func updatePassword(email: String, newPassword: String) async throws {
        print("🔄 Updating password for: \(email)")
        if let otp = UserDefaults.standard.string(forKey: "resetOTP") {
            let session = try await client.auth.verifyOTP(email: email, token: otp, type: .recovery)
            
            if session.user != nil {
                try await client.auth.update(user: UserAttributes(password: newPassword))
                UserDefaults.standard.removeObject(forKey: "resetOTP")
                print("✅ Password updated successfully")
            } else {
                throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid OTP"])
            }
        } else {
            throw NSError(domain: "PasswordReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "OTP not found"])
        }
    }
    
    // MARK: - Book Management
    
    func updateMyBag(userId: UUID, bookId: UUID, addToBag: Bool) async throws {
        print("🔄 Updating myBag for user: \(userId)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
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
        print("✅ MyBag updated successfully")
    }
    
    func updateFavourites(userId: UUID, bookId: UUID, isFavourite: Bool) async throws {
        print("🔄 Updating favourites for user: \(userId)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
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
        print("✅ Favourites updated successfully")
    }
    
    // MARK: - Shelf Management
    
    func fetchUserShelves(userId: UUID) async throws -> [String: [String]] {
        print("🔄 Fetching shelves for user: \(userId)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        return response.first?.shelves ?? ["Favorites": []]
    }
    
    func createShelf(userId: UUID, shelfName: String) async throws {
        print("🔄 Creating shelf '\(shelfName)' for user: \(userId)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
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
        print("✅ Shelf created successfully")
    }
    
    func deleteShelf(userId: UUID, shelfName: String) async throws {
        print("🔄 Deleting shelf '\(shelfName)' for user: \(userId)")
        guard shelfName != "Favorites" else {
            throw NSError(domain: "ShelfManagement", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot delete Favorites shelf"])
        }
        
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
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
        print("✅ Shelf deleted successfully")
    }
    
    func addBookToShelf(userId: UUID, shelfName: String, bookId: UUID) async throws {
        print("🔄 Adding book to shelf '\(shelfName)' for user: \(userId)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
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
        print("✅ Book added to shelf successfully")
    }
    
    func removeBookFromShelf(userId: UUID, shelfName: String, bookId: UUID) async throws {
        print("🔄 Removing book from shelf '\(shelfName)' for user: \(userId)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
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
        print("✅ Book removed from shelf successfully")
    }
    
    // MARK: - Profile Management
    
    func updateProfile(userId: UUID, firstName: String, lastName: String, enrollmentNumber: String?) async throws {
        print("🔄 Updating profile for user: \(userId)")
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
        
        if var updatedMember = currentMember {
            updatedMember.firstName = firstName
            updatedMember.lastName = lastName
            updatedMember.enrollmentNumber = enrollmentNumber
            
            DispatchQueue.main.async {
                self.currentMember = updatedMember
            }
        }
        print("✅ Profile updated successfully")
    }
    
    // MARK: - Borrowing History
    
    func fetchBorrowingHistory(for memberId: UUID) async throws -> [BookIssue] {
        print("🔄 Fetching borrowing history for: \(memberId)")
        let response: [BookIssue] = try await client
            .from("BookIssue")
            .select()
            .eq("memberId", value: memberId)
            .order("issueDate", ascending: false)
            .execute()
            .value
        
        return response.map { $0.updateStatus() }
    }
    
    func checkEmailExists(_ email: String) async throws -> Bool {
        print("🔄 Checking if email exists: \(email)")
        let response: [Member] = try await client
            .from("Member")
            .select()
            .eq("email", value: email.lowercased())
            .execute()
            .value
        
        return !response.isEmpty
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
}
