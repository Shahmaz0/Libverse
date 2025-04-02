import SwiftUI

struct GenreSelectionView: View {
    @State private var selectedGenres: Set<String> = []
    @Binding var showOnboarding: Bool
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Genres from the HomeView
    let genres = ["Technology", "Business", "Reference", "Medicine", "Mathematics", "Law", "Science"]
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            VStack(spacing: 15) {
                Text("Select Your Interests")
                    .font(.custom("Courier New", size: 26))
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Choose genres you're interested in to personalize your recommendations")
                    .font(.custom("Courier", size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Genre Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(genres, id: \.self) { genre in
                    GenreCard(
                        genre: genre,
                        isSelected: selectedGenres.contains(genre),
                        action: {
                            if selectedGenres.contains(genre) {
                                selectedGenres.remove(genre)
                            } else {
                                selectedGenres.insert(genre)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 15) {
                Button(action: savePreferencesAndContinue) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Continue")
                    }
                    
                    Spacer()
                        .frame(width: 0)
                    
                    if !isLoading {
                        Image(systemName: "arrow.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedGenres.isEmpty ? Color.gray : Color(red: 255/255, green: 111/255, blue: 45/255))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .disabled(selectedGenres.isEmpty || isLoading)
                
                Button(action: skipAndContinue) {
                    Text("Skip for now")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .medium))
                }
                .disabled(isLoading)
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func savePreferencesAndContinue() {
        guard !selectedGenres.isEmpty else { return }
        saveGenres(Array(selectedGenres))
    }
    
    private func skipAndContinue() {
        // Just dismiss onboarding without saving preferences
        showOnboarding = false
    }
    
    private func saveGenres(_ genres: [String]) {
        guard let userId = SupabaseManager.shared.currentUser?.id else {
            showAlert = true
            alertMessage = "You need to be logged in to save preferences"
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Save to Supabase
                try await SupabaseManager.shared.updateSelectedGenres(userId: userId, genres: genres)
                
                // Also save locally
                UserPreferences.shared.saveGenrePreferences(genres)
                
                // Post notification that preferences were updated to refresh recommendations
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("genrePreferencesUpdated"), object: nil)
                    isLoading = false
                    showOnboarding = false
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    showAlert = true
                    alertMessage = "Failed to save preferences: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct GenreCard: View {
    let genre: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon based on genre
                Image(systemName: iconForGenre(genre))
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .orange)
                
                Text(genre)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(isSelected ? Color.orange : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1.5)
            )
        }
    }
    
    // Helper function to determine icon based on genre
    private func iconForGenre(_ genre: String) -> String {
        switch genre {
        case "Technology":
            return "laptopcomputer"
        case "Business":
            return "briefcase.fill"
        case "Reference":
            return "books.vertical.fill"
        case "Medicine":
            return "cross.case.fill"
        case "Mathematics":
            return "function"
        case "Law":
            return "scale.3d"
        case "Science":
            return "atom"
        default:
            return "book.fill"
        }
    }
}

#Preview {
    GenreSelectionView(showOnboarding: .constant(true))
} 