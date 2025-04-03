//
//  AddUserView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/2/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct AddUserView: View {
    
    // State variables for user inputs
    @State var first: String = ""
    @State var last: String = ""
    @State var email: String = ""
    @State var phone: String = ""

    var body: some View {
        VStack {
            Text("Add User")
                .font(.largeTitle)
                .padding()
            
            Text("Welcome to BarkBuddy!")
                .padding()
            
            Text("Please enter in your information to get started")
                .padding()

            // User input fields
            VStack {
                HStack {
                    TextField("First Name", text: $first)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Last Name", text: $last)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                HStack {
                    TextField("Email", text: $email)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Phone number", text: $phone)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                // Submit Button
                Button("Enter") {
                    // Handle your button action here
                    Task {
                        async let user = addUser(first: first, last: last, email: email, phone: phone)
                        await user
                    }
                }
                .disabled(first.isEmpty || last.isEmpty || email.isEmpty || phone.isEmpty) // Disable if fields are empty
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    AddUserView()
}

// Function to add user data to Firestore
func addUser(first: String, last: String, email: String, phone: String) async {
    let db = Firestore.firestore()
    do {
        let ref = try await db.collection("Users").addDocument(data: [
            "first": first,
            "last": last,
            "email": email,
            "phone": phone
        ])
        print("Document added with ID: \(ref.documentID)")
    } catch {
        print("Error adding document: \(error.localizedDescription)")
    }
}
