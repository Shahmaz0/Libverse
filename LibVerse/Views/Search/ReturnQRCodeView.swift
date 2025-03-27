import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct ReturnQRCodeView: View {
    let issueId: UUID
    @Environment(\.presentationMode) var presentationMode
    @State private var qrCode: UIImage?
    @State private var checkStatusTimer: Timer?
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                .padding()
                
                Spacer()
                
                Text("Return QR Code")
                    .font(.custom("Charter", size: 20))
                    .bold()
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            
            if let qrCode = qrCode {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            
            Text("Please show this QR code to the librarian")
                .font(.custom("Charter", size: 16))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .onAppear {
            generateQRCode()
            startCheckingStatus()
        }
        .onDisappear {
            stopCheckingStatus()
        }
    }
    
    private func startCheckingStatus() {
        // Check every 2 seconds for return status
        checkStatusTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task {
                await checkReturnStatus()
            }
        }
    }
    
    private func stopCheckingStatus() {
        checkStatusTimer?.invalidate()
        checkStatusTimer = nil
    }
    
    private func checkReturnStatus() async {
        do {
            let query = supabaseManager.client
                .from("BookIssue")
                .select()
                .eq("id", value: issueId)
            
            let response: [BookIssue] = try await query.execute().value
            if let issue = response.first, issue.issueStatus == .returned {
                // Book has been returned, close the view
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
                stopCheckingStatus()
            }
        } catch {
            print("Error checking return status: \(error)")
        }
    }
    
    private func generateQRCode() {
        // Create the return data structure
        let returnData = ReturnData(
            issueId: issueId,
            action: "return",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        // Convert to JSON string
        guard let jsonData = try? JSONEncoder().encode(returnData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Failed to encode return data")
            return
        }
        
        // Generate QR code
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(jsonString.data(using: .utf8), forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else {
            print("Failed to generate QR code image")
            return
        }
        
        let scaledImage = outputImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            print("Failed to create CGImage from QR code")
            return
        }
        
        qrCode = UIImage(cgImage: cgImage)
    }
}

// Data structure for the QR code
struct ReturnData: Codable {
    let issueId: UUID
    let action: String
    let timestamp: String
}

#Preview {
    ReturnQRCodeView(issueId: UUID())
        .environmentObject(SupabaseManager.shared)
} 