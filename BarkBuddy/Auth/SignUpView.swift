import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore // Make sure you import Firestore

// UserType Enum (ensure case name matches usage elsewhere)
enum UserType: String, CaseIterable, Identifiable {
    case dogOwner = "Dog Owner"
    case dogWalker = "Dog Walker" // Renamed from dogWalker

    var id: String { rawValue }
}

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
    @State private var navigateToProfile = false // Single navigation trigger
    @State private var userId: String = ""
    @State private var navigateToHome: Bool = false

    // Computed property to check form validity
    private var isFormInvalid: Bool {
        firstName.isEmpty
            || lastName.isEmpty
            || email.isEmpty // Basic email format check could be added
            || password.isEmpty
            || password != confirmPassword
    }

    var body: some View {
        // NavigationStack should ideally be outside this view,
        // but if it must be here, destinations go inside.
        NavigationStack {
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

                    // User Type Picker
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
                        HStack(spacing: 10) {
                            TextField("First Name", text: $firstName)
                                .padding().background(Color(.systemGray6)).cornerRadius(10)
                            TextField("Last Name", text: $lastName)
                                .padding().background(Color(.systemGray6)).cornerRadius(10)
                        }
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress).autocapitalization(.none)
                            .padding().background(Color(.systemGray6)).cornerRadius(10)
                        SecureField("Password", text: $password)
                            .padding().background(Color(.systemGray6)).cornerRadius(10)
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding().background(Color(.systemGray6)).cornerRadius(10)

                        // --- Registration Button ---
                        Button(action: handleSignUp) {
                            if isRegistering {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up").fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.blue).foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isFormInvalid || isRegistering) // Use isFormInvalid
                        .opacity((isFormInvalid || isRegistering) ? 0.6 : 1)
                    }
                    .padding(.horizontal)

                    Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption).foregroundColor(.gray)
                        .multilineTextAlignment(.center).padding(.horizontal)

                    // Back Button
                    Button(action: { dismiss() }) {
                        HStack { Image(systemName: "arrow.left"); Text("Back to Login") }
                    }
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal) // Add horizontal padding to the VStack content
            }
            // --- Attach navigationDestination HERE (inside NavigationStack) ---
            .navigationDestination(isPresented: $navigateToProfile) {
                // Conditionally choose the destination view
                if userType == .dogOwner {
                    UserProfile(userId: userId)
                } else if userType == .dogWalker {
                    WalkerProfile(userId: userId)
                } else {
                    // Fallback or error view if needed
                    Text("Error: Unknown user type for profile.")
                }
            }

            .navigationBarBackButtonHidden(true) // Keep this if desired
            .navigationTitle("Sign Up") // Add a title
            .navigationBarTitleDisplayMode(.inline)
            .alert("Registration Info", isPresented: $showAlert) { // Add title to Alert
                Button("OK") {} // Default dismiss action
            } message: {
                Text(alertMessage)
            }
        } // End NavigationStack
    }

    // --- Private Functions ---

    private func handleSignUp() {
        // Basic validation already handled by button's disabled state,
        // but double-check password match here.
        guard password == confirmPassword else {
            showAsyncAlert(message: "Passwords do not match.")
            return
        }

        isRegistering = true

        // 1. Create Firebase Auth User
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            // Ensure UI updates are on the main thread
            DispatchQueue.main.async {
                if let error = error {
                    self.isRegistering = false
                    self.showAsyncAlert(message: error.localizedDescription)
                    print("❌ Firebase Auth Error: \(error.localizedDescription)")
                    return
                }

                guard let user = authResult?.user else {
                    self.isRegistering = false
                    self.showAsyncAlert(message: "Failed to get user information after creation.")
                    print("❌ Firebase Auth Error: No user returned")
                    return
                }

                print("✅ Firebase Auth User Created: \(user.uid)")
                self.userId = user.uid // Store the userId

                // 2. Update Auth User Profile (Display Name) - Optional step
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = "\(firstName) \(lastName)"
                changeRequest.commitChanges { nameError in
                    if let nameError = nameError {
                        // Log error but don't necessarily block Firestore profile creation
                        print("⚠️ Firebase Auth Name Update Error: \(nameError.localizedDescription)")
                    } else {
                        print("✅ Firebase Auth Name Updated: \(self.firstName) \(self.lastName)")
                    }

                    // 3. Create Firestore User Profile Document
                    self.createFirestoreProfile(for: user)
                }
            }
        }
    }

    private func createFirestoreProfile(for user: User) {
        let db = Firestore.firestore()
        // --- CORRECT: Determine collection based on userType ---
        let collectionName = userType == .dogOwner ? "users" : "walkers"

        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email, // Store email in Firestore for easier access
            "userType": userType.rawValue,
            "profileComplete": false, // Mark profile as incomplete initially
            "createdAt": FieldValue.serverTimestamp() // Use server timestamp
        ]

        db.collection(collectionName).document(user.uid).setData(userData) { firestoreError in
            // Ensure UI updates are on the main thread
            DispatchQueue.main.async {
                self.isRegistering = false // Stop progress indicator here

                if let firestoreError = firestoreError {
                    self.showAsyncAlert(message: "Failed to save profile data: \(firestoreError.localizedDescription)")
                    print("❌ Firestore Error: \(firestoreError.localizedDescription)")
                    // Consider deleting the Auth user if Firestore fails critically? (More complex)
                    return
                }

                print("✅ Firestore Profile Created in '\(collectionName)' collection")

                // 4. Trigger Navigation
                self.navigateToProfile = true // Set the single trigger
            }
        }
    }

    // Helper to show alert cleanly from async blocks
    private func showAsyncAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
