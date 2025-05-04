import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // User data states
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var bio = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var profileImage: UIImage?
    @State private var userType = ""
    
    // Dog information (for dog owners)
    @State private var dogName = ""
    @State private var dogBreed = ""
    @State private var dogAge = ""
    @State private var dogSize = ""
    @State private var dogTemperament = ""
    @State private var specialInstructions = ""
    
    // Walker information (for dog walkers)
    @State private var experience = ""
    @State private var hourlyRate = ""
    @State private var servicesOffered: [String] = []
    
    // UI states
    @State private var isLoading = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isUploading = false
    
    // Options for dog size selection
    let dogSizeOptions = ["Small", "Medium", "Large", "Extra Large"]
    
    // Available services for dog walkers
    let serviceOptions = ["Dog Walking", "Overnight Care", "Drop-in Visits", "Puppy Care", "Special Needs Care"]
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Profile Image Section
                            Button(action: {
                                alertMessage = "Profile picture functionality is unavailable in this build of the app."
                                showAlert = true
                            }) {
                                VStack {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .frame(width: 100, height: 100)
                                    }
                                    
                                    Text("Photo Unavailable")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top)
                            
                            // Basic Info Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Personal Information")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                TextField("First Name", text: $firstName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Last Name", text: $lastName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(true) // Email cannot be changed
                                
                                TextField("Phone Number", text: $phoneNumber)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.phonePad)
                            }
                            .padding(.horizontal)
                            
                            // Address Section
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Address")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                TextField("Street Address", text: $address)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                HStack {
                                    TextField("City", text: $city)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    TextField("State", text: $state)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                    
                                    TextField("Zip", text: $zipCode)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.numberPad)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Bio Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("About You")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                TextEditor(text: $bio)
                                    .frame(height: 100)
                                    .padding(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)
                            
                            // Dog Owner specific fields
                            if userType == "Dog Owner" {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Dog Information")
                                        .font(.headline)
                                        .padding(.bottom, 5)
                                    
                                    TextField("Dog's Name", text: $dogName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    TextField("Breed", text: $dogBreed)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    HStack {
                                        TextField("Age", text: $dogAge)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.numberPad)
                                        
                                        Picker("Size", selection: $dogSize) {
                                            ForEach(dogSizeOptions, id: \.self) { size in
                                                Text(size).tag(size)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                    
                                    TextField("Temperament", text: $dogTemperament)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Text("Special Care Instructions")
                                        .font(.subheadline)
                                    
                                    TextEditor(text: $specialInstructions)
                                        .frame(height: 100)
                                        .padding(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .padding(.horizontal)
                            }
                            
                            // Dog Walker specific fields
                            if userType == "Dog Walker" {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Walker Information")
                                        .font(.headline)
                                        .padding(.bottom, 5)
                                    
                                    Text("Experience")
                                        .font(.subheadline)
                                    
                                    TextEditor(text: $experience)
                                        .frame(height: 100)
                                        .padding(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    
                                    HStack {
                                        Text("Hourly Rate:")
                                        TextField("$", text: $hourlyRate)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                            .frame(width: 100)
                                    }
                                    
                                    Text("Services Offered")
                                        .font(.subheadline)
                                    
                                    ForEach(serviceOptions, id: \.self) { service in
                                        Toggle(service, isOn: Binding(
                                            get: { servicesOffered.contains(service) },
                                            set: { selected in
                                                if selected {
                                                    if !servicesOffered.contains(service) {
                                                        servicesOffered.append(service)
                                                    }
                                                } else {
                                                    servicesOffered.removeAll { $0 == service }
                                                }
                                            }
                                        ))
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Save Button
                            Button(action: saveProfile) {
                                if isUploading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Save Changes")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                            .disabled(isUploading)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                }
            })
            .onAppear {
                loadUserData()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // Load user data from Firestore
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            alertMessage = "No user logged in"
            showAlert = true
            isLoading = false
            return
        }
        
        // Set email from Auth
        self.email = user.email ?? ""
        
        // First determine if this is a dog owner or dog walker
        let db = Firestore.firestore()
        
        // Try users collection first
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.alertMessage = "Error fetching user data: \(error.localizedDescription)"
                self.showAlert = true
                self.isLoading = false
                return
            }
            
            if let document = snapshot?.documents.first {
                self.userType = "Dog Owner"
                self.loadDogOwnerData(document: document)
            } else {
                // If not found in users, try walkers collection
                db.collection("walkers").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
                    if let error = error {
                        self.alertMessage = "Error fetching walker data: \(error.localizedDescription)"
                        self.showAlert = true
                        self.isLoading = false
                        return
                    }
                    
                    if let document = snapshot?.documents.first {
                        self.userType = "Dog Walker"
                        self.loadDogWalkerData(document: document)
                    } else {
                        self.alertMessage = "User profile not found"
                        self.showAlert = true
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    private func loadDogOwnerData(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        // Load basic profile data
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.state = data["state"] as? String ?? ""
        self.zipCode = data["zipCode"] as? String ?? ""
        
        // Load dog information if available
        if let dogInfo = data["dogInfo"] as? [String: Any] {
            self.dogName = dogInfo["name"] as? String ?? ""
            self.dogBreed = dogInfo["breed"] as? String ?? ""
            self.dogAge = dogInfo["age"] as? String ?? ""
            self.dogSize = dogInfo["size"] as? String ?? "Medium"
            self.dogTemperament = dogInfo["temperament"] as? String ?? ""
            self.specialInstructions = dogInfo["specialInstructions"] as? String ?? ""
        }
        
        // Load profile image if available
        if let profileImageURL = data["profileImageURL"] as? String, let url = URL(string: profileImageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImage = image
                    }
                }
            }.resume()
        }
        
        self.isLoading = false
    }
    
    private func loadDogWalkerData(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        // Load basic profile data
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.address = data["address"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.state = data["state"] as? String ?? ""
        self.zipCode = data["zipCode"] as? String ?? ""
        
        // Load walker specific data
        self.experience = data["experience"] as? String ?? ""
        if let rate = data["hourlyRate"] as? Double {
            self.hourlyRate = String(format: "%.2f", rate)
        }
        self.servicesOffered = data["servicesOffered"] as? [String] ?? []
        
        // Load profile image if available
        if let profileImageURL = data["profileImageURL"] as? String, let url = URL(string: profileImageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImage = image
                    }
                }
            }.resume()
        }
        
        self.isLoading = false
    }
    
    private func saveProfile() {
        guard let user = Auth.auth().currentUser else {
            alertMessage = "No user logged in"
            showAlert = true
            return
        }
        
        self.isUploading = true
        
        // Determine collection based on user type
        let collectionName = userType == "Dog Owner" ? "users" : "walkers"
        let db = Firestore.firestore()
        
        // Create base profile data
        var profileData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "bio": bio,
            "address": address,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Add specific fields based on user type
        if userType == "Dog Owner" {
            let dogData: [String: Any] = [
                "name": dogName,
                "breed": dogBreed,
                "age": dogAge,
                "size": dogSize,
                "temperament": dogTemperament,
                "specialInstructions": specialInstructions
            ]
            profileData["dogInfo"] = dogData
        } else if userType == "Dog Walker" {
            profileData["experience"] = experience
            if let rate = Double(hourlyRate) {
                profileData["hourlyRate"] = rate
            }
            profileData["servicesOffered"] = servicesOffered
        }
        
        // Just update the document without handling profile image
        // Profile image functionality is disabled in this build
        updateFirestoreDocument(collectionName: collectionName, data: profileData)
    }
    
    private func updateFirestoreDocument(collectionName: String, data: [String: Any]) {
        let db = Firestore.firestore()
        
        // Query to find the user's document
        db.collection(collectionName).whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isUploading = false
                    self.alertMessage = "Error finding document: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }
            
            guard let document = snapshot?.documents.first else {
                DispatchQueue.main.async {
                    self.isUploading = false
                    self.alertMessage = "User document not found"
                    self.showAlert = true
                }
                return
            }
            
            // Update the document
            db.collection(collectionName).document(document.documentID).updateData(data) { error in
                DispatchQueue.main.async {
                    self.isUploading = false
                    
                    if let error = error {
                        self.alertMessage = "Error updating profile: \(error.localizedDescription)"
                        self.showAlert = true
                    } else {
                        self.alertMessage = "Profile updated successfully!"
                        self.showAlert = true
                    }
                }
            }
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
} 