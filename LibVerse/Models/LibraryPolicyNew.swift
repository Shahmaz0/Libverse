import Foundation

struct LibraryPolicyNew: Codable, Identifiable {
    let id: UUID
    let borrowingLimit: Int
    let returnPeriod: Int
    let fineAmount: Int
    let lostBookFine: Int
    let lastUpdated: Date?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case borrowingLimit = "borrowing_limit"
        case returnPeriod = "return_period"
        case fineAmount = "fine_amount"
        case lostBookFine = "lost_book_fine"
        case lastUpdated = "last_updated"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        borrowingLimit = try container.decode(Int.self, forKey: .borrowingLimit)
        returnPeriod = try container.decode(Int.self, forKey: .returnPeriod)
        fineAmount = try container.decode(Int.self, forKey: .fineAmount)
        lostBookFine = try container.decode(Int.self, forKey: .lostBookFine)
        
        let dateFormatter = ISO8601DateFormatter()
        
        if let lastUpdatedString = try container.decodeIfPresent(String.self, forKey: .lastUpdated) {
            lastUpdated = dateFormatter.date(from: lastUpdatedString)
        } else {
            lastUpdated = nil
        }
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString)
        } else {
            createdAt = nil
        }
    }
} 
