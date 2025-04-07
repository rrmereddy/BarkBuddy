//
//  WalkerDuringWalkView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/7/25.
//


//TS connect message view to Jay's view

import SwiftUI
import MapKit
import CoreLocation

struct WalkerDuringWalkView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var walkDuration: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isWalking = false
    @State private var walkStarted = false
    @State private var walkDistance = 0.0
    @State private var walkPath: [CLLocationCoordinate2D] = []
    @State private var currentLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    
    // Activity tracking states
    @State private var pottyBreaks = 0
    @State private var waterBreaks = 0
    @State private var treatsGiven = 0
    @State private var activityLog: [WalkActivity] = []
    
    // Communication states
    @State private var showMessageComposer = false
    @State private var messageText = ""
    @State private var showActivityPopup = false
    @State private var selectedActivity: ActivityType? = nil
    
    // Pet information
    let petName = "Max"
    let ownerName = "Jessica"
    let appointmentTime = "2:00 PM - 2:30 PM"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    // Go back action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.teal)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                Text(walkStarted ? "Walk in Progress" : "Start Your Walk")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.darkGray))
                
                Spacer()
                
                Button(action: {
                    // Help or settings
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 18))
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Pet card - always visible
                    VStack {
                        HStack(alignment: .center, spacing: 12) {
                            // Pet Image
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("🐶")
                                        .font(.title)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(petName) (\(ownerName)'s dog)")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.darkGray))
                                
                                Text(appointmentTime)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(walkStarted ? "Walk in progress" : "Scheduled walk")
                                    .font(.subheadline)
                                    .foregroundColor(walkStarted ? Color.teal : Color.orange)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showMessageComposer = true
                            }) {
                                Image(systemName: "message.fill")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.teal)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Map View
                    ZStack(alignment: .topTrailing) {
                        Map(coordinateRegion: $region, annotationItems: walkStarted ? [WalkAnnotation(coordinate: currentLocation)] : []) { item in
                            MapAnnotation(coordinate: item.coordinate) {
                                VStack {
                                    Image(systemName: "pawprint.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.teal)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                    
                                    Text(petName)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .padding(3)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .shadow(radius: 1)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(
                            !walkStarted ?
                            Text("Start the walk to track your route")
                                .foregroundColor(.gray)
                                .padding(8)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .padding()
                            : nil,
                            alignment: .center
                        )
                        
                        // Expand map button
                        Button(action: {
                            // Action to expand map to full screen
                        }) {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    if walkStarted {
                        // Walk stats card - visible when walk started
                        VStack(spacing: 0) {
                            // Section title
                            HStack {
                                Text("Current Walk Stats")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.darkGray))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .padding(.bottom, 8)
                            
                            // Stats grid
                            HStack {
                                WalkStatView(
                                    icon: "clock.fill",
                                    value: formattedDuration,
                                    label: "Duration"
                                )
                                
                                Divider()
                                    .frame(height: 40)
                                
                                WalkStatView(
                                    icon: "figure.walk",
                                    value: String(format: "%.2f", walkDistance),
                                    label: "Miles"
                                )
                                
                                Divider()
                                    .frame(height: 40)
                                
                                WalkStatView(
                                    icon: "pawprint.fill",
                                    value: "\(pottyBreaks)",
                                    label: "Potty Breaks"
                                )
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        
                        // Quick action buttons (only during walk)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ActivityButton(
                                    icon: "exclamationmark.circle.fill",
                                    label: "Potty Break",
                                    color: .yellow
                                ) {
                                    logActivity(.pottyBreak)
                                }
                                
                                ActivityButton(
                                    icon: "drop.fill",
                                    label: "Water Break",
                                    color: .blue
                                ) {
                                    logActivity(.waterBreak)
                                }
                                
                                ActivityButton(
                                    icon: "birthday.cake.fill",
                                    label: "Treat Given",
                                    color: .orange
                                ) {
                                    logActivity(.treatGiven)
                                }
                                
                                ActivityButton(
                                    icon: "camera.fill",
                                    label: "Take Photo",
                                    color: .purple
                                ) {
                                    logActivity(.photo)
                                }
                                
                                ActivityButton(
                                    icon: "exclamationmark.triangle.fill",
                                    label: "Issue",
                                    color: .red
                                ) {
                                    logActivity(.issue)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Activity timeline
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity Timeline")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.darkGray))
                                .padding(.horizontal)
                            
                            if activityLog.isEmpty {
                                Text("No activities recorded yet")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(0..<activityLog.count, id: \.self) { index in
                                        TimelineItemView(
                                            time: timeString(from: activityLog[index].timestamp),
                                            activity: activityLog[index].type.description,
                                            icon: activityLog[index].type.icon,
                                            iconColor: activityLog[index].type.color
                                        )
                                        
                                        if index < activityLog.count - 1 {
                                            TimelineSeparator()
                                        }
                                    }
                                }
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Bottom buttons based on state
                    if walkStarted {
                        // During walk buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                isWalking.toggle()
                            }) {
                                Text(isWalking ? "Pause Walk" : "Resume Walk")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(isWalking ? Color.orange : Color.teal)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // End walk
                                endWalk()
                            }) {
                                Text("End Walk")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    } else {
                        // Start walk button
                        Button(action: {
                            startWalk()
                        }) {
                            Text("Start Walk")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .background(Color.teal)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showMessageComposer) {
            MessageComposerView(petName: petName, ownerName: ownerName, messageText: $messageText, onSend: sendMessage)
        }
        .sheet(isPresented: $showActivityPopup) {
            if let activity = selectedActivity {
                ActivityDetailView(activity: activity, onSave: { notes in
                    saveActivityDetail(activity: activity, notes: notes)
                })
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Helper Methods
    
    private var formattedDuration: String {
        let minutes = Int(walkDuration) / 60
        let seconds = Int(walkDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if isWalking {
                walkDuration += 1
                
                // Simulate distance increase
                if walkDuration.truncatingRemainder(dividingBy: 10) == 0 {
                    walkDistance += 0.02
                    
                    // Simulate location update every 10 seconds
                    simulateLocationUpdate()
                }
            }
        }
    }
    
    private func simulateLocationUpdate() {
        // For demo purposes - in a real app this would use actual GPS data
        let newLat = currentLocation.latitude + Double.random(in: 0.0001...0.0005) * (Bool.random() ? 1 : -1)
        let newLong = currentLocation.longitude + Double.random(in: 0.0001...0.0005) * (Bool.random() ? 1 : -1)
        
        currentLocation = CLLocationCoordinate2D(latitude: newLat, longitude: newLong)
        walkPath.append(currentLocation)
        
        // Update map region to follow current location
        region = MKCoordinateRegion(
            center: currentLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    private func startWalk() {
        walkStarted = true
        isWalking = true
        
        // Log the start event
        logActivity(.startWalk)
        
        // Start the timer for tracking duration
        startTimer()
    }
    
    private func endWalk() {
        isWalking = false
        timer?.invalidate()
        
        // Log the end event
        logActivity(.endWalk)
        
        // In a real app, here you would navigate to a summary screen
        // For this demo, we'll keep it simple
    }
    
    private func logActivity(_ type: ActivityType) {
        let activity = WalkActivity(type: type, timestamp: Date())
        activityLog.insert(activity, at: 0) // Add newest at the top
        
        // Update counters based on activity type
        switch type {
        case .pottyBreak:
            pottyBreaks += 1
        case .waterBreak:
            waterBreaks += 1
        case .treatGiven:
            treatsGiven += 1
        case .issue:
            // Open detailed entry for issues
            selectedActivity = type
            showActivityPopup = true
        case .photo:
            // In a real app, this would open the camera
            selectedActivity = type
            showActivityPopup = true
        default:
            break
        }
    }
    
    private func sendMessage(text: String) {
        // In a real app, this would send the message to the backend
        // For demo purposes, we'll just add it to the activity log
        messageText = ""
        showMessageComposer = false
        
        let activity = WalkActivity(
            type: .message,
            timestamp: Date(),
            details: "Message to \(ownerName): \(text)"
        )
        activityLog.insert(activity, at: 0)
    }
    
    private func saveActivityDetail(activity: ActivityType, notes: String) {
        let detailedActivity = WalkActivity(
            type: activity,
            timestamp: Date(),
            details: notes
        )
        activityLog.insert(detailedActivity, at: 0)
        
        // Update counters if needed
        if activity == .pottyBreak {
            pottyBreaks += 1
        }
        
        showActivityPopup = false
        selectedActivity = nil
    }
}

// MARK: - Supporting Models

enum ActivityType {
    case startWalk
    case endWalk
    case pottyBreak
    case waterBreak
    case treatGiven
    case photo
    case issue
    case message
    
    var description: String {
        switch self {
        case .startWalk: return "Started walk"
        case .endWalk: return "Ended walk"
        case .pottyBreak: return "Potty break"
        case .waterBreak: return "Water break"
        case .treatGiven: return "Treat given"
        case .photo: return "Photo taken"
        case .issue: return "Issue reported"
        case .message: return "Message sent"
        }
    }
    
    var icon: String {
        switch self {
        case .startWalk: return "figure.walk"
        case .endWalk: return "flag.checkered"
        case .pottyBreak: return "exclamationmark.circle.fill"
        case .waterBreak: return "drop.fill"
        case .treatGiven: return "birthday.cake.fill"
        case .photo: return "camera.fill"
        case .issue: return "exclamationmark.triangle.fill"
        case .message: return "message.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .startWalk: return .teal
        case .endWalk: return .purple
        case .pottyBreak: return .yellow
        case .waterBreak: return .blue
        case .treatGiven: return .orange
        case .photo: return .purple
        case .issue: return .red
        case .message: return .teal
        }
    }
}

struct WalkActivity: Identifiable {
    let id = UUID()
    let type: ActivityType
    let timestamp: Date
    var details: String? = nil
}

// Helper model for map annotations
struct Walker_WalkAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Supporting Views

// Helper view for walk stats
struct Walker_WalkStatView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(Color.teal)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Timeline components
struct Walker_TimelineItemView: View {
    let time: String
    let activity: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(time)
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 70, alignment: .leading)
            
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 16))
            
            Text(activity)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.darkGray))
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct Walker_TimelineSeparator: View {
    var body: some View {
        HStack(spacing: 12) {
            Text(" ")
                .frame(width: 70, alignment: .leading)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1, height: 20)
                .padding(.leading, 8)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ActivityButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(12)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color(UIColor.darkGray))
            }
        }
    }
}

struct MessageComposerView: View {
    let petName: String
    let ownerName: String
    @Binding var messageText: String
    let onSend: (String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Message to \(ownerName) about \(petName)")
                    .font(.headline)
                    .padding()
                
                // Quick templates
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        MessageTemplate(text: "\(petName) is doing great!") { messageText = $0 }
                        MessageTemplate(text: "Just finished a potty break.") { messageText = $0 }
                        MessageTemplate(text: "We're having a great walk!") { messageText = $0 }
                        MessageTemplate(text: "Heading back now.") { messageText = $0 }
                    }
                    .padding(.horizontal)
                }
                
                TextEditor(text: $messageText)
                    .frame(minHeight: 150)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    if !messageText.isEmpty {
                        onSend(messageText)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Send Message")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(messageText.isEmpty ? Color.gray : Color.teal)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(messageText.isEmpty)
                
                Spacer()
            }
            .navigationBarTitle("Message Owner", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct MessageTemplate: View {
    let text: String
    let onSelect: (String) -> Void
    
    var body: some View {
        Button(action: {
            onSelect(text)
        }) {
            Text(text)
                .font(.caption)
                .padding(8)
                .background(Color.teal.opacity(0.2))
                .foregroundColor(Color.teal)
                .cornerRadius(8)
        }
    }
}

struct ActivityDetailView: View {
    let activity: ActivityType
    let onSave: (String) -> Void
    
    @State private var notes: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: activity.icon)
                        .font(.largeTitle)
                        .foregroundColor(activity.color)
                    
                    Text(activity.description)
                        .font(.headline)
                }
                .padding()
                
                Text("Add details about this activity:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                TextEditor(text: $notes)
                    .frame(minHeight: 150)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                if activity == .photo {
                    // Mock camera preview
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    onSave(notes)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save \(activity.description)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.teal)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitle("\(activity.description) Details", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Preview provider
struct DogWalkerView_Previews: PreviewProvider {
    static var previews: some View {
        WalkerDuringWalkView()
    }
}
