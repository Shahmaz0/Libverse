//
//  SearchDataController.swift
//  LibVerse
//
//  Created by Shahma Ansari on 21/03/25.
//
import Supabase
import Foundation


class DataController: ObservableObject, @unchecked Sendable {
    @Published var books: [Book] = []
    @Published var suggestions: [Book] = []
    
    private var supabase: SupabaseClient
    
    init() {
        // Initialize Supabase client
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://iswzgemgctojcdnbxvjv.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlzd3pnZW1nY3RvamNkbmJ4dmp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyMzAwODgsImV4cCI6MjA1NzgwNjA4OH0.zmATRCYC3V8_BtROa_PzmFxabWQf0NjyNSQaMrwPL7E"
        )
        
        // Fetch books from Supabase
        fetchBooks()
    }
    
    // Fetch books from Supabase
    func fetchBooks() {
        Task { [weak self] in // Capture `self` weakly to avoid retain cycles
            guard let self = self else { return }
            
            do {
                let response: [Book] = try await self.supabase
                    .from("Books") // Use the recommended method
                    .select()
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.books = response
                }
            } catch {
                print("Error fetching books: \(error)")
            }
        }
    }
    
    // Filter books based on search text
    func updateSuggestions(for searchText: String) {
        if searchText.isEmpty {
            suggestions = []
        } else {
            // Filter books where the title or any author matches the search text
            let filteredBooks = books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            
            // If the search text matches any author's name, show all books by that author
            let authorBooks = books.filter { book in
                book.author.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            
            // Combine and remove duplicates
            suggestions = Array(Set(filteredBooks + authorBooks))
        }
    }
}
