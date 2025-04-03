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
        ZStack(alignment: .bottom) {
            // Background and border
            VStack(spacing: 0) {
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
            }
            
            // Fixed position title and button
            HStack {
                // Title with fixed position
                Text(title)
                    .font(.custom("Charter", size: 20))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                
                // Only animate the button text, not its position
                if showEditButton {
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Text(isEditMode ? "Cancel" : "Edit")
                            .font(.custom("Charter", size: 16))
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 40)
                    .animation(nil, value: isEditMode) // Disable animation for the button position
                }
            }
            .frame(height: 60)
        }
    }
}

struct MyBag: View {
    @StateObject var viewModel = MyBagViewModel()
    @EnvironmentObject var supabaseManager: SupabaseManager
    @State private var isEditMode = false
    @State private var selectedBooks: Set<UUID> = []
    @State private var showingQRCode = false
    @State private var currentIssueId: UUID?
    @State private var booksToIssue: [Book] = []
    @State private var showDeleteAlert = false
    @State private var bookToDelete: UUID?
    @State private var showDeleteAllAlert = false
    
    var body: some View {
        ZStack {

            Color(red: 255/255, green: 239/255, blue: 210/255)
                .ignoresSafeArea()
            
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
                                    BookCard(
                                        BookImage: book.imageLink ?? "",
                                        title: book.title,
                                        author: book.author.joined(separator: ", "),
                                        description: book.Description ?? "No description available",
                                        showPlusButton: isEditMode,
                                        onPlusButtonTapped: {
                                            withAnimation(.easeIn) {
                                                if selectedBooks.contains(book.id) {
                                                    selectedBooks.remove(book.id)
                                                } else {
                                                    selectedBooks.insert(book.id)
                                                }
                                            }
                                        },
                                        isAdded: selectedBooks.contains(book.id),
                                        deleteAction: {
                                            bookToDelete = book.id
                                            showDeleteAlert = true
                                        },
                                        showDeleteAction: false
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
                
                // Bottom Buttons
                HStack(spacing: 10) {
                    if !isEditMode && !viewModel.bagBooks.isEmpty {
                        // Only show Borrow All button in non-edit mode
                        Button(action: {
                            booksToIssue = viewModel.bagBooks
                            viewModel.issueAllBooks { issueId in
                                currentIssueId = issueId
                                showingQRCode = true
                            }
                        }) {
                            Text("Borrow All")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                .foregroundColor(.white)
                                .border(.black, width: 1)
                                .cornerRadius(0)
                        }
                        .frame(width: UIScreen.main.bounds.width - 32, height: 30, alignment: .center)
                    } else if isEditMode {
                        // Delete Selected button in edit mode
                        Button(action: {
                            if !selectedBooks.isEmpty {
                                viewModel.removeSelectedBooks(Array(selectedBooks)) { success in
                                    if success {
                                        selectedBooks.removeAll()
                                        isEditMode = false
                                    }
                                }
                            }
                        }) {
                            Text(selectedBooks.isEmpty ? "Delete" : "Delete \(selectedBooks.count)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedBooks.isEmpty ? Color.gray : Color.red)
                                .foregroundColor(.white)
                                .border(.black, width: 1)
                                .cornerRadius(0)
                        }
                        .disabled(selectedBooks.isEmpty)
                        .frame(width: (UIScreen.main.bounds.width - 42) / 2, height: 30, alignment: .center)
                        
                        // Issue Selected button in edit mode
                        Button(action: {
                            if !selectedBooks.isEmpty {
                                booksToIssue = viewModel.bagBooks.filter { selectedBooks.contains($0.id) }
                                viewModel.issueSelectedBooks(Array(selectedBooks)) { issueId in
                                    currentIssueId = issueId
                                    showingQRCode = true
                                    selectedBooks.removeAll()
                                    isEditMode = false
                                }
                            }
                        }) {
                            Text(selectedBooks.isEmpty ? "Issue" : "Issue \(selectedBooks.count)")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(selectedBooks.isEmpty ? Color.gray : Color(red: 255/255, green: 111/255, blue: 45/255))
                                .border(.black, width: 1)
                                .cornerRadius(0)
                        }
                        .disabled(selectedBooks.isEmpty)
                        .frame(width: (UIScreen.main.bounds.width - 42) / 2, height: 30, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
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
            .alert("Delete Book", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let bookId = bookToDelete {
                        viewModel.removeBookFromBag(bookId) { _ in
                            bookToDelete = nil
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to remove this book from your bag?")
            }
            .alert("Delete All Books", isPresented: $showDeleteAllAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    viewModel.removeAllBooks { _ in }
                }
            } message: {
                Text("Are you sure you want to remove all books from your bag?")
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
    
    func removeBookFromBag(_ bookId: UUID, completion: @escaping (Bool) -> Void) {
        guard let userId = supabaseManager.currentUser?.id else {
            errorMessage = "You need to be logged in to remove books"
            completion(false)
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await supabaseManager.updateMyBag(
                    userId: userId,
                    bookId: bookId,
                    addToBag: false
                )
                
                await MainActor.run {
                    bagBooks.removeAll { $0.id == bookId }
                    isLoading = false
                    completion(true)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to remove book: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    func removeSelectedBooks(_ selectedIds: [UUID], completion: @escaping (Bool) -> Void) {
        guard let userId = supabaseManager.currentUser?.id else {
            errorMessage = "You need to be logged in to remove books"
            completion(false)
            return
        }
        
        isLoading = true
        
        Task {
            do {
                for bookId in selectedIds {
                    try await supabaseManager.updateMyBag(
                        userId: userId,
                        bookId: bookId,
                        addToBag: false
                    )
                }
                
                await MainActor.run {
                    bagBooks.removeAll { selectedIds.contains($0.id) }
                    isLoading = false
                    completion(true)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to remove books: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
    
    func removeAllBooks(completion: @escaping (Bool) -> Void) {
        let allBookIds = bagBooks.map { $0.id }
        removeSelectedBooks(allBookIds, completion: completion)
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
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    @State private var timeRemaining: TimeInterval = 300 // 5 minutes in seconds
    @State private var qrImage: UIImage?
    @State private var isExpired = false
    @State private var checkIssueTimer: Timer?
    @State private var refreshTrigger: Bool = false
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
            Task {
                qrImage = await generateQRCode()
            }
            startCheckingIssueStatus()
        }
        .onDisappear {
            stopCheckingIssueStatus()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    isExpired = true
                    Task {
                        qrImage = await generateQRCode()
                    }
                }
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func generateQRCode() async -> UIImage {
        let expirationDate = Date().addingTimeInterval(5 * 60)
        let issueDate = Date()
        
        // Fetch return period from library_policies
        do {
            let policiesQuery = supabaseManager.client
                .from("library_policies")
                .select()
                .limit(1)
            
            let policies: [LibraryPolicyNew] = try await policiesQuery.execute().value
            let returnPeriod = policies.first?.returnPeriod ?? 14 // Default to 14 days if not found
            
            let returnDate = Calendar.current.date(byAdding: .day, value: returnPeriod, to: issueDate) ?? issueDate
            
            // Create the QR data structure
            let qrData: [String: Any] = [
                "bookIssue": [
                    "bookIds": books.map { $0.id.uuidString },
                    "memberId": memberId,
                    "id": issueId.uuidString,
                    "issueDate": ISO8601DateFormatter().string(from: issueDate),
                    "status": "Pending",
                    "returnDate": ISO8601DateFormatter().string(from: returnDate)
                ],
                "expirationDate": expirationDate.timeIntervalSince1970,
                "timestamp": Date().timeIntervalSince1970,
                "isValid": !isExpired
            ]
            
            // Convert to JSON data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: qrData),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to create JSON string")
                return UIImage(systemName: "xmark.circle") ?? UIImage()
            }
            
            print("Generated QR data: \(jsonString)")
            
            let data = Data(jsonString.utf8)
            let context = CIContext()
            let filter = CIFilter.qrCodeGenerator()
            
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel") // Using high error correction for logo overlay
            
            if let outputImage = filter.outputImage {
                // Scale up the QR code to desired size
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledQRImage = outputImage.transformed(by: transform)
                
                if let qrCGImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) {
                    let size = CGSize(width: qrCGImage.width, height: qrCGImage.height)
                    UIGraphicsBeginImageContextWithOptions(size, false, 0)
                    
                    let qrUIImage = UIImage(cgImage: qrCGImage)
                    qrUIImage.draw(in: CGRect(origin: .zero, size: size))
                    
                    // Add logo in center
                    if let logoImage = UIImage(named: "QRlogo") {
                        let logoSize = CGSize(width: size.width * 0.25, height: size.height * 0.25)
                        let logoX = (size.width - logoSize.width) / 2
                        let logoY = (size.height - logoSize.height) / 2
                        let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
                        
                        // Create circular mask for logo
                        UIGraphicsBeginImageContextWithOptions(logoSize, false, 1.0)
                        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: logoSize))
                        circlePath.addClip()
                        
                        // Draw logo with white background
                        UIColor.white.setFill()
                        UIBezierPath(rect: CGRect(origin: .zero, size: logoSize)).fill()
                        logoImage.draw(in: CGRect(origin: .zero, size: logoSize))
                        
                        let circularLogo = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        // Draw circular logo on QR code
                        circularLogo?.draw(in: logoRect)
                    }
                    
                    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    print("Successfully generated QR code")
                    return finalImage ?? UIImage(systemName: "xmark.circle") ?? UIImage()
                }
            }
        } catch {
            print("Error fetching library policies: \(error)")
        }
        
        print("Failed to generate QR code image")
        return UIImage(systemName: "xmark.circle") ?? UIImage()
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
                .eq("id", value: issueId)
                .eq("memberId", value: userId)
                .in("bookId", values: books.map { $0.id })
                .eq("status", value: "Issued")
            
            let issueResponse: [BookIssue] = try await issueQuery.execute().value
            
            // Check if all books in the issue have been processed
            if issueResponse.count == books.count {
                // All books have been issued, close the QR view
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
                stopCheckingIssueStatus()
            }
        } catch {
            print("Error checking issue status: \(error)")
        }
    }
}

// Add LibraryPolicy struct
//struct LibraryPolicyNew: Codable {
//    let id: UUID
//    let borrowingLimit: Int
//    let returnPeriod: Int
//    let fineAmount: Int
//    let lostBookFine: Int
//    let lastUpdated: Date?
//    let createdAt: Date?
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case borrowingLimit = "borrowing_limit"
//        case returnPeriod = "return_period"
//        case fineAmount = "fine_amount"
//        case lostBookFine = "lost_book_fine"
//        case lastUpdated = "last_updated"
//        case createdAt = "created_at"
//    }
//}

