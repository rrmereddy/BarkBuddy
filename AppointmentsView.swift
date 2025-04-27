import SwiftUI

struct AppointmentsView: View {
    @State private var dogwalkerName: String = ""
    @State private var availabilities: [DayAvailability] = {
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            .map { DayAvailability(day: $0, isAvailable: false, timeSlots: []) }
    }()
    @State private var showingSavedAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                // Dogwalker name input
                Section(header: Text("Dogwalker Information")) {
                    TextField("Your Name", text: $dogwalkerName)
                        .autocapitalization(.words)
                }

                // Weekly availability
                Section(header: Text("Set Your Availability")) {
                    ForEach(availabilities.indices, id: \.self) { dayIndex in
                        DisclosureGroup(availabilities[dayIndex].day) {
                            AvailabilityDisclosure(day: $availabilities[dayIndex])
                        }
                    }
                }

                // Save button
                Section {
                    Button(action: saveAvailability) {
                        Text("Save Availability")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Set Your Availability")
            .alert("Success", isPresented: $showingSavedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your availability has been saved!")
            }
        }
    }

    private func saveAvailability() {
        // Persist `availabilities` here (e.g., backend or UserDefaults)
        showingSavedAlert = true
    }
}

struct AvailabilityDisclosure: View {
    @Binding var day: DayAvailability

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Available", isOn: $day.isAvailable)

            if day.isAvailable {
                Divider()
                Text("Time Slots").font(.headline)

                ForEach(day.timeSlots.indices, id: \.self) { slotIndex in
                    HStack {
                        TextField("From", text: $day.timeSlots[slotIndex].start)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("to")
                        TextField("To", text: $day.timeSlots[slotIndex].end)
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer()
                        Button {
                            day.timeSlots.remove(at: slotIndex)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                Button {
                    day.timeSlots.append(TimeSlot(start: "", end: ""))
                } label: {
                    Label("Add Time Slot", systemImage: "plus.circle")
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Previews

struct AppointmentsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppointmentsView()
                .previewDisplayName("Default State")
            AppointmentsView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

