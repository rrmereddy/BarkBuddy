//
//  WalkerProfile.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 4/21/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

// MARK: - Availability Models
struct TimeSlot: Identifiable, Codable {
    let id = UUID()
    var startTime: Date
    var endTime: Date

    enum CodingKeys: String, CodingKey {
        case startTime, endTime
    }
}

struct DayAvailability: Identifiable, Codable {
    let id = UUID()
    var day: String
    var isAvailable: Bool
    var timeSlots: [TimeSlot]

    enum CodingKeys: String, CodingKey {
        case day, isAvailable, timeSlots
    }

    static func createWeekSchedule() -> [DayAvailability] {
        let calendar = Calendar.current
        guard let defaultStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
              let defaultEnd = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) else {
            print("ERROR: Could not create default start/end times for availability schedule.")
            let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            return days.map { DayAvailability(day: $0, isAvailable: false, timeSlots: []) }
        }

        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days.map { day in
            DayAvailability(day: day, isAvailable: false, timeSlots: [TimeSlot(startTime: defaultStart, endTime: defaultEnd)])
        }
    }
}

struct WalkerProfile: View {
    let userId: String

    @State private var currentStep = 1
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
    @State private var experience = ""
    @State private var hourlyRate = ""
    @State private var servicesOffered = [String]()
    @State private var availabilitySchedule: [DayAvailability] = DayAvailability.createWeekSchedule()
    @State private var completed = false

    let serviceOptions = ["Dog Walking", "Overnight Care", "Drop-in Visits", "Puppy Care", "Special Needs Care"]

    private var isoFormatter: ISO8601DateFormatter {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt
    }

    var body: some View {
        VStack {
            NavigationLink(
                destination: HomeView(),
                isActive: $completed
            ) {
                EmptyView()
            }
            HStack {
                ForEach(1...2, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 15, height: 15)
                }
                Spacer()
                Text("\(currentStep) of 2")
                    .foregroundColor(.gray)
            }
            .padding()

            if currentStep == 1 {
                basicProfileInfoView()
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            } else {
                availabilityView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .navigationBarTitle("Walker Profile Setup", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .alert("Error", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showImagePicker) {
            Text("Image Picker Placeholder")
        }
        .animation(.default, value: currentStep)
    }

    private func basicProfileInfoView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView(title: "Complete Your Profile", subtitle: "Tell dog owners about yourself")

                Button(action: { showImagePicker = true }) {
                    profileImageView
                }

                Group {
                    formSection(header: "About You") {
                        TextEditor(text: $bio)
                            .frame(height: 120)
                            .border(Color.gray.opacity(0.2))
                    }

                    formSection(header: "Contact Information") {
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    formSection(header: "Address") {
                        TextField("Street Address", text: $address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        HStack {
                            TextField("City", text: $city).textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("State", text: $state).frame(width: 80).textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Zip Code", text: $zipCode).keyboardType(.numberPad).frame(width: 80).textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    formSection(header: "Experience") {
                        TextEditor(text: $experience)
                            .frame(height: 100)
                            .border(Color.gray.opacity(0.2))
                    }

                    formSection(header: "Services & Rate") {
                        VStack(alignment: .leading) {
                            Text("Services Offered").font(.subheadline)
                            ForEach(serviceOptions, id: \.self) { service in
                                Toggle(service, isOn: Binding(
                                    get: { servicesOffered.contains(service) },
                                    set: { selected in
                                        if selected {
                                            if !servicesOffered.contains(service) { servicesOffered.append(service) }
                                        } else {
                                            servicesOffered.removeAll { $0 == service }
                                        }
                                    }
                                ))
                            }
                        }
                        HStack {
                            Text("Hourly Rate $")
                            TextField("e.g. 25", text: $hourlyRate)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: { currentStep = 2 }) {
                    Text("Next: Set Availability")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }

    private var profileImageView: some View {
        Group {
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .frame(width: 120, height: 120)
        .background(Color(.systemGray5))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
        .padding(.bottom, 10)
    }

    private func availabilityView() -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView(title: "Set Your Availability", subtitle: "Let dog owners know when you're available")

                ForEach($availabilitySchedule) { $day in
                    VStack(alignment: .leading) {
                        Toggle(isOn: $day.isAvailable.animation()) {
                            Text(day.day).font(.headline)
                        }
                        if day.isAvailable {
                            ForEach($day.timeSlots) { $slot in
                                HStack {
                                    DatePicker("", selection: $slot.startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                    Text("to")
                                    DatePicker("", selection: $slot.endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                    Spacer()
                                    if day.timeSlots.count > 1 {
                                        Button {
                                            day.timeSlots.removeAll { $0.id == slot.id }
                                        } label: {
                                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.leading)
                            }
                            Button {
                                let defaultStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                                let defaultEnd = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
                                let newSlot = TimeSlot(startTime: defaultStart, endTime: defaultEnd)
                                day.timeSlots.append(newSlot)
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Time Slot")
                                }
                            }
                            .buttonStyle(.borderless)
                            .padding(.top, 5)
                            .padding(.leading)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                HStack {
                    Button(action: { currentStep = 1 }) {
                        Text("Back")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }

                    Button(action: submitWalkerProfile) {
                        HStack {
                            Spacer()
                            if isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Complete Profile")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(isUploading)
                }
                .padding()
            }
        }
    }

    private func headerView(title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.title2).bold()
            Text(subtitle).font(.subheadline).foregroundColor(.gray)
        }
        .padding()
    }

    private func formSection<Content: View>(header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header).font(.headline)
            content()
                .padding(.bottom, 5)
        }
    }

    private func submitWalkerProfile() {
        isUploading = true

        var data: [String: Any] = [
            "bio": bio,
            "phoneNumber": phoneNumber,
            "address": address,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "experience": experience,
            "hourlyRate": Double(hourlyRate) ?? 0.0,
            "servicesOffered": servicesOffered,
            "profileComplete": true
        ]

        var availabilityData = [String: Any]()
        for day in availabilitySchedule where day.isAvailable {
            availabilityData[day.day] = [
                "isAvailable": day.isAvailable,
                "timeSlots": day.timeSlots.map {
                    ["startTime": isoFormatter.string(from: $0.startTime),
                     "endTime": isoFormatter.string(from: $0.endTime)]
                }
            ]
        }

        if !availabilityData.isEmpty {
            data["availability"] = availabilityData
        }

        if let img = profileImage, let imgData = img.jpegData(compressionQuality: 0.7) {
            uploadImageAndSaveProfile(imageData: imgData, data: data)
        } else {
            saveProfile(data: data, db: Firestore.firestore())
        }
    }

    private func uploadImageAndSaveProfile(imageData: Data, data: [String: Any]) {
        let storage = Storage.storage()
        let db = Firestore.firestore()
        let ref = storage.reference().child("walker_profiles/\(userId).jpg")

        ref.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                if let error = error {
                    self.finishWithError("Image upload failed: \(error.localizedDescription)")
                } else {
                    self.finishWithError("Image upload failed.")
                }
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    print("⚠️ Failed to get download URL: \(error.localizedDescription)")
                    var updatedData = data
                    updatedData["profileImageURL"] = nil
                    self.saveProfile(data: updatedData, db: db)
                    return
                }

                if let downloadURL = url {
                    var finalData = data
                    finalData["profileImageURL"] = downloadURL.absoluteString
                    self.saveProfile(data: finalData, db: db)
                } else {
                    self.saveProfile(data: data, db: db)
                }
            }
        }
    }

    private func finishWithError(_ message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
            self.isUploading = false
        }
    }

    private func saveProfile(data: [String: Any], db: Firestore) {
        db.collection("walkers").document(userId).setData(data, merge: true) { error in
            DispatchQueue.main.async {
                self.isUploading = false

                if let error = error {
                    self.finishWithError("Failed to save profile: \(error.localizedDescription)")
                    print("❌ Firestore save error: \(error.localizedDescription)")
                    return
                }

                print("✅ Walker profile saved/updated successfully for \(userId)")
                self.completed = true
            }
        }
    }
}

struct WalkerProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkerProfile(userId: "previewUserID")
        }
    }
}
