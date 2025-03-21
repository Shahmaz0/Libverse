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
//
//let sampleBooks: [Book] = [
//    Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald", description: "Nick Carraway, a young man from Minnesota, moves to New York in the summer of the 1922 to learn about the bond business.", category: "Contemporary Fiction", image: "book1"),
//    Book(title: "To Kill a Mockingbird", author: "Harper Lee", description: "The story of a young girl and her family in the American South during the 1930s.", category: "Contemporary Fiction", image: "book2"),
//    Book(title: "1984", author: "George Orwell", description: "A dystopian novel set in a totalitarian society ruled by the Party.", category: "Politics", image: "book3"),
//    
//    Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald", description: "Nick Carraway, a young man from Minnesota, moves to New York in the summer of the 1922 to learn about the bond business.", category: "Contemporary Fiction", image: "book1"),
//    Book(title: "To Kill a Mockingbird", author: "Harper Lee", description: "The story of a young girl and her family in the American South during the 1930s.", category: "Contemporary Fiction", image: "book2"),
//    Book(title: "1984", author: "George Orwell", description: "A dystopian novel set in a totalitarian society ruled by the Party.", category: "Politics", image: "book3"),
//]
//
//
//
//
