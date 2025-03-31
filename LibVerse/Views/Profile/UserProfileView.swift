import SwiftUI

struct UserProfileView: View {
    // Using mock data for now
    let profile: UserProfile = .mockProfile
    @State private var selectedTab = 0
    @State private var showEditProfile = false
    @Binding var showMainApp: Bool
    @Binding var showUserInitialView: Bool
    @Environment(\.presentationMode) var presentationMode
    
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
                    
                    // Fines Card
                    finesCard
                    
                    // Tab Picker
                    tabPicker
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        borrowedBooksList
                    } else {
                        accountDetails
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 80) // Add padding for the logout button
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            
            // Fixed Logout Button at bottom
            VStack {
                Button(action: {
                    Task {
                        try? await SupabaseManager.shared.signOut()
                        showMainApp = false
                        showUserInitialView = true
                    }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .fontWeight(.regular)
                    }
                    .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: profile)
        }
    }
    
    private var profileHeader: some View {
        Button(action: {
            showEditProfile = true
        }) {
            HStack(spacing: 15) {
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .clipShape(Circle())
                
                // User Info
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(profile.email)
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
            Text("Current Fines")
                .font(.headline)
            
            Spacer()
            
            Text("₹\(String(format: "%.2f", profile.fines))")
                .font(.title2)
                .bold()
                .foregroundColor(profile.fines > 0 ? .black : .black)
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
        .padding(.horizontal)
    }
    
    private var borrowedBooksList: some View {
        VStack(spacing: 15) {
            ForEach(profile.borrowedBooks) { book in
                BorrowedBookCard(book: book)
            }
        }
        .padding(.horizontal)
    }
    
    private var accountDetails: some View {
        VStack(spacing: 20) {
            DetailRow(title: "Email", value: profile.email)
            DetailRow(title: "Enrollment Number", value: profile.enrollmentNumber)
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
            Label("Borrowed Books", systemImage: "book.fill").tag(0)
            Label("Account Details", systemImage: "person.fill").tag(1)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
}

struct BorrowedBookCard: View {
    let book: BorrowedBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack {
                    HStack {
                        Text(book.title)
                            .font(.headline)
                            .padding(.leading, 0)
                        
                        Spacer()
                        HStack {
                            Image(systemName: book.isOverdue ? "exclamationmark.triangle.fill" : "clock.fill")
                                .foregroundColor(book.isOverdue ? .red : .black)
                            
                            Text(book.isOverdue ? "Overdue by \(abs(book.daysRemaining)) days" : "Due in \(book.daysRemaining) days")
                                .font(.subheadline)
                                .foregroundColor(book.isOverdue ? .red : .black)
                        }
                    }
                    
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.leading, -165)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
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
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var enrollmentNumber: String
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(profile: UserProfile) {
        self.profile = profile
        _firstName = State(initialValue: profile.firstName)
        _lastName = State(initialValue: profile.lastName)
        _enrollmentNumber = State(initialValue: profile.enrollmentNumber)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image with Edit Icon
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .clipShape(Circle())
                            .padding(.top)

                        Button(action: {
                            // Action to edit profile image
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                        .offset(x: 8, y: 8)
                    }

                    // Edit Form
                    VStack(spacing: 15) {
                        EditField(title: "First Name", text: $firstName)
                        EditField(title: "Last Name", text: $lastName)
                        EditField(title: "Enrollment Number", text: $enrollmentNumber)
                    }
                    .padding()
                    .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .cornerRadius(0)
                    .padding(.horizontal)

                    // Save Button
                    Button(action: saveChanges) {
                        Text("Save Changes")
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
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                }
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage == "Profile updated successfully!" {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .edgesIgnoringSafeArea(.all)
    }

    private func saveChanges() {
        alertMessage = "Profile updated successfully!"
        showAlert = true
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
}

#Preview {
    UserProfileView(showMainApp: .constant(true), showUserInitialView: .constant(true))
}
