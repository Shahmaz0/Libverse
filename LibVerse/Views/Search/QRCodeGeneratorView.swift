import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let book: Book
    let memberId: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var timeRemaining: TimeInterval = 300 // 5 minutes in seconds
    @State private var qrImage: UIImage?
    @State private var isExpired = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                
                Text("Issue QR Code")
                    .font(.custom("Charter", size: 20))
                    .bold()
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            
            Spacer()
            
            Text("Show this QR to Librarian")
                .font(.custom("Charter", size: 24))
                .foregroundColor(.black)
            
            if let qrImage = qrImage {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 290, height: 290)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(width: 280, height: 280)
                    
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .opacity(isExpired ? 0.3 : 1.0)
                    
                    if isExpired {
                        Text("EXPIRED")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
            
            VStack(spacing: 8) {
                Text("Time Remaining")
                    .font(.custom("Charter", size: 16))
                Text(formatTime(timeRemaining))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(timeRemaining < 60 ? .red : .black)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            VStack(spacing: 12) {
                Text(book.title)
                    .font(.custom("Charter", size: 18))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                
                Text("By: \(book.author.joined(separator: ", "))")
                    .font(.custom("Charter", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .onAppear {
            qrImage = generateQRCode()
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    isExpired = true
                    qrImage = generateQRCode()
                }
            }
        }
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func generateQRCode() -> UIImage {
        let expirationDate = Date().addingTimeInterval(5 * 60)
        
        // Create a new BookIssue instance
        let bookIssue = BookIssue(
            bookId: book.id,
            memberId: UUID(uuidString: memberId) ?? UUID()
        )
        
        // Convert BookIssue to JSON data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let qrData = """
        {
            "bookIssue": \(String(data: try! encoder.encode(bookIssue), encoding: .utf8)!),
            "expirationDate": "\(expirationDate.timeIntervalSince1970)",
            "timestamp": "\(Date().timeIntervalSince1970)",
            "isValid": \(!isExpired)
        }
        """
        
        let data = Data(qrData.utf8)
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // Using high error correction for logo overlay
        
        if let outputImage = filter.outputImage {
            // Scale up the QR code to desired size
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQRImage = outputImage.transformed(by: transform)
            
            if let qrCGImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) {
                let size = CGSize(width: qrCGImage.width, height: qrCGImage.height)
                UIGraphicsBeginImageContextWithOptions(size, false, 0)
                
                let qrUIImage = UIImage(cgImage: qrCGImage)
                qrUIImage.draw(in: CGRect(origin: .zero, size: size))
                
                // Add logo in center
                if let logoImage = UIImage(named: "QRlogo") {
                    let logoSize = CGSize(width: size.width * 0.25, height: size.height * 0.25)
                    let logoX = (size.width - logoSize.width) / 2
                    let logoY = (size.height - logoSize.height) / 2
                    let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
                    
                    // Create circular mask for logo
                    UIGraphicsBeginImageContextWithOptions(logoSize, false, 0)
                    let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: logoSize))
                    circlePath.addClip()
                    
                    // Draw logo with white background
                    UIColor.white.setFill()
                    UIBezierPath(rect: CGRect(origin: .zero, size: logoSize)).fill()
                    logoImage.draw(in: CGRect(origin: .zero, size: logoSize))
                    
                    let circularLogo = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    // Draw circular logo on QR code
                    circularLogo?.draw(in: logoRect)
                }
                
                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return finalImage ?? UIImage(systemName: "xmark.circle") ?? UIImage()
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
} 

