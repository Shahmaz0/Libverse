import SwiftUI

struct OTPVerificationView: View {
    let email: String
    let password: String
    
    @State private var otpFields: [String] = Array(repeating: "", count: 6)
    @FocusState private var fieldFocus: Int?
    @State private var errorMessage: String?
    @State private var navigateToHome = false
    @State private var isForgetPasswordFlow = false
    @State private var showSuccessMessage = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var timeRemaining = 60
    @State private var timer: Timer?
    @State private var isResendEnabled = false
    @Environment(\.dismiss) private var dismiss
        
    var otp: String {
        otpFields.joined()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Text("Email Verification")
                                .font(.custom("Courier New", size: 25))
                                .bold()
                                .frame(width: 287, alignment: .center)
                            
                            Text("Enter the code sent to")
                                .font(.custom("Courier", size: 16))
                            
                            Text(email)
                                .font(.custom("Courier", size: 16))
                                .bold()
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                ZStack {
                                    TextField("", text: $otpFields[index], onEditingChanged: { editing in
                                        if editing {
                                            otpFields[index] = ""
                                        }
                                    })
                                    .textFieldStyle(.plain)
                                    .frame(width: 43, height: 43)
                                    .multilineTextAlignment(.center)
                                    .keyboardType(.numberPad)
                                    .focused($fieldFocus, equals: index)
                                    .onChange(of: otpFields[index]) { newValue in
                                        if newValue.count >= 1 {
                                            otpFields[index] = String(newValue.prefix(1))
                                            if index < 5 {
                                                fieldFocus = index + 1
                                            } else {
                                                fieldFocus = nil
                                            }
                                        }
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black, lineWidth: 1.25)
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: verifyOTP) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                            } else {
                                Text("Verify")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(otp.count == 6 ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray)
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(otp.count != 6 || isLoading)
                        .padding(.horizontal)
                        
                        Button(action: resendCode) {
                            if timeRemaining > 0 {
                                Text("Resend Code in \(timeRemaining)s")
                                    .font(.custom("Courier", size: 16))
                                    .foregroundColor(.gray)
                            } else {
                                Text("Resend Code")
                                    .font(.custom("Courier", size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                        .disabled(timeRemaining > 0 || isLoading)
                    }
                    .padding()
                }
                Spacer()
            }
            .overlay {
                if showSuccessMessage {
                    Text("OTP Verified Successfully!")
                        .font(.custom("Courier", size: 18))
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .alert("Verification", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage == "Email verified successfully!" {
                        navigateToHome = true
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .navigationDestination(isPresented: $navigateToHome) {
                TabBarView()
                    .navigationBarBackButtonHidden(true)
            }
            .onAppear {
                fieldFocus = 0
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    private func verifyOTP() {
        isLoading = true
        errorMessage = nil
        
        // Check if this is for forgot password flow
        isForgetPasswordFlow = UserDefaults.standard.string(forKey: "resetEmail") != nil
        
        Task {
            do {
                if isForgetPasswordFlow {
                    // For forgot password flow
                    try await SupabaseManager.shared.verifyOTP(email: email, otp: otp) { result in
                        DispatchQueue.main.async {
                            isLoading = false
                            switch result {
                            case .success:
                                withAnimation {
                                    showSuccessMessage = true
                                }
                                navigateToHome = true
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                alertMessage = "Error: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }
                } else if UserDefaults.standard.string(forKey: "pendingLoginEmail") != nil {
                    // For login flow
                    _ = try await SupabaseManager.shared.verifyLoginOTP(email: email, otp: otp)
                    
                    DispatchQueue.main.async {
                        isLoading = false
                        withAnimation {
                            showSuccessMessage = true
                        }
                        navigateToHome = true
                    }
                } else {
                    // For signup flow
                    SupabaseManager.shared.verifyOTP(email: email, otp: otp) { result in
                        DispatchQueue.main.async {
                            isLoading = false
                            switch result {
                            case .success:
                                withAnimation {
                                    showSuccessMessage = true
                                }
                                navigateToHome = true
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                alertMessage = "Error: \(error.localizedDescription)"
                                showAlert = true
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func startTimer() {
        timeRemaining = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isResendEnabled = true
                }
            }
        }
    }
    
    private func resendCode() {
        isLoading = true
        isResendEnabled = false
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signInWithOTP(email: email)
                
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "New verification code has been sent to your email"
                    showAlert = true
                    startTimer()
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    isResendEnabled = true
                    alertMessage = "Error sending new code: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

