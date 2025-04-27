import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isRegistering = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userType: UserType = .dogOwner
    @State private var navigateToProfile = false
    @State private var userId: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Join BarkBuddy today")
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                
                // User Type Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("I am a:")
                        .font(.headline)
                        .padding(.leading, 2)
                    
                    Picker("User Type", selection: $userType) {
                        ForEach(UserType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Registration Form
                VStack(spacing: 15) {
                    // First Name and Last Name in a row
                    HStack(spacing: 10) {
                        TextField("First Name", text: $firstName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
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
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    // Registration button
                    Button(action: handleSignUp) {
                        if isRegistering {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isFormIncomplete || isRegistering)
                    .opacity((isFormIncomplete || isRegistering) ? 0.6 : 1)
                }
                .padding(.horizontal)
                
                // Terms and Conditions
                Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Back to Login
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Login")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                if userType == .dogOwner {
                    UserProfile(userId: userId)
                } else {
                    WalkerProfile(userId: userId)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var isFormIncomplete: Bool {
        return firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
    }
    
    private func handleSignUp() {
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }
        
        isRegistering = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isRegistering = false
            
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            // Update user profile with full name
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = "\(firstName) \(lastName)"
            changeRequest?.commitChanges { error in
                if let error = error {
                    print("Error updating user profile: \(error.localizedDescription)")
                }
            }
            
            // Store additional user info in Firestore based on user type
            if let uid = result?.user.uid {
                let db = Firestore.firestore()
                
                // Determine collection based on user type
                let collection = userType == .dogOwner ? "users" : "walkers"
                
                db.collection(collection).document(uid).setData([
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "userType": userType.rawValue,
                    "profileComplete": false,
                    "createdAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("Error writing user data to Firestore: \(error.localizedDescription)")
                    }
                }
                
                // Store user ID for profile setup
                userId = uid
                
                // Navigate to profile setup
                navigateToProfile = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
