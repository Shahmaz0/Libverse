import Foundation

struct UserProfile {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    let department: String
    let enrollmentNumber: String
    let fines: Double
    let borrowedBooks: [BorrowedBook]
}

struct BorrowedBook: Identifiable {
    let id: String
    let title: String
    let author: String
    let dueDate: Date
    let daysRemaining: Int
    
    var isOverdue: Bool {
        daysRemaining < 0
    }
}

// Mock data for testing
extension UserProfile {
    static let mockProfile = UserProfile(
        userId: "USR123456",
        firstName: "Adnaan",
        lastName: "Ahmad",
        email: "adnaanahmad28@gmail.com",
        department: "Computer Science",
        enrollmentNumber: "2213110944",
        fines: 25.0,
        borrowedBooks: [
            BorrowedBook(
                id: "BK001",
                title: "The Great Gatsby",
                author: "F. Scott Fitzgerald",
                dueDate: Date().addingTimeInterval(5 * 24 * 60 * 60), // 5 days from now
                daysRemaining: 5
            ),
            BorrowedBook(
                id: "BK002",
                title: "1984",
                author: "George Orwell",
                dueDate: Date().addingTimeInterval(-2 * 24 * 60 * 60), // 2 days overdue
                daysRemaining: -2
            ),
            BorrowedBook(
                id: "BK003",
                title: "To Kill a Mockingbird",
                author: "Harper Lee",
                dueDate: Date().addingTimeInterval(10 * 24 * 60 * 60), // 10 days from now
                daysRemaining: 10
            )
        ]
    )
} 
