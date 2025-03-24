import SwiftUI
import Supabase

struct LogInView: View {
    @State private var collegeEmail: String = ""
    @State private var password: String = ""
    @State private var showForgotPasswordFlow = false
    @State private var isLoggedIn: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showOTPView = false
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Image("Logo")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                        
                        VStack(spacing: 15) {
                            Text("Get the most out of Pustakalaya")
                                .font(.custom("Courier New", size: 25))
                                .bold()
                                .multilineTextAlignment(.center)
                            
                            Text("Access your university’s digital library and discover a vast collection of academic books, journals and novels.")
                                .font(.custom("Courier", size: 16))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Form Fields
                        Group {
                            customTextField(placeholder: "College Email", text: $collegeEmail, keyboardType: .emailAddress, autocapitalization: .none)
                            passwordField(placeholder: "Password", text: $password, isPasswordVisible: $isPasswordVisible)
                        }
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            Button(action: { showForgotPasswordFlow = true }) {
                                Text("Forgot Password?")
                                    .font(.custom("Courier", size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                        .sheet(isPresented: $showForgotPasswordFlow) {
                            ForgotPasswordEmailView()
                        }
                        
                        // Log In Button
                        Button(action: logIn) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                Text("Log In")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .disabled(isLoading)
                        
                        // Navigation to SignUpView
                        NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                            Text("New User? Sign Up")
                                .font(.custom("Courier", size: 16))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $isLoggedIn) {
                TabBarView()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showOTPView) {
                OTPVerificationView(email: collegeEmail , password: password)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, autocapitalization: UITextAutocapitalizationType = .words) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                TextField(placeholder, text: text)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
            }
            TextField("", text: text)
                .padding()
                .frame(height: 43)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1.25)
                )
        }
    }
    
    private func passwordField(placeholder: String, text: Binding<String>, isPasswordVisible: Binding<Bool>) -> some View {
        ZStack(alignment: .trailing) {
            if isPasswordVisible.wrappedValue {
                TextField(placeholder, text: text)
                    .padding()
                    .frame(height: 43)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 1.25)
                    )
            } else {
                SecureField(placeholder, text: text)
                    .padding()
                    .frame(height: 43)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 1.25)
                    )
            }
            Button(action: { isPasswordVisible.wrappedValue.toggle() }) {
                Image(systemName: isPasswordVisible.wrappedValue ? "eye" : "eye.slash")
                    .foregroundColor(.black)
                    .padding(.trailing, 10)
            }
        }
    }
    
    private func logIn() {
        let collegeDomain = "@gmail.com"
        guard collegeEmail.hasSuffix(collegeDomain) else {
            alertMessage = "Please use your college email address (\(collegeDomain))."
            showAlert = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // First verify the email and password format is valid
                guard !password.isEmpty, password.count >= 6 else {
                    DispatchQueue.main.async {
                        isLoading = false
                        alertMessage = "Password must be at least 6 characters."
                        showAlert = true
                    }
                    return
                }
                
                // Send OTP to email
                try await SupabaseManager.shared.client.auth.signInWithOTP(email: collegeEmail)
                
                // Store credentials for completing login after OTP verification
                UserDefaults.standard.set(collegeEmail, forKey: "pendingLoginEmail")
                UserDefaults.standard.set(password, forKey: "pendingLoginPassword")
                
                DispatchQueue.main.async {
                    isLoading = false
                    showOTPView = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Error sending verification code: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    LogInView()
}
