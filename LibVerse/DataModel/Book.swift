//
//  Book.swift
//  LibVerse
//
//  Created by Shahma Ansari on 21/03/25.
//

import Foundation

struct Book: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let author: [String]
    let genre: String
    let publicationDate: String
    let totalCopies: Int
    let availableCopies: Int
    let ISBN: String
    let Description: String?
    let shelfLocation: String?
    let dateAdded: String?
    let publisher: String?
    let imageLink: String?
}


struct LibraryBook: Identifiable, Codable {
    let id: UUID
    let title: String
    private let authorArray: [String]?  // To handle author coming as array
    let genre: String?
    let publicationDate: String?
    let totalCopies: Int?
    let availableCopies: Int?
    let ISBN: String?
    let Description: String?
    let shelfLocation: String?
    let dateAdded: String?
    let publisher: String?
    let imageLink: String?
    
    // Computed property to get author string
    var author: String {
        return authorArray?.first ?? "Unknown Author"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, genre
        case authorArray = "author"  // Map the author array from JSON to authorArray
        case publicationDate = "publicationDate"
        case totalCopies = "totalCopies"
        case availableCopies = "availableCopies"
        case ISBN = "ISBN"
        case Description = "Description"
        case shelfLocation = "shelfLocation"
        case dateAdded = "dateAdded"
        case publisher, imageLink
    }
    
    // Custom initializer to handle potential type mismatches
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        // Handle author which could be array or string
        if let authorArr = try? container.decode([String].self, forKey: .authorArray) {
            authorArray = authorArr
        } else if let authorStr = try? container.decode(String.self, forKey: .authorArray) {
            authorArray = [authorStr]
        } else {
            authorArray = nil
        }
        
        // Decode optional fields
        genre = try? container.decode(String.self, forKey: .genre)
        publicationDate = try? container.decode(String.self, forKey: .publicationDate)
        totalCopies = try? container.decode(Int.self, forKey: .totalCopies)
        availableCopies = try? container.decode(Int.self, forKey: .availableCopies)
        ISBN = try? container.decode(String.self, forKey: .ISBN)
        Description = try? container.decode(String.self, forKey: .Description)
        shelfLocation = try? container.decode(String.self, forKey: .shelfLocation)
        dateAdded = try? container.decode(String.self, forKey: .dateAdded)
        publisher = try? container.decode(String.self, forKey: .publisher)
        imageLink = try? container.decode(String.self, forKey: .imageLink)
    }
}

struct PopularBook: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let author: String
    let rating: Int
    let isBookmarked: Bool
}

struct Announcement: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let type: String
    let expiry_date: Date?
    let created_at: Date
    let is_active: Bool
    let is_archived: Bool
    let last_modified: Date?
    let start_date: Date?
    
    // Computed properties to maintain compatibility with existing UI
    var description: String {
        return content
    }
    
    var date: Date {
        return created_at
    }
    
    var isNew: Bool {
        // Consider an announcement new if it was created in the last 3 days AND hasn't been viewed
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        let hasBeenViewed = UserDefaults.standard.bool(forKey: "announcement_viewed_\(id.uuidString)")
        return created_at > threeDaysAgo && !hasBeenViewed
    }
    
    var fullContent: String {
        return content
    }
    
    // Mark announcement as viewed
    func markAsViewed() {
        UserDefaults.standard.set(true, forKey: "announcement_viewed_\(id.uuidString)")
    }
}
