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
       let issueStatus: IssueStatus
       let issueDate: Date
       let returnDate: Date
       let actualReturnDate: Date?
       let overdueDays: Int?
       
       enum CodingKeys: String, CodingKey {
           case id
           case bookId
           case memberId
           case issueStatus = "status"
           case issueDate
           case returnDate
           case actualReturnDate
           case overdueDays
       }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let dateFormatter = ISO8601DateFormatter()
            
            id = try container.decode(UUID.self, forKey: .id)
            bookId = try container.decode(UUID.self, forKey: .bookId)
            memberId = try container.decode(UUID.self, forKey: .memberId)
            issueStatus = try container.decode(IssueStatus.self, forKey: .issueStatus)
            
            if let issueDateString = try container.decodeIfPresent(String.self, forKey: .issueDate) {
                issueDate = dateFormatter.date(from: issueDateString) ?? Date()
            } else {
                issueDate = Date()
            }
            
            if let returnDateString = try container.decodeIfPresent(String.self, forKey: .returnDate) {
                returnDate = dateFormatter.date(from: returnDateString) ?? Date()
            } else {
                returnDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            }
            
            if let actualReturnDateString = try container.decodeIfPresent(String.self, forKey: .actualReturnDate) {
                actualReturnDate = dateFormatter.date(from: actualReturnDateString)
            } else {
                actualReturnDate = nil
            }
            
            overdueDays = try container.decodeIfPresent(Int.self, forKey: .overdueDays)
        }
        
        init(bookId: UUID, memberId: UUID) {
            self.id = UUID()
            self.bookId = bookId
            self.memberId = memberId
            self.issueStatus = .pending
            self.issueDate = Date()
            self.returnDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            self.actualReturnDate = nil
            self.overdueDays = nil
        }
        
        init(id: UUID, bookId: UUID, memberId: UUID, issueStatus: IssueStatus, issueDate: Date, returnDate: Date, actualReturnDate: Date?, overdueDays: Int?) {
            self.id = id
            self.bookId = bookId
            self.memberId = memberId
            self.issueStatus = issueStatus
            self.issueDate = issueDate
            self.returnDate = returnDate
            self.actualReturnDate = actualReturnDate
            self.overdueDays = overdueDays
        }
        
        func calculateOverdueDays() -> Int {
            guard issueStatus == .overdue else { return 0 }
            return Calendar.current.dateComponents([.day], from: returnDate, to: Date()).day ?? 0
        }
        
        func updateStatus() -> BookIssue {
            var updatedIssue = self
            
            switch issueStatus {
            case .pending:
                updatedIssue = BookIssue(
                    id: id,
                    bookId: bookId,
                    memberId: memberId,
                    issueStatus: .issued,
                    issueDate: issueDate,
                    returnDate: returnDate,
                    actualReturnDate: nil,
                    overdueDays: nil
                )
                
            case .issued:
                if Date() > returnDate {
                    updatedIssue = BookIssue(
                        id: id,
                        bookId: bookId,
                        memberId: memberId,
                        issueStatus: .overdue,
                        issueDate: issueDate,
                        returnDate: returnDate,
                        actualReturnDate: nil,
                        overdueDays: calculateOverdueDays()
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
                    actualReturnDate: nil,
                    overdueDays: calculateOverdueDays()
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
                actualReturnDate: Date(),
                overdueDays: nil
            )
        }
    }
