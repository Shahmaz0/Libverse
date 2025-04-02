import SwiftUI

enum GenreType: String, CaseIterable {
    case technology = "Technology"
    case business = "Business"
    case reference = "Reference"
    case medicine = "Medicine"
    case mathematics = "Mathematics"
    case law = "Law"
    case science = "Science"
}

struct OnboardingView: View {
    @State private var selectedGenres: Set<GenreType> = []
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to LibVerse!")
                .font(.largeTitle)
                .bold()
            
            Text("Select your favorite genres")
                .font(.title2)
                .foregroundColor(.gray)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(GenreType.allCases, id: \.self) { genre in
                        GenreSelectionRow(genre: genre, isSelected: selectedGenres.contains(genre)) {
                            if selectedGenres.contains(genre) {
                                selectedGenres.remove(genre)
                            } else {
                                selectedGenres.insert(genre)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Button(action: {
                // Save preferences here if needed
                hasCompletedOnboarding = true
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedGenres.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(selectedGenres.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}

struct GenreSelectionRow: View {
    let genre: GenreType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(genre.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 