import SwiftUI
import Combine

struct UserProfileView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    @State private var showEditProfile = false
    @State private var showGenrePreferences = false
    @Binding var showMainApp: Bool
    @Binding var showUserInitialView: Bool
    @Environment(\.presentationMode) var presentationMode
    
    // Book data states
    @State private var currentlyBorrowedBooks: [Book] = []
    @State private var borrowingHistoryBooks: [Book] = []
    @State private var isLoading = false
    
    var profile: Member? {
        supabaseManager.currentMember
    }
    
    init(showMainApp: Binding<Bool>, showUserInitialView: Binding<Bool>) {
        _showMainApp = showMainApp
        _showUserInitialView = showUserInitialView
        
        // Customize segmented control appearance
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color(red: 255/255, green: 111/255, blue: 45/255))
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Language Selector
                    LanguageSelector()
                    
                    // Fines Card
                    finesCard
                    
                    //Policy Card
                    policyCard
                    
                    // Account Details (always visible)
                    accountDetails
                    
                    // Tab Picker
                    tabPicker
                    
                    // Content based on selected tab
                    if isLoading {
                        ProgressView()
                            .padding(.vertical, 50)
                    } else {
                        if selectedTab == 0 {
                            currentlyBorrowedBooksList
                        } else {
                            borrowingHistoryList
                        }
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 80)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            
            // Fixed Logout Button at bottom
            VStack {
                Button(action: {
                    Task {
                        do {
                            // Clear user preferences before signing out
                            UserPreferences.shared.clearAllPreferences()
                            
                            // Sign out from Supabase
                            try await SupabaseManager.shared.signOut()
                            
                            // Update UI state
                            showMainApp = false
                            showUserInitialView = true
                        } catch {
                            print("Error during logout: \(error)")
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        LocalizedText("logout")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .foregroundColor(.white)
                    .overlay(RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1.25))
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .navigationTitle(localizationManager.localizedString("profile"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: profile ?? Member(id: UUID(), email: "", firstName: "", lastName: "", enrollmentNumber: nil, fines: 0.0, borrowedBooks: []))
        }
        .task {
            await loadBooks()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            // Force view refresh when language changes
        }
    }
    
    // MARK: - Data Loading
    
    private func loadBooks() async {
        guard let userId = supabaseManager.currentUser?.id else { return }
        
        isLoading = true
        
        do {
            // Fetch currently borrowed books (issued or overdue)
            let activeIssues: [BookIssue] = try await supabaseManager.client
                .from("BookIssue")
                .select()
                .eq("memberId", value: userId)
                .in("status", value: ["Issued", "Overdue"])
                .execute()
                .value
            
            // Fetch borrowing history (returned books)
            let returnedIssues: [BookIssue] = try await supabaseManager.client
                .from("BookIssue")
                .select()
                .eq("memberId", value: userId)
                .eq("status", value: "Returned")
                .execute()
                .value
            
            // Get book details
            currentlyBorrowedBooks = try await fetchBooks(for: activeIssues)
            borrowingHistoryBooks = try await fetchBooks(for: returnedIssues)
            
        } catch {
            print("Error loading books: \(error)")
        }
        isLoading = false
    }
    
    private func fetchBooks(for issues: [BookIssue]) async throws -> [Book] {
        guard !issues.isEmpty else { return [] }
        
        let bookIds = issues.map { $0.bookId }
        
        let books: [Book] = try await supabaseManager.client
            .from("Books")
            .select()
            .in("id", value: bookIds)
            .execute()
            .value
        
        return books
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        Button(action: { showEditProfile = true }) {
            HStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(profile?.firstName ?? "") \(profile?.lastName ?? "")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(profile?.email ?? "")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            .cornerRadius(0)
            .overlay(RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 1.25))
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var finesCard: some View {
        HStack {
            LocalizedText("current_fines")
                .font(.headline)
            
            Spacer()
            
            Text("₹\(String(format: "%.2f", profile?.fines ?? 0.0))")
                .font(.title2)
                .bold()
                .foregroundColor((profile?.fines ?? 0) > 0 ? .red : .black)
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
        .padding(.horizontal)
    }
    
    private var policyCard: some View {
        NavigationLink(destination: LibraryPoliciesView()) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                
                LocalizedText("library_policies")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            .cornerRadius(0)
            .overlay(RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 1.25))
            .padding(.horizontal)
        }
    }
    
    private var currentlyBorrowedBooksList: some View {
        Group {
            if currentlyBorrowedBooks.isEmpty {
                LocalizedText("no_books_currently_borrowed")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(currentlyBorrowedBooks) { book in
                    LocalizedBookCard(
                        bookImage: book.imageLink ?? "",
                        title: book.title,
                        author: book.author.joined(separator: ", "),
                        description: book.Description ?? "No description available",
                        showPlusButton: false
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var borrowingHistoryList: some View {
        Group {
            if borrowingHistoryBooks.isEmpty {
                LocalizedText("no_borrowing_history_found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(borrowingHistoryBooks) { book in
                    LocalizedBookCard(
                        bookImage: book.imageLink ?? "",
                        title: book.title,
                        author: book.author.joined(separator: ", "),
                        description: book.Description ?? "No description available",
                        showPlusButton: false
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var accountDetails: some View {
        VStack(spacing: 20) {
            DetailRow(title: localizationManager.localizedString("email"), value: profile?.email ?? localizationManager.localizedString("n_a"))
            DetailRow(title: localizationManager.localizedString("enrollment_number"), value: profile?.enrollmentNumber ?? localizationManager.localizedString("n_a"))
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
        .padding(.horizontal)
    }
    
    private var tabPicker: some View {
        Picker("View", selection: $selectedTab) {
            LocalizedText("currently_borrowed").tag(0)
            LocalizedText("borrowing_history").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                LocalizedText("back")
                    .fontWeight(.regular)
            }
            .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
}

struct EditProfileView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    let profile: Member
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var enrollmentNumber: String
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(profile: Member) {
        self.profile = profile
        _firstName = State(initialValue: profile.firstName)
        _lastName = State(initialValue: profile.lastName)
        _enrollmentNumber = State(initialValue: profile.enrollmentNumber ?? "")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .clipShape(Circle())
                            .padding(.top)

                        Button(action: {}) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                        .offset(x: 8, y: 8)
                    }

                    VStack(spacing: 15) {
                        EditField(title: localizationManager.localizedString("first_name"), text: $firstName)
                        EditField(title: localizationManager.localizedString("last_name"), text: $lastName)
                        EditField(title: localizationManager.localizedString("enrollment_number"), text: $enrollmentNumber)
                    }
                    .padding()
                    .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .cornerRadius(0)
                    .padding(.horizontal)

                    Button(action: saveChanges) {
                        LocalizedText("save_changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .foregroundColor(.white)
                            .cornerRadius(0)
                            .overlay(RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.black, lineWidth: 1.25))
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle(localizationManager.localizedString("edit_profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localizedString("cancel")) {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage == localizationManager.localizedString("profile_updated_successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
    }

    private func saveChanges() {
        guard let userId = profile.id else { return }
        
        Task {
            do {
                try await SupabaseManager.shared.updateProfile(
                    userId: userId,
                    firstName: firstName,
                    lastName: lastName,
                    enrollmentNumber: enrollmentNumber.isEmpty ? nil : enrollmentNumber
                )
                
                alertMessage = localizationManager.localizedString("profile_updated_successfully")
                showAlert = true
            } catch {
                alertMessage = "\(localizationManager.localizedString("failed_to_update_profile")) \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

struct EditField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.custom("Courier", size: 16))
                .foregroundColor(.secondary)

            TextField("", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                .overlay(RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 1.25))
                .font(.custom("Courier", size: 16))
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(showMainApp: .constant(true), showUserInitialView: .constant(true))
    }
}
