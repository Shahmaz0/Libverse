    import Foundation

    enum IssueStatus: String, Codable {
        case pending = "Pending"
        case issued = "Issued"
        case returned = "Returned"
        case overdue = "Overdue"
    }

    struct BookIssue: Codable, Identifiable {
       let id: UUID
       let bookId: UUID
       let memberId: UUID
       let issueDate: Date
       let dueDate: Date
       let returnDate: Date?
       let fine: Float
       let status: IssueStatus
       let isOverdue: Bool
       let isPaid: Bool
       let isLost: Bool
       
       enum CodingKeys: String, CodingKey {
           case id
           case bookId
           case memberId
           case issueDate
           case dueDate
           case returnDate
           case fine
           case status
           case isOverdue = "is_overdue"
           case isPaid = "is_paid"
           case isLost = "is_lost"
       }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"  // Format from Supabase date field
            
            let iso8601Formatter = ISO8601DateFormatter()
            
            id = try container.decode(UUID.self, forKey: .id)
            bookId = try container.decode(UUID.self, forKey: .bookId)
            memberId = try container.decode(UUID.self, forKey: .memberId)
            status = try container.decode(IssueStatus.self, forKey: .status)
            
            if let issueDateString = try container.decodeIfPresent(String.self, forKey: .issueDate) {
                issueDate = dateFormatter.date(from: issueDateString) ?? 
                           iso8601Formatter.date(from: issueDateString) ?? 
                           Date()
            } else {
                issueDate = Date()
            }
            
            if let dueDateString = try container.decodeIfPresent(String.self, forKey: .dueDate) {
                dueDate = dateFormatter.date(from: dueDateString) ?? 
                         iso8601Formatter.date(from: dueDateString) ?? 
                         Calendar.current.date(byAdding: .day, value: 7, to: issueDate) ?? 
                         Date()
            } else {
                dueDate = Calendar.current.date(byAdding: .day, value: 7, to: issueDate) ?? Date()
            }
            
            if let returnDateString = try container.decodeIfPresent(String.self, forKey: .returnDate) {
                returnDate = dateFormatter.date(from: returnDateString) ?? 
                           iso8601Formatter.date(from: returnDateString)
            } else {
                returnDate = nil
            }
            
            fine = try container.decode(Float.self, forKey: .fine)
            isOverdue = try container.decode(Bool.self, forKey: .isOverdue)
            isPaid = try container.decode(Bool.self, forKey: .isPaid)
            isLost = try container.decode(Bool.self, forKey: .isLost)
        }
        
        init(bookId: UUID, memberId: UUID) {
            self.id = UUID()
            self.bookId = bookId
            self.memberId = memberId
            self.status = .pending
            self.issueDate = Date()
            self.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            self.returnDate = nil
            self.fine = 0.0
            self.isOverdue = false
            self.isPaid = true
            self.isLost = false
        }
        
        init(id: UUID, bookId: UUID, memberId: UUID, issueStatus: IssueStatus, issueDate: Date, returnDate: Date?, overdueDays: Int?, isLost: Bool? = false) {
            self.id = id
            self.bookId = bookId
            self.memberId = memberId
            self.status = issueStatus
            self.issueDate = issueDate
            self.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: issueDate) ?? Date()
            self.returnDate = returnDate
            self.fine = 0.0
            self.isOverdue = false
            self.isPaid = true
            self.isLost = isLost ?? false
        }
        
        func calculateOverdueDays() -> Int {
            guard status == .overdue else { return 0 }
            return Calendar.current.dateComponents([.day], from: dueDate, to: Date()).day ?? 0
        }
        
        func updateStatus() -> BookIssue {
            var updatedIssue = self
            
            switch status {
            case .pending:
                updatedIssue = BookIssue(
                    id: id,
                    bookId: bookId,
                    memberId: memberId,
                    issueStatus: .issued,
                    issueDate: issueDate,
                    returnDate: returnDate,
                    overdueDays: nil,
                    isLost: isLost
                )
                
            case .issued:
                if Date() > dueDate {
                    updatedIssue = BookIssue(
                        id: id,
                        bookId: bookId,
                        memberId: memberId,
                        issueStatus: .overdue,
                        issueDate: issueDate,
                        returnDate: returnDate,
                        overdueDays: calculateOverdueDays(),
                        isLost: isLost
                    )
                }
                
            case .overdue:
                // Keep updating overdue days
                updatedIssue = BookIssue(
                    id: id,
                    bookId: bookId,
                    memberId: memberId,
                    issueStatus: .overdue,
                    issueDate: issueDate,
                    returnDate: returnDate,
                    overdueDays: calculateOverdueDays(),
                    isLost: isLost
                )
                
            case .returned:
                // Already returned, no changes needed
                break
            }
            
            return updatedIssue
        }
        
        func markAsReturned() -> BookIssue {
            return BookIssue(
                id: id,
                bookId: bookId,
                memberId: memberId,
                issueStatus: .returned,
                issueDate: issueDate,
                returnDate: returnDate,
                overdueDays: nil,
                isLost: isLost
            )
        }
    }
