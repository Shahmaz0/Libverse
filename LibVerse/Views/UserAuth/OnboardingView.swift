import SwiftUI

enum GenreType: String, CaseIterable {
    case technology = "Technology"
    case business = "Business"
    case reference = "Reference"
    case medicine = "Medicine"
    case mathematics = "Mathematics"
    case law = "Law"
    case science = "Science"
    
    var icon: String {
        switch self {
        case .technology: return "desktopcomputer"
        case .business: return "briefcase"
        case .reference: return "books.vertical"
        case .medicine: return "heart.text.square"
        case .mathematics: return "function"
        case .law: return "building.columns"
        case .science: return "atom"
        }
    }
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var showMainApp: Bool
    @Binding var showUserInitialView: Bool
    @State private var selectedGenres: Set<GenreType> = []
    
    init(hasCompletedOnboarding: Binding<Bool>, showMainApp: Binding<Bool> = .constant(false), showUserInitialView: Binding<Bool> = .constant(true)) {
        self._hasCompletedOnboarding = hasCompletedOnboarding
        self._showMainApp = showMainApp
        self._showUserInitialView = showUserInitialView
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Tell us what you like to read")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Select at least one genre to help us personalize your recommendations")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Genres grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                            ForEach(GenreType.allCases, id: \.self) { genre in
                                genreSelectionButton(for: genre)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                hasCompletedOnboarding = true
                                showMainApp = true
                                showUserInitialView = false
                            }
                        }) {
                            Text("Continue")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(!selectedGenres.isEmpty ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(selectedGenres.isEmpty)
                        .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                hasCompletedOnboarding = true
                                showMainApp = true
                                showUserInitialView = false
                            }
                        }) {
                            Text("Skip for now")
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                        }
                        .padding(.bottom)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func genreSelectionButton(for genre: GenreType) -> some View {
        let isSelected = selectedGenres.contains(genre)
        
        return Button(action: {
            if isSelected {
                selectedGenres.remove(genre)
            } else {
                selectedGenres.insert(genre)
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: genre.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(red: 255/255, green: 111/255, blue: 45/255))
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(red: 255/255, green: 111/255, blue: 45/255), lineWidth: 1)
                    )
                
                Text(genre.rawValue)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .black)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(red: 255/255, green: 111/255, blue: 45/255).opacity(0.8) : Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color(red: 255/255, green: 111/255, blue: 45/255).opacity(0.3) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 
