import SwiftUI
import Supabase

// MARK: - AnnouncementView
struct AnnouncementView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var announcements: [Announcement] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(red: 255/255, green: 111/255, blue: 45/255))
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                        .padding()
                    
                    Text("Error loading announcements")
                        .font(.headline)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Try Again") {
                        fetchAnnouncements()
                    }
                    .padding()
                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            } else if announcements.isEmpty {
                VStack {
                    Image(systemName: "megaphone")
                        .font(.system(size: 50))
                        .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                        .padding()
                    
                    Text("No announcements available")
                        .font(.headline)
                }
            } else {
                List {
                    ForEach(announcements.filter { $0.is_active && !$0.is_archived }) { announcement in
                        NavigationLink(destination: AnnouncementDetailView(announcement: announcement)) {
                            AnnouncementRow(announcement: announcement)
                        }
                        .listRowBackground(Color(red: 255/255, green: 239/255, blue: 210/255))
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Announcements")
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
        .onAppear {
            fetchAnnouncements()
        }
    }
    
    private func fetchAnnouncements() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response: [Announcement] = try await SupabaseManager.shared.client
                    .from("announcements")
                    .select()
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.announcements = response
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("Error fetching announcements: \(error)")
                }
            }
        }
    }
}

// MARK: - Announcement Row
struct AnnouncementRow: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(announcement.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                if announcement.isNew {
                    Text("NEW")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                        .cornerRadius(4)
                }
            }
            
            Text(announcement.content)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Text(dateFormatter.string(from: announcement.created_at))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// MARK: - Announcement Detail View
struct AnnouncementDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let announcement: Announcement
    @State private var hasMarkedAsViewed = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with title and date
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(announcement.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if !hasMarkedAsViewed && announcement.isNew {
                            Text("NEW")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(dateFormatter.string(from: announcement.created_at))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Divider
                Rectangle()
                    .fill(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .frame(height: 2)
                
                // Metadata row
                HStack {
//                    Label("Type: \(announcement.type)", systemImage: "tag")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Spacer()
                    
                    if let expiryDate = announcement.expiry_date {
                        Label("Expires: \(shortDateFormatter.string(from: expiryDate))", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                // Full content
                Text(announcement.content)
                    .font(.body)
                    .foregroundColor(.black)
                    .lineSpacing(6)
            }
            .padding()
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
        .navigationTitle("Announcement Details")
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
        .onAppear {
            if !hasMarkedAsViewed {
                announcement.markAsViewed()
                hasMarkedAsViewed = true
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
    
    private var shortDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        AnnouncementView()
    }
} 
