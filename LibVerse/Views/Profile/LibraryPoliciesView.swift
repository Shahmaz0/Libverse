//
//  LibraryPoliciesView.swift
//  LibVerse
//
//  Created by ARYAN SINGHAL on 02/04/25.
//


import SwiftUI

struct PolicyResponse: Decodable {
     let borrowing_limit: Int
     let return_period: Int
     let fine_amount: Int
     let lost_book_fine: Int
 }

struct LibraryPoliciesView: View {
    @State private var policyData: PolicyResponse?
    @State private var isLoading = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if let policy = policyData {
                    PolicyCard(title: "Borrowing Limit", value: "\(policy.borrowing_limit) books", icon: "book.fill")
                    PolicyCard(title: "Return Period", value: "\(policy.return_period) days", icon: "calendar")
                    PolicyCard(title: "Fine Amount", value: "₹\(policy.fine_amount)", icon: "indianrupeesign.circle.fill")
                    PolicyCard(title: "Lost Book Fine", value: "₹\(policy.lost_book_fine)", icon: "exclamationmark.triangle.fill")
                }
            }
            .padding()
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .navigationTitle("Library Policies")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchPolicyData()
        }
    }
    
    private func fetchPolicyData() async {
        isLoading = true
        error = nil
        
        do {
            let policy: PolicyResponse = try await SupabaseManager.shared.client
                .from("library_policies")
                .select()
                .single()
                .execute()
                .value
            
            await MainActor.run {
                self.policyData = policy
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load policy data: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

struct PolicyCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .bold()
            }
            
            Spacer()
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
    }
}

#Preview {
    NavigationView {
        LibraryPoliciesView()
    }
} 
