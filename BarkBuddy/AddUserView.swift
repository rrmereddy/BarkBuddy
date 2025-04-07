//
//  AddUserView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/2/25.
//
// deleting or changing a profile will only be allowed once a user is logged in, this page would probably appear before allowing a user to set a log in?
//details like pet, services offered, address not taken here, will be added when appointments are booked
//connect this to a user structure that allows us to hold this information within the app (atleast know our documentID)
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct AddUserView: View {
    
    // State variables for user inputs
    @State var first: String = ""
    @State var last: String = ""
    @State var email: String = ""
    @State var password: String = ""  // New: Added for authentication
    @State var confirmPassword: String = "" // New: For password confirmation
    @State var phone: String = ""
    @State var userType: String = ""
    @State var infoEntered = false // letting us know if a user has created their profile
    @State var documentID: String? = nil // Store the document ID for deleting the profile
    @State var isDeleted = false // Track whether the user has deleted their profile
    
    // Authentication states
    @State var isRegistered = false
    @State var isVerified = false
    @State var showingAlert = false
    @State var alertMessage = ""
    @State var alertTitle = ""
    @State var isLoading = false
    
    var body: some View {
        VStack {
            Text("Add User")
                .font(.largeTitle)
                .padding()
            
            Text("Welcome to BarkBuddy!")
            
            if !isRegistered {
                // Account creation view
                accountCreationView
            } else if !isVerified {
                // Email verification view
                emailVerificationView
            } else {
                // Profile creation view after verification
                profileCreationView
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - View Components
    
    var accountCreationView: some View {
        VStack {
            Text("Create your account")
                .font(.headline)
                .padding()
            
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("I am a...")
            HStack {
                Button("Owner"){
                    userType = "Users"
                }
                .padding()
                .background(userType == "Users" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                Button("Walker"){
                    userType = "Walkers"
                }
                .padding()
                .background(userType == "Walkers" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button("Register") {
                registerUser()
            }
            .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || userType.isEmpty || password != confirmPassword || password.count < 6)
            .padding()
            .background(
                (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || userType.isEmpty || password != confirmPassword || password.count < 6)
                ? Color.gray.opacity(0.5)
                : Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if password != confirmPassword && !confirmPassword.isEmpty {
                Text("Passwords don't match")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if password.count < 6 && !password.isEmpty {
                Text("Password must be at least 6 characters")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
    }
    
    var emailVerificationView: some View {
        VStack {
            Text("Verify Your Email")
                .font(.headline)
                .padding()
            
            Text("A verification email has been sent to \(email). Please check your inbox and click the verification link.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button("I've Verified My Email") {
                checkEmailVerification()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Resend Verification Email") {
                sendVerificationEmail()
            }
            .padding()
            .foregroundColor(.blue)
            
            Button("Use Different Email") {
                logout()
            }
            .padding()
            .foregroundColor(.red)
        }
        .padding()
    }
    
    var profileCreationView: some View {
        VStack {
            Text("Create Your Profile")
                .font(.headline)
                .padding()
            
            HStack {
                TextField("First Name", text: $first)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Last Name", text: $last)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            TextField("Phone number", text: $phone)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
            
            // Submit Button (now it handles both creating and updating)
            Button(infoEntered ? "Update Profile" : "Create Profile") {
                if let documentID = documentID {
                    // If profile exists, update it
                    Task {
                        await updateUserProfile(documentID: documentID, first: first, last: last, phone: phone)
                    }
                } else {
                    // If it's a new profile, create it
                    Task {
                        async let user = addUser(first: first, last: last, phone: phone)
                        await user
                    }
                }
                infoEntered = true
            }
            .disabled(first.isEmpty || last.isEmpty || phone.isEmpty)
            .padding()
            .background(
                (first.isEmpty || last.isEmpty || phone.isEmpty)
                ? Color.gray.opacity(0.5)
                : Color.blue
            )
            .foregroundColor(.white)
            .cornerRadius(8)
            
            if infoEntered {
                Text("Your profile has been saved!")
                
                // Make the delete button visible after profile is created
                if let documentID = documentID, !isDeleted {
                    Button("Delete Profile") {
                        Task {
                            await deleteUserProfile(documentID: documentID)
                        }
                        isDeleted = true
                        infoEntered = false
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
            
            Button("Sign Out") {
                logout()
            }
            .foregroundColor(.red)
            .padding()
        }
        .padding()
    }
    
    // MARK: - Firebase Authentication Methods
    
    func registerUser() {
        if password != confirmPassword {
            alertTitle = "Error"
            alertMessage = "Passwords don't match"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            
            if let error = error {
                alertTitle = "Registration Failed"
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            // Successfully registered
            isRegistered = true
            sendVerificationEmail()
        }
    }
    
    func sendVerificationEmail() {
        guard let user = Auth.auth().currentUser else {
            alertTitle = "Error"
            alertMessage = "No authenticated user found"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        user.sendEmailVerification { error in
            isLoading = false
            
            if let error = error {
                alertTitle = "Failed to Send Verification"
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            alertTitle = "Verification Email Sent"
            alertMessage = "Please check your inbox at \(email) and click the verification link"
            showingAlert = true
        }
    }
    
    func checkEmailVerification() {
        guard let user = Auth.auth().currentUser else {
            alertTitle = "Error"
            alertMessage = "No authenticated user found"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Reload user to get latest verification status
        user.reload { error in
            isLoading = false
            
            if let error = error {
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            if Auth.auth().currentUser?.isEmailVerified == true {
                isVerified = true
            } else {
                alertTitle = "Not Verified"
                alertMessage = "Your email is not verified yet. Please check your inbox and click the verification link."
                showingAlert = true
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            // Reset states
            isRegistered = false
            isVerified = false
            documentID = nil
            infoEntered = false
            isDeleted = false
            email = ""
            password = ""
            confirmPassword = ""
            first = ""
            last = ""
            phone = ""
        } catch {
            alertTitle = "Error"
            alertMessage = "Failed to sign out: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    // MARK: - Firestore Methods
    
    // Function to add user data to Firestore (now only after verification)
    func addUser(first: String, last: String, phone: String) async {
        guard let user = Auth.auth().currentUser, user.isEmailVerified else {
            return
        }
        
        let db = Firestore.firestore()
        let dateCreated = Date() // Get the date created for the user
        do {
            let ref = try await db.collection(userType).addDocument(data: [
                "first": first,
                "last": last,
                "email": email,
                "phone": phone,
                "uid": user.uid,
                "createdAt": dateCreated
            ])
            print("Document added with ID: \(ref.documentID)")
            documentID = ref.documentID // Store the document ID to delete later
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
    }
    
    // Function to update user profile in Firestore
    func updateUserProfile(documentID: String, first: String, last: String, phone: String) async {
        let db = Firestore.firestore()
        do {
            try await db.collection(userType).document(documentID).updateData([
                "first": first,
                "last": last,
                "phone": phone
            ])
            print("Document updated with ID: \(documentID)")
        } catch {
            print("Error updating document: \(error.localizedDescription)")
        }
    }
    
    // Function to delete user profile from Firestore
    func deleteUserProfile(documentID: String) async {
        let db = Firestore.firestore()
        do {
            try await db.collection(userType).document(documentID).delete()
            print("Document deleted with ID: \(documentID)")
            // Reset relevant state variables
            self.documentID = nil
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddUserView()
}


