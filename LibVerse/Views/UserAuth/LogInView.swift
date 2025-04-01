import SwiftUI
import Supabase

struct LogInView: View {
    @State private var collegeEmail: String = ""
    @State private var password: String = ""
    @State private var showForgotPasswordFlow = false
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showOTPView = false
    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var hasLoginError = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Image("Logo")
                            .resizable()
                            .frame(width: 160, height: 160)
                            .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                        
                        VStack(spacing: 15) {
                            Text("Get the most out of Pustakalaya")
                                .font(.custom("Courier New", size: 25))
                                .bold()
                                .multilineTextAlignment(.center)
                            
                            Text("Access your university's digital library and discover a vast collection of academic books, journals and novels.")
                                .font(.custom("Courier", size: 16))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Form Fields
                        Group {
                            if hasLoginError {
                                Text(errorMessage)
                                    .font(.custom("Courier", size: 14))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 5)
                            }
                            
                            customTextField(placeholder: "College Email", text: $collegeEmail, keyboardType: .emailAddress, autocapitalization: .none)
                            passwordField(placeholder: "Password", text: $password, isPasswordVisible: $isPasswordVisible)
                        }
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            NavigationLink(destination: ForgotPasswordEmailView()) {
                                Text("Forgot Password?")
                                    .font(.custom("Courier", size: 16))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        
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
                                    .border(.black)
                                    .cornerRadius(0)
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
            .navigationDestination(isPresented: $isAuthenticated) {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else {
                    TabBarView()
                }
            }
            .navigationDestination(isPresented: $showOTPView) {
                OTPVerificationView(email: collegeEmail, password: password)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, autocapitalization: UITextAutocapitalizationType = .words) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                TextField(placeholder, text: text)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.black)
                    .padding()
            }
            TextField("", text: text)
                .padding()
                .frame(height: 43)
                .keyboardType(keyboardType)
                .autocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(hasLoginError ? Color.red : Color.black, lineWidth: 1.25)
                )
                .shadow(color: hasLoginError ? Color.red.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
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
                            .stroke(hasLoginError ? Color.red : Color.black, lineWidth: 1.25)
                    )
                    .shadow(color: hasLoginError ? Color.red.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
            } else {
                SecureField(placeholder, text: text)
                    .padding()
                    .frame(height: 43)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(hasLoginError ? Color.red : Color.black, lineWidth: 1.25)
                    )
                    .shadow(color: hasLoginError ? Color.red.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
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
            errorMessage = "Please use your college email address (\(collegeDomain))."
            hasLoginError = true
            return
        }
        
        isLoading = true
        hasLoginError = false
        errorMessage = ""
        
        Task {
            do {
                // First verify the email and password format is valid
                guard !password.isEmpty, password.count >= 6 else {
                    DispatchQueue.main.async {
                        isLoading = false
                        errorMessage = "Password must be at least 6 characters."
                        hasLoginError = true
                    }
                    return
                }
                
                // First try to sign in with email and password
                let authResponse = try await SupabaseManager.shared.client.auth.signIn(
                    email: collegeEmail,
                    password: password
                )
                
                // If credentials are correct, proceed with OTP flow
                try await SupabaseManager.shared.client.auth.signInWithOTP(email: collegeEmail)
                
                UserDefaults.standard.set(collegeEmail, forKey: "pendingLoginEmail")
                UserDefaults.standard.set(password, forKey: "pendingLoginPassword")
                
                DispatchQueue.main.async {
                    isLoading = false
                    showOTPView = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    hasLoginError = true
                    if error.localizedDescription.contains("Invalid login credentials") {
                        errorMessage = "Invalid email or password. Please try again."
                    } else {
                        errorMessage = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

#Preview {
    LogInView()
}
