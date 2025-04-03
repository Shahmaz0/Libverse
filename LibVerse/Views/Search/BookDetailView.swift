//
//  BookDetailView.swift
//  LibVerse
//
//  Created by Shahma Ansari on 23/03/25.
//

import SwiftUI

// Add MemberShelves model
struct MemberShelves: Codable {
    let id: UUID
    let memberId: UUID
    let shelfName: String
    let bookId: UUID
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case memberId = "member_id"
        case shelfName = "shelf_name"
        case bookId = "book_id"
        case createdAt = "created_at"
    }
}

struct BookDetailView: View {
    let book: Book
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite: Bool = false
    @State private var showingQRCode = false
    @State private var isBookIssued: Bool = false
    @State private var currentIssueId: UUID?
    @State private var checkIssueTimer: Timer?
    @State private var refreshTrigger: Bool = false
    @State private var isInBag: Bool = false
    @State private var showingReturnQRCode = false
    @State private var showingAddToShelf = false
    @State private var isInAnyShelf: Bool = false
    @State private var isDisabled: Bool = false
    @EnvironmentObject var supabaseManager: SupabaseManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .frame(width: 65, height: 60)
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.top, -1),
                        alignment: .top
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: 1.25)
                            .foregroundColor(.black)
                            .padding(.trailing, -1),
                        alignment: .trailing
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.bottom, -1),
                        alignment: .bottom
                    )
                    .overlay(
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                        }
                            .padding(.leading, 20),
                        alignment: .leading
                    )
                
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
                            .frame(width: 1.25)
                            .foregroundColor(.black)
                            .padding(.leading, -1),
                        alignment: .leading
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.bottom, -1),
                        alignment: .bottom
                    )
                
            }
            .overlay(
                Text(LocalizationManager.shared.localizedString("book_details"))
                    .font(.custom("Charter", size: 20))
                    .bold()
                    .foregroundColor(.black),
                alignment: .center
            )
            .frame(width: 400)
            .padding(.horizontal, -20)
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            Rectangle()
                                .stroke(Color.black, lineWidth: 0.5)
                                .frame(width: 120, height: 120)
                            
                            if book.imageLink?.isEmpty ?? true {
                                Image("mvc")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .background(Color.white)
                                    .clipped()
                            } else {
                                AsyncImage(url: URL(string: book.imageLink!)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 112, height: 112)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 112, height: 112)
                                            .clipped()
                                    case .failure:
                                        Image("mvc")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 112, height: 112)
                                            .clipped()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        .frame(width: 120, height: 120)
                        .padding(.leading, 5)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            TranslatedBookTitle(book.title)
                                .font(.custom("Charter", size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(spacing: 0) {
                                Text(LocalizationManager.shared.localizedString("by") + ": ")
                                    .font(.custom("Charter", size: 13))
                                    .foregroundColor(.gray)
                                
                                Text(LocalizationManager.shared.translateAuthor(book.author.joined(separator: ", ")))
                                    .font(.custom("Charter", size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    
                    Button(action: {
                        if isBookIssued {
                            showingReturnQRCode = true
                        } else if let userId = supabaseManager.currentUser?.id {
                            showingQRCode = true
                        }
                    }) {
                        Text(isBookIssued ? LocalizationManager.shared.localizedString("return") : LocalizationManager.shared.localizedString("issue_now"))
                            .frame(width: 325, height: 20)
                            .padding()
                            .background(isBookIssued ? Color.green : Color(red: 255/255, green: 111/255, blue: 45/255))
                            .foregroundColor(.white)
                            .cornerRadius(0)
                            .border(.black)
                    }
                    .disabled(isDisabled && !isBookIssued)
                    .opacity(isDisabled && !isBookIssued ? 0.5 : 1)
                    .sheet(isPresented: $showingQRCode) {
                        if let userId = supabaseManager.currentUser?.id {
                            QRCodeGeneratorView(book: book, memberId: userId.uuidString)
                                .onAppear {
                                    startCheckingIssueStatus()
                                }
                                .onDisappear {
                                    stopCheckingIssueStatus()
                                }
                        }
                    }
                    .sheet(isPresented: $showingReturnQRCode) {
                        if let issueId = currentIssueId {
                            ReturnQRCodeView(issueId: issueId)
                        }
                    }
                    
                    if isDisabled && !isBookIssued {
                        Text(LocalizationManager.shared.localizedString("account_disabled"))
                            .font(.custom("Charter", size: 12))
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.top, 5)
                    }
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                            .frame(width: 118, height: 60)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.top, -1),
                                alignment: .top
                            )
                            .overlay(
                                Rectangle()
                                    .frame(width: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.trailing, -1),
                                alignment: .trailing
                            )
                            .overlay(
                                Rectangle()
                                    .frame(height: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.bottom, -1),
                                alignment: .bottom
                            )
                            .overlay(
                                Rectangle()
                                    .frame(width: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.leading, -1),
                                alignment: .leading
                            )
                            .overlay(
                                VStack {
                                    Button(action: {
                                        isInBag.toggle()
                                        Task {
                                            if let userId = supabaseManager.currentUser?.id {
                                                do {
                                                    try await supabaseManager.updateMyBag(
                                                        userId: userId,
                                                        bookId: book.id,
                                                        addToBag: isInBag
                                                    )
                                                } catch {
                                                    print("Error updating myBag: \(error)")
                                                }
                                            }
                                        }
                                    }) {
                                        Image(systemName: isInBag ? "bag.fill" : "bag")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(LocalizationManager.shared.localizedString("add_to_bag"))
                                        .font(.custom("Charter", size: 10))
                                },
                                alignment: .center
                            )
                        Rectangle()
                            .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                            .frame(width: 118, height: 60)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.top, -1),
                                alignment: .top
                            )
                            .overlay(
                                Rectangle()
                                    .frame(width: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.trailing, -1),
                                alignment: .trailing
                            )
                            .overlay(
                                Rectangle()
                                    .frame(height: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.bottom, -1),
                                alignment: .bottom
                            )
                            .overlay(
                                Rectangle()
                                    .frame(width: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.leading, -1),
                                alignment: .leading
                            )
                            .overlay(
                                VStack {
                                    Button(action: {
                                        isFavorite.toggle()
                                        Task {
                                            if let userId = supabaseManager.currentUser?.id {
                                                do {
                                                    // Update favorites status
                                                    try await supabaseManager.updateFavourites(
                                                        userId: userId,
                                                        bookId: book.id,
                                                        isFavourite: isFavorite
                                                    )
                                                    
                                                    // Add or remove from Favorites shelf
                                                    if isFavorite {
                                                        try await supabaseManager.addBookToShelf(
                                                            userId: userId,
                                                            shelfName: "Favorites",
                                                            bookId: book.id
                                                        )
                                                    } else {
                                                        try await supabaseManager.removeBookFromShelf(
                                                            userId: userId,
                                                            shelfName: "Favorites",
                                                            bookId: book.id
                                                        )
                                                    }
                                                } catch {
                                                    print("Error updating favourites: \(error)")
                                                }
                                            }
                                        }
                                    }) {
                                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(LocalizationManager.shared.localizedString("add_to_favourites"))
                                        .font(.custom("Charter", size: 10))
                                },
                                alignment: .center
                            )
                        Rectangle()
                            .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                            .frame(width: 118, height: 60)
                            .overlay(
                                Rectangle()
                                    .frame(height: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.top, -1),
                                alignment: .top
                            )
                            .overlay(
                                Rectangle()
                                    .frame(width: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.trailing, -1),
                                alignment: .trailing
                            )
                            .overlay(
                                Rectangle()
                                    .frame(height: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.bottom, -1),
                                alignment: .bottom
                            )
                            .overlay(
                                Rectangle()
                                    .frame(width: 1.25)
                                    .foregroundColor(.black)
                                    .padding(.leading, -1),
                                alignment: .leading
                            )
                            .overlay(
                                VStack {
                                    Button(action: {
                                        showingAddToShelf = true
                                    }) {
                                        Image(systemName: isInAnyShelf ? "books.vertical.fill" : "books.vertical")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(LocalizationManager.shared.localizedString("add_to_myshelf"))
                                        .font(.custom("Charter", size: 10))
                                },
                                alignment: .center
                            )
                        
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Text(LocalizationManager.shared.localizedString("genre"))
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(width: 120, alignment: .leading)
                            
                            Text(book.genre)
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Text(LocalizationManager.shared.localizedString("shelf_location"))
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(width: 120, alignment: .leading)
                            
                            Text(book.shelfLocation ?? "N/A")
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Text(LocalizationManager.shared.localizedString("available_copies"))
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(width: 120, alignment: .leading)
                            
                            Text("\(book.availableCopies)")
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Text(LocalizationManager.shared.localizedString("publisher"))
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(width: 120, alignment: .leading)
                            
                            Text(book.publisher ?? "N/A")
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Text(LocalizationManager.shared.localizedString("released"))
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(width: 120, alignment: .leading)
                            
                            Text(book.publicationDate)
                                .font(.custom("Charter", size: 14))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Rectangle()
                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                        .frame(width: 365, height: 1)
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.top, -1),
                            alignment: .top
                        )
                    
                    TranslatedBookDescription(book.Description ?? "No description available")
                        .font(.custom("Charter", size: 13))
                        .foregroundColor(.black)
                        .lineLimit(nil)
                        .padding(.horizontal)
                        .frame(width: 400, alignment: .center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                // Check if the book is already in favourites and bag
                if let userId = supabaseManager.currentUser?.id {
                    Task {
                        do {
                            // Check favourites
                            let query = supabaseManager.client
                                .from("Member")
                                .select()
                                .eq("id", value: userId)
                            
                            let response: [Member] = try await query.execute().value
                            if let member = response.first {
                                isFavorite = member.favourites.contains(book.id.uuidString)
                                isInBag = member.myBag.contains(book.id.uuidString)
                                
                                // Check if member is disabled
                                let memberDisabledQuery = supabaseManager.client
                                    .from("Member")
                                    .select("is_disabled")
                                    .eq("id", value: userId)
                                
                                let memberDisabledResponse = try await memberDisabledQuery.execute()
                                do {
                                    if memberDisabledResponse.data != nil {
                                        let jsonObject = try JSONSerialization.jsonObject(with: memberDisabledResponse.data) as? [[String: Any]]
                                        if let firstMember = jsonObject?.first,
                                           let isDisabledValue = firstMember["is_disabled"] as? Bool {
                                            await MainActor.run {
                                                isDisabled = isDisabledValue
                                            }
                                        }
                                    }
                                } catch {
                                    print("Error parsing is_disabled flag: \(error)")
                                }
                            }
                            
                            // Check if book is issued to current user
                            let issueQuery = supabaseManager.client
                                .from("BookIssue")
                                .select()
                                .eq("memberId", value: userId)
                                .eq("bookId", value: book.id)
                                .eq("status", value: "Issued")
                            
                            let issueResponse: [BookIssue] = try await issueQuery.execute().value
                            if let issue = issueResponse.first {
                                isBookIssued = true
                                currentIssueId = issue.id
                            }
                            
                            // Check if book is in any shelf
                            let shelvesQuery = supabaseManager.client
                                .from("member_shelves")
                                .select()
                                .eq("member_id", value: userId)
                                .eq("book_id", value: book.id)
                            
                            let shelvesResponse: [MemberShelves] = try await shelvesQuery.execute().value
                            await MainActor.run {
                                isInAnyShelf = !shelvesResponse.isEmpty
                            }
                        } catch {
                            print("Error fetching data: \(error)")
                        }
                    }
                }
            }
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
        .id(localizationManager.currentLanguage.rawValue)
        .id(refreshTrigger)
        .sheet(isPresented: $showingAddToShelf) {
            AddToShelfView(book: book, isInAnyShelf: $isInAnyShelf)
        }
    }
    
    private func startCheckingIssueStatus() {
        // Check every 2 seconds for issue status
        checkIssueTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task {
                await checkIssueStatus()
            }
        }
    }
    
    private func stopCheckingIssueStatus() {
        checkIssueTimer?.invalidate()
        checkIssueTimer = nil
    }
    
    private func checkIssueStatus() async {
        guard let userId = supabaseManager.currentUser?.id else { return }
        
        do {
            let issueQuery = supabaseManager.client
                .from("BookIssue")
                .select()
                .eq("memberId", value: userId)
                .eq("bookId", value: book.id)
                .eq("status", value: "Issued")
            
            let issueResponse: [BookIssue] = try await issueQuery.execute().value
            if let issue = issueResponse.first {
                // Book has been issued, update UI and close QR view
                await MainActor.run {
                    isBookIssued = true
                    currentIssueId = issue.id
                    showingQRCode = false
                    refreshTrigger.toggle()
                }
                stopCheckingIssueStatus()
            }
        } catch {
            print("Error checking issue status: \(error)")
        }
    }
}

struct AddToShelfView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var categories: [String] = []
    @State private var showingAddModal = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    let book: Book
    @Binding var isInAnyShelf: Bool
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    var filteredCategories: [String] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Add to Shelf")
                        .font(.custom("Charter", size: 20))
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "875232"))
                        .padding(.leading, 10)
                    
                    TextField("Search shelves...", text: $searchText)
                        .font(.custom("Charter", size: 16))
                        .padding(.vertical, 12)
                }
                .background(Color(hex: "FCEFD5"))
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Shelf list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredCategories, id: \.self) { category in
                            Button(action: {
                                addBookToShelf(category)
                            }) {
                                HStack {
                                    Text(category)
                                        .font(.custom("Charter", size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(hex: "DE5B23"))
                                }
                                .padding()
                                .background(Color(hex: "FCEFD5"))
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 0.5)
                                )
                            }
                        }
                    }
                }
                
                // Add new shelf button
                Button(action: {
                    showingAddModal = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "DE5B23"))
                        
                        Text("Create New Shelf")
                            .font(.custom("Charter", size: 16))
                            .foregroundColor(Color(hex: "DE5B23"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "FCEFD5"))
                    .overlay(
                        Rectangle()
                            .stroke(Color(hex: "DE5B23"), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            // Success message overlay
            if showSuccessMessage {
                VStack {
                    Spacer()
                    Text(successMessage)
                        .font(.custom("Charter", size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "DE5B23"))
                        .cornerRadius(8)
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showingAddModal) {
            AddModalView { newShelfName in
                createNewShelf(newShelfName)
            }
        }
        .onAppear {
            loadUserShelves()
        }
    }
    
    private func loadUserShelves() {
        guard let currentUser = supabaseManager.currentUser else { return }
        
        Task {
            do {
                let userShelves = try await supabaseManager.fetchUserShelves(userId: currentUser.id)
                await MainActor.run {
                    categories = Array(userShelves.keys)
                }
            } catch {
                print("Error loading shelves: \(error)")
            }
        }
    }
    
    private func createNewShelf(_ shelfName: String) {
        guard let currentUser = supabaseManager.currentUser else { return }
        
        Task {
            do {
                try await supabaseManager.createShelf(userId: currentUser.id, shelfName: shelfName)
                await MainActor.run {
                    categories.append(shelfName)
                }
            } catch {
                print("Error creating shelf: \(error)")
            }
        }
    }
    
    private func addBookToShelf(_ shelfName: String) {
        guard let currentUser = supabaseManager.currentUser else { return }
        
        Task {
            do {
                try await supabaseManager.addBookToShelf(
                    userId: currentUser.id,
                    shelfName: shelfName,
                    bookId: book.id
                )
                await MainActor.run {
                    // Update isInAnyShelf if the shelf is not Favorites
                    if shelfName != "Favorites" {
                        isInAnyShelf = true
                    }
                    
                    successMessage = "Book added to \(shelfName) shelf"
                    withAnimation {
                        showSuccessMessage = true
                    }
                    
                    // Hide the success message after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showSuccessMessage = false
                        }
                    }
                }
            } catch {
                print("Error adding book to shelf: \(error)")
            }
        }
    }
}

