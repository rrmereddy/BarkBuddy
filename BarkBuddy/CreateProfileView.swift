//
//  CreateProfileView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/14/25.
//

import SwiftUI
import PhotosUI

struct CreateProfileView: View {
    // User profile data
    @State private var profileImage: UIImage?
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var pets: [Pet] = []
    
    // Photo picker
    @State private var isShowingPhotoPicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    // New pet form
    @State private var isShowingAddPetSheet = false
    @State private var newPetName = ""
    @State private var newPetBreed = ""
    
    // Alert states
    @State private var showingSaveAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
                    
                    // Pets Section
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
                    
                    // Save Button
                    Button(action: saveProfile) {
                        Text("Save Profile")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
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
        .presentationDetents([.height(200)])
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
        
        let newPet = Pet(name: newPetName, breed: newPetBreed)
        pets.append(newPet)
        
        isShowingAddPetSheet = false
        resetPetForm()
    }
    
    func resetPetForm() {
        newPetName = ""
        newPetBreed = ""
    }
    
    func saveProfile() {
        // Here you would implement the logic to save the profile data
        // For example, uploading to your API or storing locally
        
        // Validate required fields (if applicable)
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            showingErrorAlert = true
            return
        }
        
        // Show success message
        showingSaveAlert = true
    }
}

// MARK: - Pet Model
struct Pet: Identifiable {
    let id = UUID()
    let name: String
    let breed: String
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
