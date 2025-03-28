import SwiftUI

// MARK: - Announcement Model
struct Announcement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let isNew: Bool
    let fullContent: String
}

// MARK: - AnnouncementView
struct AnnouncementView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Sample announcements data
    let announcements: [Announcement] = [
        Announcement(
            title: "New Books Added",
            description: "Check out the latest additions to our library collection.",
            date: Date().addingTimeInterval(-86400),
            isNew: true,
            fullContent: "We're excited to announce several new additions to our library collection. The new titles include bestsellers in fiction, non-fiction, and academic resources. All new books are available for borrowing immediately.\n\nFeatured new additions:\n• The Silent Patient by Alex Michaelides\n• Atomic Habits by James Clear\n• The Psychology of Money by Morgan Housel\n• Project Hail Mary by Andy Weir\n\nVisit the library or browse our digital collection to discover these and other new titles."
        ),
        Announcement(
            title: "Library Hours Update",
            description: "The library will now be open from 9 AM to 8 PM on weekdays and 10 AM to 6 PM on weekends.",
            date: Date().addingTimeInterval(-259200),
            isNew: false,
            fullContent: "Please note our updated library hours effective immediately:\n\nWeekdays (Monday-Friday):\n9:00 AM - 8:00 PM\n\nWeekends (Saturday-Sunday):\n10:00 AM - 6:00 PM\n\nThe extended weekday hours are in response to student feedback requesting longer evening access. We hope these new hours better accommodate your study and research needs. The digital library resources remain available 24/7 through our website and mobile app."
        ),
        Announcement(
            title: "Special Author Event",
            description: "Join us for a meet and greet with bestselling author J.K. Rowling next Friday at 5 PM.",
            date: Date().addingTimeInterval(-432000),
            isNew: false,
            fullContent: "We're thrilled to announce a special author event featuring J.K. Rowling, the bestselling author of the Harry Potter series.\n\nDate: Friday, June 15\nTime: 5:00 PM - 7:00 PM\nLocation: Main Library Auditorium\n\nThe event will include a reading from the author's latest work, a Q&A session, and a book signing opportunity. Attendance is free but space is limited. Reserve your spot through the Events section of our app or website.\n\nBooks will be available for purchase at the event, or you may bring your own copies for signing (limit of 2 books per person)."
        ),
        Announcement(
            title: "System Maintenance",
            description: "The LibVerse app will be undergoing maintenance on Sunday night. Service may be disrupted for 1-2 hours.",
            date: Date().addingTimeInterval(-604800),
            isNew: false,
            fullContent: "Important Notice: System Maintenance\n\nThe LibVerse app and website will be undergoing scheduled maintenance this Sunday from 11:00 PM to 1:00 AM.\n\nDuring this time, you may experience temporary disruptions in service, including:\n• Inability to log in\n• Search function limitations\n• Book checkout delays\n\nThis maintenance is necessary to implement security updates and performance improvements. We apologize for any inconvenience and appreciate your patience.\n\nIf you need to access library resources during this time, we recommend downloading materials in advance."
        )
    ]
    
    var body: some View {
        List {
            ForEach(announcements) { announcement in
                NavigationLink(destination: AnnouncementDetailView(announcement: announcement)) {
                    AnnouncementRow(announcement: announcement)
                }
                .listRowBackground(Color(red: 255/255, green: 239/255, blue: 210/255))
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
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
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
            
            Text(announcement.description)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Text(dateFormatter.string(from: announcement.date))
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
                    
                    Text(dateFormatter.string(from: announcement.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Divider
                Rectangle()
                    .fill(Color(red: 255/255, green: 111/255, blue: 45/255))
                    .frame(height: 2)
                
                // Full content
                Text(announcement.fullContent)
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
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
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