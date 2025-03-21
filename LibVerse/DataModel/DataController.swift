//import Foundation
//import Combine
//import Supabase
//
//class MemberTableManager {
//    static let shared = MemberTableManager()
//    private let supabase = SupabaseManager.shared
//    
//    private init() {}
//    
//    // Fetch current member
//    func fetchCurrentMember() async -> Member? {
//        do {
//            guard let session = try? await supabase.client.auth.session else {
//                print("No active session found")
//                return nil
//            }
//            
//            let userId = session.user.id
//            let response: PostgrestResponse<[Member]> = try await supabase.client
//                .database
//                .from("members")
//                .select()
//                .eq("id", value: userId)
//                .execute()
//            
//            return response.value.first
//        } catch {
//            print("Error fetching member: \(error.localizedDescription)")
//            return nil
//        }
//    }
//    
//    // Add new member
//    func addMember(
//        firstName: String,
//        lastName: String,
//        enrollmentNumber: String,
//        collegeName: String,
//        collegeEmail: String,
//        password: String
//    ) async throws {
//        let member = Member(
//            id: UUID(),
//            firstName: firstName,
//            lastName: lastName,
//            enrollmentNumber: enrollmentNumber,
//            collegeName: collegeName,
//            collegeEmail: collegeEmail,
//            password: password,
//            createdAt: Date()
//        )
//        
//        let _: PostgrestResponse<Empty> = try await supabase.client
//            .database
//            .from("members")
//            .insert(member)
//            .execute()
//    }
//    
//    // Update member
//    func updateMember(_ member: Member) async throws {
//        let _: PostgrestResponse<Empty> = try await supabase.client
//            .database
//            .from("members")
//            .update(member)
//            .eq("id", value: member.id)
//            .execute()
//    }
//    
//    // Delete member
//    func deleteMember(id: UUID) async throws {
//        let _: PostgrestResponse<Empty> = try await supabase.client
//            .database
//            .from("members")
//            .delete()
//            .eq("id", value: id)
//            .execute()
//    }
//    
//    // Fetch all members except current
//    func fetchMembers() async -> [Member] {
//        do {
//            guard let session = try? await supabase.client.auth.session else {
//                print("No active session found")
//                return []
//            }
//            
//            let currentUserId = session.user.id
//            let response: PostgrestResponse<[Member]> = try await supabase.client
//                .database
//                .from("members")
//                .select()
//                .neq("id", value: currentUserId)
//                .execute()
//            
//            return response.value
//        } catch {
//            print("Error fetching members: \(error.localizedDescription)")
//            return []
//        }
//    }
//}
