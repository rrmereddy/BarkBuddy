//
//  ScheduleWalkView.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 5/2/25.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Owner's Dog Model
struct OwnerDog: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

// MARK: - Walker Model
struct ScheduleWalker: Identifiable, Hashable {
    let id: String
    let name: String
}

// MARK: - Schedule Walk View
struct ScheduleWalkView: View {
    let userID: String

    @State private var walkDateTime = Date()
    @State private var selectedDuration: Int = 30
    @State private var selectedDog: OwnerDog?
    @State private var selectedWalker: ScheduleWalker?
    @State private var showingConfirmation = false
    @State private var acceptedWalkers: [ScheduleWalker] = []

    private let ownerDogs: [OwnerDog] = [
        OwnerDog(name: "Buddy"),
        OwnerDog(name: "Lucy")
    ]

    private let durations = [30, 45, 60, 90]

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                // Dog Picker
                Section(header: Text("Select Your Dog")) {
                    Picker("Dog", selection: $selectedDog) {
                        Text("Select a dog").tag(nil as OwnerDog?)
                        ForEach(ownerDogs) { dog in
                            Text(dog.name).tag(dog as OwnerDog?)
                        }
                    }
                    .onAppear {
                        if selectedDog == nil {
                            selectedDog = ownerDogs.first
                        }
                        fetchAcceptedWalkers()
                    }
                }

                // Walker Picker
                Section(header: Text("Select a Walker")) {
                    Picker("Walker", selection: $selectedWalker) {
                        Text("Select a walker").tag(nil as ScheduleWalker?)
                        ForEach(acceptedWalkers) { walker in
                            Text(walker.name).tag(walker as ScheduleWalker?)
                        }
                    }
                }

                // Date & Time Picker
                Section(header: Text("Select Date and Time")) {
                    DatePicker("Date & Time", selection: $walkDateTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                // Duration Picker
                Section(header: Text("Select Walk Duration")) {
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(durations, id: \.self) { duration in
                            Text("\(duration) minutes").tag(duration)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Schedule Button
                Section {
                    Button("Schedule Walk") {
                        scheduleWalk()
                    }
                    .disabled(selectedDog == nil || selectedWalker == nil)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Schedule a Walk")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            )
            .alert("Walk Scheduled!", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                if let dog = selectedDog, let walker = selectedWalker {
                    Text("Your \(selectedDuration)-minute walk for \(dog.name) with \(walker.name) on \(formattedDate(walkDateTime)) has been scheduled.")
                }
            }
        }
    }

    // MARK: - Firestore Fetch
    private func fetchAcceptedWalkers() {
        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument(completion: { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let walkersArray = data["accepted_walkers"] as? [[String: Any]] {
                self.acceptedWalkers = walkersArray.compactMap { dict in
                    if let id = dict["id"] as? String, let name = dict["name"] as? String {
                        return ScheduleWalker(id: id, name: name)
                    }
                    return nil
                }

                if self.selectedWalker == nil {
                    self.selectedWalker = acceptedWalkers.first
                }
            }
        })
    }


    // MARK: - Scheduling Logic
    private func scheduleWalk() {
        guard let dog = selectedDog, let walker = selectedWalker else {
            print("❌ Missing selection.")
            return
        }

        let walkData: [String: Any] = [
            "dogName": dog.name,
            "ownerId": userID,
            "walkerId": walker.id,
            "walkerName": walker.name,
            "startTime": Timestamp(date: walkDateTime),
            "duration": selectedDuration,
            "price": calculatePrice(duration: selectedDuration),
            "status": "upcoming"
        ]

        let db = Firestore.firestore()
        db.collection("walkers").document(walker.id).updateData([
            "upcoming_walks": FieldValue.arrayUnion([walkData])
        ]) { error in
            if let error = error {
                print("❌ Error updating walk: \(error.localizedDescription)")
            } else {
                print("✅ Walk scheduled for \(dog.name) with \(walker.name)")
                self.showingConfirmation = true
            }
        }
        
        db.collection("users").document(userID).updateData([
            "upcoming_walks": FieldValue.arrayUnion([walkData])
        ]) { error in
            if let error = error {
                print("❌ Error updating walk: \(error.localizedDescription)")
            } else {
                print("✅ Walk scheduled for \(dog.name) with \(walker.name)")
                self.showingConfirmation = true
            }
        }
    }

    private func calculatePrice(duration: Int) -> Double {
        return Double(duration) * 0.5
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d 'at' h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct ScheduleWalkView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleWalkView(userID: "PreviewID")
    }
}
