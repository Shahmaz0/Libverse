import SwiftUI
import Combine

struct UserProfileView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var showEditProfile = false
    @State private var showGenrePreferences = false
    @Binding var showMainApp: Bool
    @Binding var showUserInitialView: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var profile: Member? {
        supabaseManager.currentMember
    }
    
    init(showMainApp: Binding<Bool>, showUserInitialView: Binding<Bool>) {
        _showMainApp = showMainApp
        _showUserInitialView = showUserInitialView
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    // Fines Card
                    finesCard
                    
                    //Policy Card
                    policyCard
                    
                    // Account Details (always visible)
                    accountDetails
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
                backButton
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: profile ?? Member(id: UUID(), email: "", firstName: "", lastName: "", enrollmentNumber: nil, fines: 0.0, borrowedBooks: []))
        }
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
            Text("Current Fines")
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
                
                Text("Library Policies")
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
        }
    }
    
    private var accountDetails: some View {
        VStack(spacing: 20) {
            DetailRow(title: "Email", value: profile?.email ?? "N/A")
            DetailRow(title: "Enrollment Number", value: profile?.enrollmentNumber ?? "N/A")
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
        .padding(.horizontal)
    }
    
    private var backButton: some View {
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
                        EditField(title: "First Name", text: $firstName)
                        EditField(title: "Last Name", text: $lastName)
                        EditField(title: "Enrollment Number", text: $enrollmentNumber)
                    }
                    .padding()
                    .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .cornerRadius(0)
                    .padding(.horizontal)

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
                
                alertMessage = "Profile updated successfully!"
                showAlert = true
            } catch {
                alertMessage = "Failed to update profile: \(error.localizedDescription)"
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
