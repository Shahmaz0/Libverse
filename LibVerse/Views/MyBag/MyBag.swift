//
//  MyBag.swift
//  LibVerse
//
//  Created by Shahma Ansari on 26/03/25.
//

import SwiftUI

struct MyBag: View {
    @StateObject var viewModel = MyBagViewModel()
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var isEditing = false
    @State private var selectedBooks: Set<UUID> = []
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 239/255, blue: 210/255)
                .ignoresSafeArea()
            
            VStack {

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.top, -1),
                            alignment: .top
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.bottom, -1),
                            alignment: .bottom
                        )
                    
                    Rectangle()
                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                        .frame(maxWidth: 90, maxHeight: 60)
                        .overlay(
                            Rectangle()
                                .frame(width: 1.25)
                                .foregroundColor(.black)
                                .padding(.leading, -1),
                            alignment: .leading
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.top, -1),
                            alignment: .top
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.bottom, -1),
                            alignment: .bottom
                        )
                        .overlay(
                            Group {
                                if isEditing {
                                    Button(action: {
                                        withAnimation {
                                            isEditing = false
                                            selectedBooks.removeAll()
                                        }
                                    }) {
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                    }
                                } else {
                                    Button(action: {
                                        withAnimation {
                                            isEditing = true
                                        }
                                    }) {
                                        Image(systemName: "square.and.pencil")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                    }
                                }
                            },
                            alignment: .center
                        )
                }
                .overlay(
                    Text("My Bag")
                        .font(.custom("Charter", size: 20))
                        .bold()
                        .foregroundColor(.black),
                    alignment: .center
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -20)
                
                // Content section of the MyBag view (only showing the modified part)
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if viewModel.bagBooks.isEmpty {
                    Text("Your bag is empty")
                        .font(.custom("Charter", size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 300)
                } else {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(viewModel.bagBooks, id: \.id) { book in
                                HStack(alignment: .center, spacing: 0) {
                                    if isEditing {
                                        Button(action: {
                                            withAnimation {
                                                if selectedBooks.contains(book.id) {
                                                    selectedBooks.remove(book.id)
                                                } else {
                                                    selectedBooks.insert(book.id)
                                                }
                                            }
                                        }) {
                                            Image(systemName: selectedBooks.contains(book.id) ? "checkmark.circle.fill" : "circle")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(selectedBooks.contains(book.id) ?
                                                    Color(red: 255/255, green: 111/255, blue: 45/255) : .gray)
                                        }
                                        .padding(.trailing, 12)
                                        .padding(.leading, 30)
                                    }
                                    
                                    BookCard(
                                        BookImage: book.imageLink ?? "",
                                        title: book.title,
                                        author: book.author.joined(separator: ", "),
                                        description: book.Description ?? "No description available"
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.trailing, 20)
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                }
                Spacer()
                
                if isEditing {
                    HStack {
                        Button(action: {
                            // Delete selected books action
                            print("Delete selected books: \(selectedBooks)")
                        }) {
                            Text("Delete")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        }
                        .frame(width: 160, height: 30, alignment: .center)
                        
                        Button(action: {
                            // Issue selected books action
                            print("Issue selected books: \(selectedBooks)")
                        }) {
                            Text("Issue Selected")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                .foregroundColor(.white)
                                .cornerRadius(0)
                        }
                        .frame(width: 160, height: 30, alignment: .center)
                    }
                    .padding(.bottom, 20)
                } else {
                    Button(action: {
                        print("Issue All clicked.")
                    }) {
                        Text("Issue all")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .foregroundColor(.white)
                            .cornerRadius(0)
                    }
                    .frame(width: 345, height: 30, alignment: .center)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            viewModel.fetchBagBooks()
        }
    }
}

class MyBagViewModel: ObservableObject {
    @Published var bagBooks: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let supabaseManager = SupabaseManager.shared
    
    func fetchBagBooks() {
        guard let currentUser = supabaseManager.currentUser else {
            self.bagBooks = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let query = supabaseManager.client
                    .from("Member")
                    .select()
                    .eq("id", value: currentUser.id)
                
                let members: [Member] = try await query.execute().value
                
                guard let member = members.first else {
                    await MainActor.run {
                        self.isLoading = false
                        self.bagBooks = []
                    }
                    return
                }
                
                let bagIds = member.myBag
                
                if bagIds.isEmpty {
                    await MainActor.run {
                        self.isLoading = false
                        self.bagBooks = []
                    }
                    return
                }
                
                let bookIds = bagIds.compactMap { UUID(uuidString: $0) }
                
                let bookQuery = supabaseManager.client
                    .from("Books")
                    .select()
                    .in("id", values: bookIds)
                
                let books: [Book] = try await bookQuery.execute().value
                
                await MainActor.run {
                    self.bagBooks = books
                    self.isLoading = false
                }
            } catch {
                print("Error fetching bag books: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load bag books. Please try again."
                    self.bagBooks = []
                }
            }
        }
    }
}

#Preview {
    let mockViewModel = MyBagViewModel()
    mockViewModel.bagBooks = [
        Book(
            id: UUID(),
            title: "The Great Gatsby",
            author: ["F. Scott Fitzgerald"],
            genre: "Classic",
            publicationDate: "1925",
            totalCopies: 10,
            availableCopies: 5,
            ISBN: "9780743273565",
            Description: "A story of wealth, love, and the American Dream in the 1920s.",
            shelfLocation: "Fiction A1",
            dateAdded: "2023-01-15",
            publisher: "Scribner",
            imageLink: "https://example.com/gatsby.jpg"
        ),
        Book(
            id: UUID(),
            title: "To Kill a Mockingbird",
            author: ["Harper Lee"],
            genre: "Fiction",
            publicationDate: "1960",
            totalCopies: 8,
            availableCopies: 3,
            ISBN: "9780061120084",
            Description: "A powerful story of racial injustice and moral growth in the American South.",
            shelfLocation: "Fiction B2",
            dateAdded: "2023-02-20",
            publisher: "J. B. Lippincott & Co.",
            imageLink: "https://example.com/mockingbird.jpg"
        )
    ]
    mockViewModel.isLoading = false
    
    return MyBag(viewModel: mockViewModel)
        .environmentObject(SupabaseManager.shared)
}
