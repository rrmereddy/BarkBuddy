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
    @State var userType:String = ""
    @State var infoEntered = false //letting us know if a user has created their profile
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
                HStack { //lets us know which area of the database to store this information
                    //TS work on the UI for these Buttons, can't tell which one is pressed atm
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
                
                // Submit Button
                Button("Enter") {
                    // Handle your button action here
                    Task {
                        async let user = addUser(first: first, last: last, email: email, phone: phone, userType: userType)
                        await user
                    }
                    infoEntered = true
                    
                }
                .disabled(first.isEmpty || last.isEmpty || email.isEmpty || phone.isEmpty || infoEntered || userType.isEmpty) // Disable if fields are empty or if info has already been entered
                .padding()
                
                if infoEntered == true {
                    Text("Your information has been saved!")
                }
                
            }
            .padding()
        }
    }
}
#Preview {
    AddUserView()
}
// Function to add user data to Firestore
func addUser(first: String, last: String, email: String, phone: String, userType: String) async {
    let db = Firestore.firestore()
    let dateCreated = Date() //lets us get the date created for the user
    do {
        let ref = try await db.collection(userType).addDocument(data: [
            "first": first,
            "last": last,
            "email": email,
            "phone": phone,
            "createdAt": dateCreated
        ])
        print("Document added with ID: \(ref.documentID)")
    } catch {
        print("Error adding document: \(error.localizedDescription)")
    }
}

