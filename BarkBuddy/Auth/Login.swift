import SwiftUI
import FirebaseCore
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo and App Name
                    VStack(spacing: 15) {
                        Image(systemName: "pawprint.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.blue)
                        
                        Text("BarkBuddy")
                            .font(.system(size: 36, weight: .bold))
                        
                        Text("Connect with dog walkers in your area")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                    
                    // Login Form
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button(action: handleLogin) {
                            if isLoggingIn {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(email.isEmpty || password.isEmpty || isLoggingIn)
                        .opacity((email.isEmpty || password.isEmpty || isLoggingIn) ? 0.6 : 1)
                        
                        Button("Forgot Password?") {
                            // Handle password reset
                            if !email.isEmpty {
                                sendPasswordReset()
                            } else {
                                alertMessage = "Please enter your email address"
                                showAlert = true
                            }
                        }
                        .font(.footnote)
                        .padding(.top, 5)
                    }
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        VStack { Divider() }.padding(.leading)
                        Text("OR")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        VStack { Divider() }.padding(.trailing)
                    }
                    
                    // Social Login Buttons
                    VStack(spacing: 15) {
                        Button(action: handleGoogleSignIn) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .foregroundColor(.red)
                                Text("Continue with Google")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Button(action: handleAppleSignIn) {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Continue with Apple")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Prompt
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func handleLogin() {
        isLoggingIn = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false
            
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            // Successfully logged in, navigate to main app view
            
        }
    }
    
    private func handleGoogleSignIn() {
        // Implement Google Sign In
        alertMessage = "Google Sign In will be implemented with Firebase Auth"
        showAlert = true
    }
    
    private func handleAppleSignIn() {
        // Implement Apple Sign In
        alertMessage = "Apple Sign In will be implemented with Firebase Auth"
        showAlert = true
    }
    
    private func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Password reset email sent to \(email)"
            }
            showAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
