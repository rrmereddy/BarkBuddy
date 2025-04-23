//
//  CreateProfileView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/14/25.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

// User type enum
enum UserType {
    case user
    case walker
    
    //temporary! We have no way to pull specific userID rn
    var documentId: String {
        switch self {
        case .user:
            return "6cxigz0LIPxAu9b5J0Lp"
        case .walker:
            return "CaXIIozHXL3W34RVz1iq"
        }
    }
}

struct CreateProfileView: View {
    // User profile data
    @State private var profileImage: UIImage?
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var pets: [Pet] = []
    @State private var userType: UserType = .user
    
    // Firebase references
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // States
    @State private var isLoading = false
    
    // Photo picker
    @State private var isShowingPhotoPicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    // New pet form
    @State private var isShowingAddPetSheet = false
    @State private var newPetName = ""
    @State private var newPetBreed = ""
    @State private var otherInfo = ""
    @State private var temperament = ""
    
    // Alert states
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // User Type Selector
                    Picker("User Type", selection: $userType) {
                        Text("Pet Owner").tag(UserType.user)
                        Text("Walker").tag(UserType.walker)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Profile Photo Section
                    VStack {
                        ZStack {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        PhotosPicker(selection: $photoPickerItem, matching: .images) {
                            Text("Change Photo")
                                .foregroundColor(.blue)
                        }
                        .onChange(of: photoPickerItem) { loadProfileImage() }
                    }
                    .padding(.top, 10)
                    
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.headline)
                        
                        TextField("Enter your full name", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Bio Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .font(.headline)
                        
                        TextEditor(text: $bio)
                            .frame(height: 120)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Pets Section (only show for regular users)
                    if userType == .user {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("My Pets")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    isShowingAddPetSheet = true
                                }) {
                                    Text("+ Add Pet")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if pets.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("No pets added yet")
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 20)
                                    Spacer()
                                }
                            } else {
                                ForEach(pets) { pet in
                                    PetRowView(pet: pet) {
                                        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
                                            pets.remove(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Save Button
                    Button(action: saveProfile) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save Profile")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(isLoading)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Create Profile")
            .sheet(isPresented: $isShowingAddPetSheet) {
                addPetView
            }
            .alert("Profile Saved", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been successfully updated!")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // Add Pet View
    var addPetView: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Pet's Name", text: $newPetName)
                    TextField("Pet's Breed", text: $newPetBreed)
                    TextField("Pet's Temperament", text: $temperament)
                    TextField("Any Other Info?", text: $otherInfo)
                }
            }
            .navigationTitle("Add New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingAddPetSheet = false
                        resetPetForm()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addPet()
                    }
                    .disabled(newPetName.isEmpty || newPetBreed.isEmpty)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    // MARK: - Functions
    
    func loadProfileImage() {
        Task {
            if let photoItem = photoPickerItem,
               let data = try? await photoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }
    
    func addPet() {
        guard !newPetName.isEmpty, !newPetBreed.isEmpty else {
            errorMessage = "Please enter both pet name and breed"
            showingErrorAlert = true
            return
        }
        
        let newPet = Pet(name: newPetName, breed: newPetBreed, temperament: temperament, otherInfo: otherInfo)
        pets.append(newPet)
        
        isShowingAddPetSheet = false
        resetPetForm()
    }
    
    func resetPetForm() {
        newPetName = ""
        newPetBreed = ""
        temperament = ""
        otherInfo = ""
    }
    
    func saveProfile() {
        // Validate required fields
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            showingErrorAlert = true
            return
        }
        
        isLoading = true
        
        // Get the document ID based on user type
        let documentId = userType.documentId
        
        // First upload image if exists
        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.8) {
            let storageRef = storage.reference().child("profile_images/\(documentId).jpg")
            
            let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    DispatchQueue.main.async {
                        isLoading = false
                        errorMessage = "Error uploading image: \(error.localizedDescription)"
                        showingErrorAlert = true
                    }
                    return
                }
                
                // Get download URL
                storageRef.downloadURL { url, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            isLoading = false
                            errorMessage = "Error getting image URL: \(error.localizedDescription)"
                            showingErrorAlert = true
                        }
                        return
                    }
                    
                    if let photoURL = url?.absoluteString {
                        // Save user data with photo URL
                        saveUserDataToFirestore(documentId: documentId, photoURL: photoURL)
                    }
                }
            }
        } else {
            // No profile image, just save user data
            saveUserDataToFirestore(documentId: documentId, photoURL: nil)
        }
    }
    
    func saveUserDataToFirestore(documentId: String, photoURL: String?) {
        // Create data dictionary to match your specified field mappings
        var userData: [String: Any] = [
            "first": name,
            "bio": bio
        ]
        
        // Add photo URL if available
        if let photoURL = photoURL {
            userData["photo"] = photoURL
        }
        
        // Add pets data for user type
        if userType == .user && !pets.isEmpty {
            let petsData = pets.map { pet -> [String: String] in
                return [
                    "name": pet.name,
                    "breed": pet.breed,
                    "temperament": pet.temperament,
                    "otherInfo": pet.otherInfo
                ]
            }
            userData["pets"] = petsData
        }
        
        // Update the document in Firestore
        db.collection("users").document(documentId).setData(userData, merge: true) { error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Error saving profile: \(error.localizedDescription)"
                    showingErrorAlert = true
                } else {
                    showingSaveAlert = true
                }
            }
        }
    }
}

// MARK: - Pet Model
struct Pet: Identifiable, Codable {
    let id = UUID()
    let name: String
    let breed: String
    let temperament: String
    let otherInfo: String
}

// MARK: - Pet Row View
struct PetRowView: View {
    let pet: Pet
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "pawprint.fill")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(.system(size: 16, weight: .medium))
                
                Text(pet.breed)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
struct ProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView()
    }
}
