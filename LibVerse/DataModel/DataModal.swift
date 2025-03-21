//
//  DataModal.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 21/03/25.
//

import Foundation
struct Member: Codable, Identifiable {
    var id: UUID
    var firstName: String
    var lastName: String
    var enrollmentNumber: String
    var collegeName: String
    var collegeEmail: String
    var password: String
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case enrollmentNumber = "enrollment_number"
        case collegeName = "college_name"
        case collegeEmail = "college_email"
        case password
        case createdAt = "created_at"
    }
}
