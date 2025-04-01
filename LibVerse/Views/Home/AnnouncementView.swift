import SwiftUI
import Supabase

// MARK: - Announcement Manager
class AnnouncementManager: ObservableObject {
    static let shared = AnnouncementManager()
    
    @Published var unreadCount: Int = 0
    @Published var announcements: [Announcement] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    // Constants for announcement types
    private let typeAll = "All"
    private let typeMember = "Member"
    
    private init() {
        // Set up NotificationCenter observer for app becoming active
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAnnouncements), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Clear viewed announcements when user logs out
        NotificationCenter.default.addObserver(self, selector: #selector(clearViewedAnnouncements), name: NSNotification.Name("UserDidLogout"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clearViewedAnnouncements() {
        // Clear all viewed announcements from UserDefaults
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }
    
    @objc func refreshAnnouncements() {
        fetchAnnouncements()
    }
    
    func fetchAnnouncements() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let response: [Announcement] = try await SupabaseManager.shared.client
                    .from("announcements")
                    .select()
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    // Show all announcements that are either "All" or "Member" type
                    self.announcements = response.filter { announcement in
                        let type = announcement.type.lowercased()
                        return type == self.typeAll.lowercased() || type == self.typeMember.lowercased()
                    }
                    
                    // Calculate unread count
                    self.calculateUnreadCount()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    print("Error fetching announcements: \(error)")
                }
            }
        }
    }
    
    func calculateUnreadCount() {
        let newCount = announcements.filter { $0.is_active && !$0.is_archived && !isAnnouncementViewed($0) }.count
        DispatchQueue.main.async {
            self.unreadCount = newCount
        }
    }
    
    func markAnnouncementAsRead(_ announcement: Announcement) {
        if let index = announcements.firstIndex(where: { $0.id == announcement.id }) {
            UserDefaults.standard.set(true, forKey: "announcement_viewed_\(announcement.id.uuidString)")
            calculateUnreadCount()
        }
    }
    
    func isAnnouncementViewed(_ announcement: Announcement) -> Bool {
        return UserDefaults.standard.bool(forKey: "announcement_viewed_\(announcement.id.uuidString)")
    }
}

// MARK: - Announcement Model
struct Announcement: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let type: String
    let expiry_date: Date?
    let created_at: Date
    let is_active: Bool
    let is_archived: Bool
    let last_modified: Date?
    let start_date: Date?
    
    // Computed properties to maintain compatibility with existing UI
    var description: String {
        return content
    }
    
    var date: Date {
        return created_at
    }
    
    var isNew: Bool {
        // Consider an announcement new if it hasn't been viewed
        return !AnnouncementManager.shared.isAnnouncementViewed(self)
    }
    
    var fullContent: String {
        return content
    }
}

// MARK: - AnnouncementView
struct AnnouncementView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var announcementManager = AnnouncementManager.shared
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all)
            
            if announcementManager.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(red: 255/255, green: 111/255, blue: 45/255))
            } else if let error = announcementManager.error {
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
                        announcementManager.fetchAnnouncements()
                    }
                    .padding()
                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            } else if announcementManager.announcements.isEmpty {
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
                    ForEach(announcementManager.announcements.filter { $0.is_active && !$0.is_archived }) { announcement in
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
            // Fetch announcements when view appears
            announcementManager.fetchAnnouncements()
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
    @ObservedObject private var announcementManager = AnnouncementManager.shared
    
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
                    Label("Type: \(announcement.type)", systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
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
            if !hasMarkedAsViewed && announcement.isNew {
                hasMarkedAsViewed = true
                announcementManager.markAnnouncementAsRead(announcement)
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