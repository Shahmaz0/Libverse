import SwiftUI

struct UserProfileView: View {
    // Using mock data for now
    let profile: UserProfile = .mockProfile
    @State private var selectedTab = 0
    @State private var showEditProfile = false
    @Binding var showMainApp: Bool
    @Binding var showUserInitialView: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Fines Card
                    finesCard
                    
                    // Tab Picker
                    Picker("View", selection: $selectedTab) {
                        Text("Borrowed Books").tag(0)
                        Text("Account Details").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        borrowedBooksList
                    } else {
                        accountDetails
                    }
                    
                    // Action Buttons
                    VStack(spacing: 15) {
                        // Edit Profile Button
                        Button(action: {
                            showEditProfile = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        // Logout Button
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
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(profile: profile)
            }
        }
    }
    
    private var profileHeader: some View {
        Button(action: {
            showEditProfile = true
        }) {
            VStack(spacing: 15) {
                // Profile Image Container
                ZStack {
                    // Square background
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 1.25)
                        )
                    
                    // Profile Image
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
                
                // User Info
                VStack(spacing: 8) {
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.custom("Courier New", size: 20))
                        .bold()
                    
                    Text(profile.department)
                        .font(.custom("Courier", size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // Edit indicator
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                    Text("Tap to edit profile")
                        .font(.custom("Courier", size: 14))
                        .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                }
                .padding(.bottom, 5)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var finesCard: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Current Fines")
                    .font(.headline)
                Text("₹\(String(format: "%.2f", profile.fines))")
                    .font(.title2)
                    .bold()
                    .foregroundColor(profile.fines > 0 ? .red : .green)
            }
            
            Spacer()
            
            Button(action: {
                // Handle payment action
            }) {
                Text("Pay Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(profile.fines > 0 ? Color.red : Color.green)
                    .cornerRadius(8)
            }
            .disabled(profile.fines == 0)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
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
            DetailRow(title: "User ID", value: profile.userId)
            DetailRow(title: "Email", value: profile.email)
            DetailRow(title: "Department", value: profile.department)
            DetailRow(title: "Enrollment Number", value: profile.enrollmentNumber)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct BorrowedBookCard: View {
    let book: BorrowedBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(book.title)
                .font(.headline)
            
            Text(book.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: book.isOverdue ? "exclamationmark.triangle.fill" : "clock.fill")
                    .foregroundColor(book.isOverdue ? .red : .green)
                
                Text(book.isOverdue ? "Overdue by \(abs(book.daysRemaining)) days" : "Due in \(book.daysRemaining) days")
                    .font(.subheadline)
                    .foregroundColor(book.isOverdue ? .red : .green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
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

// Add EditProfileView
struct EditProfileView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var department: String
    @State private var enrollmentNumber: String
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(profile: UserProfile) {
        self.profile = profile
        _firstName = State(initialValue: profile.firstName)
        _lastName = State(initialValue: profile.lastName)
        _department = State(initialValue: profile.department)
        _enrollmentNumber = State(initialValue: profile.enrollmentNumber)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top)
                    
                    // Edit Form
                    VStack(spacing: 15) {
                        EditField(title: "First Name", text: $firstName)
                        EditField(title: "Last Name", text: $lastName)
                        EditField(title: "Department", text: $department)
                        EditField(title: "Enrollment Number", text: $enrollmentNumber)
                    }
                    .padding()
                    
                    // Save Button
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
        }
    }
    
    private func saveChanges() {
        // Here you would typically update the profile in your database
        // For now, we'll just show a success message
        alertMessage = "Profile updated successfully!"
        showAlert = true
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
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.custom("Courier", size: 16))
        }
    }
}

#Preview {
    UserProfileView(showMainApp: .constant(true), showUserInitialView: .constant(true))
} 
