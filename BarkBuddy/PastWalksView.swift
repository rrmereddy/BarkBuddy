//
//  PastWalksView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/12/25.
//

import SwiftUI

struct PastWalksView: View {
    @State private var selectedWalk: Walk?
    @State private var showingDetail = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode
    
    // Sample data
    let walks = [
        Walk(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            dogName: "Max",
            partnerName: "John",
            partnerImage: "profile1",
            duration: 30,
            distance: 1.2,
            cost: 15.00,
            pottyBreaks: 2,
            activities: ["Park visit", "Ball play"],
            comments: "Max was excited today!",
            rating: 4.5,
            photos: ["walk1", "walk2"]
        ),
        Walk(
            id: UUID(),
            date: Date().addingTimeInterval(-259200),
            dogName: "Bella",
            partnerName: "Sarah",
            partnerImage: "profile2",
            duration: 45,
            distance: 2.0,
            cost: 22.50,
            pottyBreaks: 3,
            activities: ["Trail walk", "Training"],
            comments: "Bella is making great progress with her training.",
            rating: 5.0,
            photos: ["walk3"]
        ),
        Walk(
            id: UUID(),
            date: Date().addingTimeInterval(-432000),
            dogName: "Max",
            partnerName: "John",
            partnerImage: "",
            duration: 20,
            distance: 0.8,
            cost: 10.00,
            pottyBreaks: 1,
            activities: ["Neighborhood walk"],
            comments: "Quick potty break.",
            rating: 4.0,
            photos: []
        )
    ]
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(walks) { walk in
                    WalkListItem(walk: walk)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedWalk = walk
                            showingDetail = true
                        }
                }
            }
            .navigationTitle("Past Walks")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            )
            .sheet(isPresented: $showingDetail) {
                if let walk = selectedWalk {
                    WalkDetailView(walk: walk)
                        .edgesIgnoringSafeArea(.bottom)
                }
                
            }
        }
    }
}

struct WalkListItem: View {
    let walk: Walk
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile picture
            ProfileImageView(imageName: walk.partnerImage, name: walk.partnerName)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Walk with \(walk.partnerName)")
                        .font(.headline)
                    Spacer()
                }
                
                HStack {
                    Text("\(walk.dogName)")
                        .font(.subheadline)
                    Spacer()
                }
                
                Text(formattedDate(walk.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ProfileImageView: View {
    let imageName: String
    let name: String
    
    // Human emoji options for placeholder
    let humanEmojis = ["👩", "👨", "👱‍♀️", "👱‍♂️", "👩‍🦰", "👨‍🦰", "👩‍🦱", "👨‍🦱", "👩‍🦳", "👨‍🦳"]
    
    var body: some View {
        // In a real app, you would use an actual image loaded from an asset or URL
        // For now, we'll use emoji placeholders if no image is available
        if imageName.isEmpty {
            // Get a consistent emoji based on the name
            let nameHash = name.hashValue
            let emojiIndex = abs(nameHash) % humanEmojis.count
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                
                Text(humanEmojis[emojiIndex])
                    .font(.system(size: 24))
            }
        } else {
            // This would be a proper image in a real app
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                
                Text("👤")
                    .font(.system(size: 24))
            }
        }
    }
}

struct WalkDetailView: View {
    let walk: Walk
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section
                    HStack(spacing: 15) {
                        ProfileImageView(imageName: walk.partnerImage, name: walk.partnerName)
                            .frame(width: 70, height: 70)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Walk with \(walk.partnerName)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(walk.dogName)")
                                .font(.headline)
                            
                            Text(formattedDate(walk.date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Walk stats
                    HStack(spacing: 12) {
                        StatCard(iconName: "clock", value: "\(walk.duration)", unit: "min", label: "Duration")
                        StatCard(iconName: "figure.walk", value: String(format: "%.1f", walk.distance), unit: "mi", label: "Distance")
                        StatCard(iconName: "pawprint.fill", value: "\(walk.pottyBreaks)", unit: "", label: "Potty Breaks")
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Payment section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Payment")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("$\(String(format: "%.2f", walk.cost))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Action to view receipt
                            }) {
                                Text("View Receipt")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Activities
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Activities")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(walk.activities, id: \.self) { activity in
                                    ActivityChip(activity: activity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Comments
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Comments")
                            .font(.headline)
                        
                        Text(walk.comments)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Rating section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Rating")
                            .font(.headline)
                        
                        HStack {
                            StarsView(rating: walk.rating)
                            Text("(\(String(format: "%.1f", walk.rating)))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Photos if available
                    if !walk.photos.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Photos")
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(walk.photos, id: \.self) { photo in
                                        WalkPhotoView(imageName: photo)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Map of route
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Walk Route")
                            .font(.headline)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                            
                            Image(systemName: "map")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("Map View")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .offset(y: 40)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarTitle("Walk Details", displayMode: .inline)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct StarsView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" :
                       (index == Int(rating) && rating.truncatingRemainder(dividingBy: 1) >= 0.5 ? "star.leadinghalf.filled" : "star"))
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct StatCard: View {
    let iconName: String
    let value: String
    let unit: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ActivityChip: View {
    let activity: String
    
    var body: some View {
        Text(activity)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(20)
    }
}

struct WalkPhotoView: View {
    let imageName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
            
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.gray)
        }
    }
}

// Model
struct Walk: Identifiable {
    let id: UUID
    let date: Date
    let dogName: String
    let partnerName: String
    let partnerImage: String
    let duration: Int // minutes
    let distance: Double // miles
    let cost: Double
    let pottyBreaks: Int
    let activities: [String]
    let comments: String
    let rating: Double
    let photos: [String]
}

struct PastWalksView_Previews: PreviewProvider {
    static var previews: some View {
        PastWalksView()
    }
}
