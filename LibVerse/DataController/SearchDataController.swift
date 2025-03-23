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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var supabase: SupabaseClient
    
    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://iswzgemgctojcdnbxvjv.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlzd3pnZW1nY3RvamNkbmJ4dmp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyMzAwODgsImV4cCI6MjA1NzgwNjA4OH0.zmATRCYC3V8_BtROa_PzmFxabWQf0NjyNSQaMrwPL7E"
        )
        
        fetchBooks()
    }
    
    func fetchBooks() {
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let response: [Book] = try await self.supabase
                    .from("Books")
                    .select()
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.books = response
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch books. Please check your internet connection."
                    self.isLoading = false
                }
                print("Error fetching books: \(error)")
            }
        }
    }
    
    func updateSuggestions(for searchText: String) {
        if searchText.isEmpty {
            suggestions = []
        } else {
            let filteredBooks = books.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            
            let authorBooks = books.filter { book in
                book.author.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            
            suggestions = Array(Set(filteredBooks + authorBooks))
        }
    }
}


//Shahma
