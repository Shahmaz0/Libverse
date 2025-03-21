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
    let Description: String
    let shelfLocation: String
    let dateAdded: String
    let publisher: String
    let imageLink: String
}
