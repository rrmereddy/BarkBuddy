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
struct TimeSlot: Identifiable {
    let id = UUID()
    var startTime: Date
    var endTime: Date
}

struct DayAvailability: Identifiable {
    let id = UUID()
    var day: String
    var isAvailable: Bool
    var timeSlots: [TimeSlot]

    static func createWeekSchedule() -> [DayAvailability] {
        let defaultStart = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let defaultEnd = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
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

    // Walker specific info
    @State private var experience = ""
    @State private var hourlyRate = ""
    @State private var servicesOffered = [String]()

    // Availability
    @State private var availabilitySchedule: [DayAvailability] = DayAvailability.createWeekSchedule()

    let serviceOptions = ["Dog Walking", "Overnight Care", "Drop-in Visits", "Puppy Care", "Special Needs Care"]

    var body: some View {
        VStack {
            // Progress indicator
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
            } else {
                availabilityView()
            }
        }
        .navigationBarTitle("Walker Profile Setup", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showImagePicker) {
            // TODO: Integrate real image picker
            Text("Image Picker here")
        }
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
                    }

                    formSection(header: "Contact Information") {
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }

                    formSection(header: "Address") {
                        TextField("Street Address", text: $address)
                        HStack {
                            TextField("City", text: $city)
                            TextField("State", text: $state).frame(width: 80)
                            TextField("Zip Code", text: $zipCode).keyboardType(.numberPad).frame(width: 80)
                        }
                    }

                    formSection(header: "Experience") {
                        TextEditor(text: $experience)
                            .frame(height: 100)
                    }

                    formSection(header: "Services & Rate") {
                        VStack(alignment: .leading) {
                            Text("Services Offered").font(.subheadline)
                            ForEach(serviceOptions, id: \.self) { service in
                                Toggle(service, isOn: Binding(
                                    get: { servicesOffered.contains(service) },
                                    set: { selected in
                                        if selected { servicesOffered.append(service) }
                                        else { servicesOffered.removeAll { $0 == service } }
                                    }
                                ))
                            }
                        }
                        HStack {
                            Text("Hourly Rate $")
                            TextField("e.g. 25", text: $hourlyRate)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
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
            }
        }
        .frame(width: 120, height: 120)
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
                        Toggle(isOn: $day.isAvailable) {
                            Text(day.day).font(.headline)
                        }
                        if day.isAvailable {
                            ForEach($day.timeSlots) { $slot in
                                HStack {
                                    DatePicker("", selection: $slot.startTime, displayedComponents: .hourAndMinute)
                                    Text("to")
                                    DatePicker("", selection: $slot.endTime, displayedComponents: .hourAndMinute)
                                    Spacer()
                                    if day.timeSlots.count > 1 {
                                        Button(action: { day.timeSlots.removeAll { $0.id == slot.id } }) {
                                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            Button(action: {
                                let newSlot = TimeSlot(startTime: Date(), endTime: Date())
                                day.timeSlots.append(newSlot)
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Time Slot")
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                HStack {
                    Button(action: { currentStep = 1 }) {
                        Text("Back").frame(maxWidth: .infinity)
                            .padding().background(Color.gray.opacity(0.3)).cornerRadius(8)
                    }
                    Button(action: submitWalkerProfile) {
                        if isUploading { ProgressView() } else { Text("Complete Profile") }
                    }
                    .frame(maxWidth: .infinity)
                    .padding().background(Color.blue).foregroundColor(.white).cornerRadius(8)
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
        }
    }

    private func submitWalkerProfile() {
        isUploading = true
        let db = Firestore.firestore()
        let storage = Storage.storage()

        // Build availability data
        var availabilityData = [String: Any]()
        for day in availabilitySchedule {
            availabilityData[day.day] = [
                "isAvailable": day.isAvailable,
                "timeSlots": day.timeSlots.map { ["startTime": isoFormatter.string(from: $0.startTime), "endTime": isoFormatter.string(from: $0.endTime)] }
            ]
        }

        var data: [String: Any] = [
            "bio": bio,
            "phoneNumber": phoneNumber,
            "address": address,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "experience": experience,
            "hourlyRate": Double(hourlyRate) ?? 0,
            "servicesOffered": servicesOffered,
            "availability": availabilityData
        ]

        // Upload image if present
        if let img = profileImage, let imgData = img.jpegData(compressionQuality: 0.8) {
            let ref = storage.reference().child("walker_profiles/\(userId).jpg")
            ref.putData(imgData, metadata: nil) { _, err in
                if let err = err { finishWithError(err.localizedDescription); return }
                ref.downloadURL { url, err in
                    if let err = err { finishWithError(err.localizedDescription); return }
                    data["profileImageURL"] = url?.absoluteString
                    saveProfile(data: data, db: db)
                }
            }
        } else {
            saveProfile(data: data, db: db)
        }
    }

    private func finishWithError(_ message: String) {
        alertMessage = message
        showAlert = true
        isUploading = false
    }

    private func saveProfile(data: [String: Any], db: Firestore) {
        db.collection("walkers").document(userId).setData(data, merge: true) { err in
            isUploading = false
            if let err = err { finishWithError(err.localizedDescription); return }
            alertMessage = "Profile setup complete!"
            showAlert = true
        }
    }

    private var isoFormatter: ISO8601DateFormatter {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate]
        return fmt
    }
}

struct WalkerProfileSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkerProfile(userId: "97xAJ9gTauXZlyUDOzi2ASWse5R2")
        }
    }
}



