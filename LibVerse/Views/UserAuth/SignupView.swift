import SwiftUI
import Supabase

struct SignUpView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var enrollmentNumber: String = ""
    @State private var collegeName: String = ""
    @State private var collegeEmail: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var navigateToOTP: Bool = false

    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !enrollmentNumber.isEmpty &&
        !collegeName.isEmpty &&
        !collegeEmail.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        collegeEmail.hasSuffix("@gmail.com") &&
        password.count >= 6
    }

    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                Spacer()
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Text("Create an account")
                            .font(.custom("Courier New", size: 25))
                            .bold()
                            .frame(width: 287, alignment: .center)
                        
                        Text("Join first to access the feature of Libverse")
                            .font(.custom("Courier", size: 16))
                            .frame(width: 350)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    Group {
                        HStack(spacing: 15) {
                            customTextField(placeholder: "First Name", text: $firstName)
                            customTextField(placeholder: "Last Name", text: $lastName)
                        }
                        
                        customTextField(placeholder: "Enrollment Number", text: $enrollmentNumber, keyboardType: .numberPad)
                        customTextField(placeholder: "College Name", text: $collegeName)
                        customTextField(placeholder: "College Email", text: $collegeEmail, keyboardType: .emailAddress, autocapitalization: .none)
                        customSecureField(placeholder: "Password", text: $password)
                        customSecureField(placeholder: "Confirm Password", text: $confirmPassword)
                    }
                    
                    Spacer()
                    
                    Button(action: signUp) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                        } else {
                            Text("Sign Up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color(red: 255/255, green: 111/255, blue: 45/255) : Color.gray)
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(!isFormValid || isLoading)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    NavigationLink(destination: LogInView().navigationBarBackButtonHidden(true)) {
                        Text("Already a user? Sign In")
                            .font(.custom("Courier", size: 16))
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
            Spacer()
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
        .navigationDestination(isPresented: $navigateToOTP) {
            OTPVerificationView(email: collegeEmail, password: password)
        }
    }

    // Rest of the file remains the same
    private func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, autocapitalization: UITextAutocapitalizationType = .words) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
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
    
    private func customSecureField(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("Courier", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 10)
            }
            SecureField("", text: text)
                .padding()
                .frame(height: 43)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.black, lineWidth: 1.25)
                )
        }
    }
    
    private func signUp() {
        isLoading = true
        Task {
            do {
                let authResponse = try await supabaseManager.signUp(email: collegeEmail, password: password)
                
                DispatchQueue.main.async {
                    isLoading = false
                    if authResponse.user != nil {
                        navigateToOTP = true
                    } else {
                        alertMessage = "An error occurred during signup."
                        showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    alertMessage = "Error signing up: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
