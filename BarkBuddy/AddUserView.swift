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
struct AddUserView: View {
    
    // State variables for user inputs
    @State var first: String = ""
    @State var last: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    @State var userType: String = ""
    @State var infoEntered = false // letting us know if a user has created their profile
    @State var documentID: String? = nil // Store the document ID for deleting the profile
    @State var isDeleted = false // Track whether the user has deleted their profile
    
    var body: some View {
        VStack {
            Text("Add User")
                .font(.largeTitle)
                .padding()
            
            Text("Welcome to BarkBuddy!")
            
            Text("Please enter in your information to get started")
                .padding()
            
            // User input fields
            VStack {
                Text("I am a...")
                HStack {
                    Button("Owner"){
                        userType = "Users"
                    }
                    .padding()
                    Button("Walker"){
                        userType = "Walkers"
                    }
                }
                HStack {
                    TextField("First Name", text: $first)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $last)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack {
                    TextField("Email", text: $email)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Phone number", text: $phone)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Submit Button (now it handles both creating and updating)
                Button(infoEntered ? "Update Profile" : "Enter") {
                    if let documentID = documentID {
                        // If profile exists, update it
                        Task {
                            await updateUserProfile(documentID: documentID, first: first, last: last, email: email, phone: phone)
                        }
                    } else {
                        // If it's a new profile, create it
                        Task {
                            async let user = addUser(first: first, last: last, email: email, phone: phone, userType: userType)
                            await user
                        }
                    }
                    infoEntered = true
                } //TS make it so that the button switches back to Enter once a profile is deleted
                .disabled(first.isEmpty || last.isEmpty || email.isEmpty || phone.isEmpty || userType.isEmpty)
                .padding()
                
                if infoEntered {
                    Text("Your information has been saved!")
                    
                    // Make the delete button visible after profile is created
                    if let documentID = documentID, !isDeleted {
                        Button("Delete Profile") {
                            Task {
                                await deleteUserProfile(documentID: documentID)
                            }
                            isDeleted = true
                        }
                        .foregroundColor(.red)
                        .padding()
                    }
                }
            }
            .padding()
        }
    }
    
    // Function to add user data to Firestore
    func addUser(first: String, last: String, email: String, phone: String, userType: String) async {
        let db = Firestore.firestore()
        let dateCreated = Date() // Get the date created for the user
        do {
            let ref = try await db.collection(userType).addDocument(data: [
                "first": first,
                "last": last,
                "email": email,
                "phone": phone,
                "createdAt": dateCreated
            ])
            print("Document added with ID: \(ref.documentID)")
            documentID = ref.documentID // Store the document ID to delete later
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
    }
    
    // Function to update user profile in Firestore
    func updateUserProfile(documentID: String, first: String, last: String, email: String, phone: String) async {
        let db = Firestore.firestore()
        do {
            try await db.collection(userType).document(documentID).updateData([
                "first": first,
                "last": last,
                "email": email,
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
        } catch {
            print("Error deleting document: \(error.localizedDescription)")
        }
    }
}
#Preview {
    AddUserView()
}


