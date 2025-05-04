//
//  UserProfile.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 4/21/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct UserProfile: View {
    let userId: String
    @State private var bio = ""
    @State private var phoneNumber = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Dog information
    @State private var dogName = ""
    @State private var dogBreed = ""
    @State private var dogAge = ""
    @State private var dogSize = "Medium"
    @State private var dogTemperament = ""
    @State private var specialInstructions = ""
    @State private var completed: Bool = false
    
    let dogSizeOptions = ["Small", "Medium", "Large", "Extra Large"]
    
    var body: some View {
        VStack{
            NavigationLink(
                destination: HomeView(),
                isActive: $completed,
                label: {
                    EmptyView()
                }
            )
            .hidden()
            ScrollView {
                VStack(spacing: 25) {
                    
                    // Header
                    VStack(spacing: 10) {
                        Text("Complete Your Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tell us about you and your dog")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    
                    // Profile Picture
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Add Profile Photo")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                    }
                    
                    // Owner Profile Form
                    VStack(spacing: 15) {
                        // Bio
                        VStack(alignment: .leading, spacing: 5) {
                            Text("About You")
                                .font(.headline)
                                .padding(.leading, 2)
                            
                            TextEditor(text: $bio)
                                .frame(height: 120)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                        
                        // Contact Information
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Contact Information")
                                .font(.headline)
                                .padding(.leading, 2)
                            
                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        
                        // Address
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Address")
                                .font(.headline)
                                .padding(.leading, 2)
                            
                            TextField("Street Address", text: $address)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            HStack(spacing: 10) {
                                TextField("City", text: $city)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                TextField("State", text: $state)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .frame(width: 80)
                                
                                TextField("Zip", text: $zipCode)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .frame(width: 80)
                            }
                        }
                        
                        // Dog Information
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Dog Information")
                                .font(.headline)
                                .padding(.leading, 2)
                            
                            TextField("Dog's Name", text: $dogName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            TextField("Breed", text: $dogBreed)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            HStack(spacing: 10) {
                                TextField("Age", text: $dogAge)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                Picker("Size", selection: $dogSize) {
                                    ForEach(dogSizeOptions, id: \.self) { size in
                                        Text(size).tag(size)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            
                            TextField("Temperament (e.g., friendly, shy, energetic)", text: $dogTemperament)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Special Care Instructions")
                                    .font(.subheadline)
                                    .padding(.leading, 2)
                                
                                TextEditor(text: $specialInstructions)
                                    .frame(height: 100)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Submit button
                        Button(action: submitUserProfile) {
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Complete Profile")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isUploading)
                        .opacity(isUploading ? 0.6 : 1)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarTitle("Profile Setup", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showImagePicker) {
            // Image picker would go here
            ImagePicker(selectedImage: $profileImage)
        }
    }
    
    private func submitUserProfile() {
        isUploading = true
        
        let db = Firestore.firestore()
        
        // Create dog information document
        let dogData: [String: Any] = [
            "name": dogName,
            "breed": dogBreed,
            "age": dogAge,
            "size": dogSize,
            "temperament": dogTemperament,
            "specialInstructions": specialInstructions,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        // Store profile data to be used with or without image
        let profileData: [String: Any] = [
            "bio": bio,
            "phoneNumber": phoneNumber,
            "address": address,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "profileComplete": true,
            "dogInfo": dogData,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // If we have an image, upload it first, then update the profile
        if let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.7) {
            uploadImageAndSaveProfile(imageData: imageData, profileData: profileData)
        } else {
            // Otherwise just update the profile without an image
            updateProfileData(profileData: profileData)
        }
    }
    
    private func uploadImageAndSaveProfile(imageData: Data, profileData: [String: Any]) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("user_profiles/\(userId).jpg")
        
        // Upload the image
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                // Handle the error
                DispatchQueue.main.async {
                    self.isUploading = false
                    self.alertMessage = "Error uploading image: \(error?.localizedDescription ?? "Unknown error")"
                    self.showAlert = true
                }
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { url, error in
                var updatedProfileData = profileData
                
                if let downloadURL = url {
                    // Add the profile image URL to the profile data
                    updatedProfileData["profileImageURL"] = downloadURL.absoluteString
                }
                
                // Update the profile with or without the image URL
                self.updateProfileData(profileData: updatedProfileData)
            }
        }
    }
    
    private func updateProfileData(profileData: [String: Any]) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).updateData(profileData) { error in
            DispatchQueue.main.async {
                self.isUploading = false
                
                if let error = error {
                    self.alertMessage = "Error updating profile: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }
                
                self.alertMessage = "Profile completed successfully!"
                self.showAlert = true
                self.completed = true
            }
        }
    }
}

struct UserProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfile(userId: "PreviewID")
        }
    }
}
