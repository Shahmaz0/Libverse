//
//  MyBag.swift
//  LibVerse
//
//  Created by Shahma Ansari on 26/03/25.

import SwiftUI

struct HeaderView: View {
    let title: String
    let showEditButton: Bool
    @Binding var isEditMode: Bool
    
    var body: some View {
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
            .overlay(
                HStack(spacing: 0) {
                    Text(title)
                        .font(.custom("Charter", size: 20))
                        .bold()
                        .foregroundColor(.black)
                        .offset(x: isEditMode ? 25 : 0) // Move right in edit mode
                    
                    Spacer()
                    
                    if showEditButton {
                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Text(isEditMode ? "Cancel" : "Edit")
                                .font(.custom("Charter", size: 16))
                                .foregroundColor(.black)
                                .offset(x: isEditMode ? -20 : 0) // Move left in edit mode
                        }
                    }
                }
                .padding(.horizontal, 16)
                .animation(.easeIn, value: isEditMode) // Ensure no animation
            )
    }
}

struct MyBag: View {
    @StateObject var viewModel = MyBagViewModel()
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var isEditMode = true
    @State private var selectedBooks: Set<UUID> = []
    @State private var showingQRCode = false
    @State private var currentIssueId: UUID?
    @State private var booksToIssue: [Book] = []
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 255/255, green: 239/255, blue: 210/255)
                .ignoresSafeArea()
            
            // Header (fixed at top)
            VStack(spacing: 0) {
                HeaderView(
                    title: "My Bag",
                    showEditButton: !viewModel.bagBooks.isEmpty,
                    isEditMode: $isEditMode
                )
                Spacer()
            }
            
            VStack(spacing: 0) {
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 60)
                
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
                                HStack(spacing: 0) {
                                    if isEditMode {
                                        Button(action: {
                                            withAnimation(.easeIn) {
                                                if selectedBooks.contains(book.id) {
                                                    selectedBooks.remove(book.id)
                                                } else {
                                                    selectedBooks.insert(book.id)
                                                }
                                            }
                                        }) {
                                            Image(systemName: selectedBooks.contains(book.id) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 22))
                                                .foregroundColor(selectedBooks.contains(book.id) ? Color(red: 255/255, green: 111/255, blue: 45/255) : .gray)
                                                .frame(width: 44, height: 44)
                                        }
                                        .padding(.leading, 8)
                                    }
                                    
                                    BookCard(
                                        BookImage: book.imageLink ?? "",
                                        title: book.title,
                                        author: book.author.joined(separator: ", "),
                                        description: book.Description ?? "No description available"
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 16)
                    }
                }
                
                Spacer()
                
                // Bottom Button
                if !isEditMode && !viewModel.bagBooks.isEmpty {
                    Button(action: {
                        booksToIssue = viewModel.bagBooks
                        viewModel.issueAllBooks { issueId in
                            currentIssueId = issueId
                            showingQRCode = true
                        }
                    }) {
                        Text("Issue all")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .foregroundColor(.white)
                            .border(.black, width: 1)
                            .cornerRadius(0)
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 30, alignment: .center)
                    .padding(.bottom, 20)
                } else {
                    Button(action: {
                        booksToIssue = viewModel.bagBooks.filter { selectedBooks.contains($0.id) }
                        viewModel.issueSelectedBooks(Array(selectedBooks)) { issueId in
                            currentIssueId = issueId
                            showingQRCode = true
                            selectedBooks.removeAll()
                        }
                    }) {
                        Text(selectedBooks.isEmpty ? "Issue" : "Issue \(selectedBooks.count)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .border(.black, width: 1)
                            .cornerRadius(0)
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 30, alignment: .center)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showingQRCode) {
                if !booksToIssue.isEmpty, let userId = supabaseManager.currentUser?.id {
                    if booksToIssue.count == 1 {
                        QRCodeGeneratorView(
                            book: booksToIssue[0],
                            memberId: userId.uuidString
                        )
                    } else {
                        MultipleBooksQRView(
                            books: booksToIssue,
                            memberId: userId.uuidString,
                            issueId: currentIssueId ?? UUID()
                        )
                    }
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

    
    func issueSelectedBooks(_ selectedIds: [UUID], completion: @escaping (UUID?) -> Void) {
        guard let userId = supabaseManager.currentUser?.id else {
            errorMessage = "You need to be logged in to issue books"
            completion(nil)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Filter the books that are selected
                let selectedBooks = bagBooks.filter { selectedIds.contains($0.id) }
                
                // Check if any selected books are already issued
                let issueQuery = supabaseManager.client
                    .from("BookIssue")
                    .select()
                    .eq("memberId", value: userId)
                    .in("bookId", values: selectedBooks.map { $0.id })
                    .eq("status", value: "Issued")
                
                let existingIssues: [BookIssue] = try await issueQuery.execute().value
                
                if !existingIssues.isEmpty {
                    await MainActor.run {
                        errorMessage = "Some books are already issued"
                        isLoading = false
                    }
                    completion(nil)
                    return
                }
                
                // Check if all selected books are available
                let unavailableBooks = selectedBooks.filter { $0.availableCopies <= 0 }
                if !unavailableBooks.isEmpty {
                    await MainActor.run {
                        errorMessage = "Some books are not available for issue"
                        isLoading = false
                    }
                    completion(nil)
                    return
                }
                
                // Create issues for all selected books
                let issueId = UUID() // Single issue ID for all books
                
                for book in selectedBooks {
                    let newIssue = BookIssue(
                        id: issueId, // Same ID for all books in this batch
                        bookId: book.id,
                        memberId: userId,
                        issueStatus: .pending,
                        issueDate: Date(),
                        returnDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                        actualReturnDate: nil,
                        overdueDays: nil
                    )
                    
                    try await supabaseManager.client
                        .from("BookIssue")
                        .insert(newIssue)
                        .execute()
                    
                    // Update available copies count
                    try await supabaseManager.client
                        .from("Books")
                        .update(["availableCopies": book.availableCopies - 1])
                        .eq("id", value: book.id)
                        .execute()
                    
                    // Remove from bag
                    try await supabaseManager.updateMyBag(
                        userId: userId,
                        bookId: book.id,
                        addToBag: false
                    )
                }
                
                // Refresh the bag
                await MainActor.run {
                    isLoading = false
                    fetchBagBooks()
                    completion(issueId)
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to issue books: \(error.localizedDescription)"
                    completion(nil)
                }
            }
        }
    }

    func issueAllBooks(completion: @escaping (UUID?) -> Void) {
        issueSelectedBooks(bagBooks.map { $0.id }, completion: completion)
    }
}

// New view for multiple books QR code
struct MultipleBooksQRView: View {
    let books: [Book]
    let memberId: String
    let issueId: UUID
    @Environment(\.presentationMode) var presentationMode
    
    @State private var timeRemaining: TimeInterval = 300 // 5 minutes in seconds
    @State private var qrImage: UIImage?
    @State private var isExpired = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                .padding()
                
                Spacer()
                
                Text("Issue QR Code")
                    .font(.custom("Charter", size: 20))
                    .bold()
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            
            Spacer()
            
            Text("Show this QR for \(books.count) books")
                .font(.custom("Charter", size: 24))
                .foregroundColor(.black)
            
            if let qrImage = qrImage {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 290, height: 290)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(width: 280, height: 280)
                    
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .opacity(isExpired ? 0.3 : 1.0)
                    
                    if isExpired {
                        Text("EXPIRED")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text("Time Remaining")
                    .font(.custom("Charter", size: 16))
                Text(formatTime(timeRemaining))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(timeRemaining < 60 ? .red : .black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text("\(books.count) Books Selected")
                    .font(.custom("Charter", size: 18))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text("Includes: \(books.prefix(2).map { $0.title }.joined(separator: ", "))\(books.count > 2 ? " and \(books.count - 2) more" : "")")
                    .font(.custom("Charter", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .onAppear {
            qrImage = generateQRCode()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    isExpired = true
                    qrImage = generateQRCode()
                }
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func generateQRCode() -> UIImage {
        let expirationDate = Date().addingTimeInterval(5 * 60)
        
        // Create a dictionary with all book IDs
        let qrData: [String: Any] = [
            "issueId": issueId.uuidString,
            "bookIds": books.map { $0.id.uuidString },
            "memberId": memberId,
            "expirationDate": expirationDate.timeIntervalSince1970,
            "timestamp": Date().timeIntervalSince1970,
            "isValid": !isExpired
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: qrData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        let data = Data(jsonString.utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
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
