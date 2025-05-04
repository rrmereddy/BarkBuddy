//
//  PastWalksView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/12/25.
//

import SwiftUI

struct PastWalksView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    // Sample data
    let walks = Walk.sampleWalks
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header to ensure consistency
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("Past Walks")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Spacer()
                    
                    // Balance the header with empty space
                    Text("      ")
                        .padding(.trailing)
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 1)
                
                // The list of past walks
                List {
                    ForEach(walks) { walk in
                        NavigationLink(destination: SimpleWalkDetailView(walk: walk)) {
                            SimpleWalkRow(walk: walk)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Ultra-simple walk row for maximum performance
struct SimpleWalkRow: View {
    let walk: Walk
    
    // Pre-calculate date string
    private let dateString: String
    
    init(walk: Walk) {
        self.walk = walk
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        self.dateString = formatter.string(from: walk.date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Simple circular avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Text(String(walk.partnerName.prefix(1)))
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            // Walk information
            VStack(alignment: .leading, spacing: 4) {
                Text("\(walk.dogName) with \(walk.partnerName)")
                    .font(.system(size: 16, weight: .medium))
                
                Text(dateString)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Label("\(walk.duration) min", systemImage: "clock")
                        .font(.system(size: 12))
                    
                    Label(String(format: "%.1f mi", walk.distance), systemImage: "figure.walk")
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// Extremely simplified walk detail view focused on performance
struct SimpleWalkDetailView: View {
    let walk: Walk
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoadingDetails = true
    
    // Pre-compute formatted strings
    private let dateString: String
    private let costString: String
    
    init(walk: Walk) {
        self.walk = walk
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        self.dateString = dateFormatter.string(from: walk.date)
        
        self.costString = String(format: "$%.2f", walk.cost)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header section with walk info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Walk with \(walk.partnerName)")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.bottom, 2)
                    
                    Text(walk.dogName)
                        .font(.system(size: 18, weight: .medium))
                    
                    Text(dateString)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    // Stats summary
                    HStack(spacing: 12) {
                        StatBadge(value: "\(walk.duration) min", icon: "clock", color: .blue)
                        StatBadge(value: String(format: "%.1f mi", walk.distance), icon: "figure.walk", color: .green)
                        StatBadge(value: "\(walk.pottyBreaks)", icon: "pawprint.fill", color: .orange)
                        StatBadge(value: costString, icon: "dollarsign.circle", color: .green)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                Divider()
                
                // Walk details - only show after loading delay to ensure UI is responsive
                if !isLoadingDetails {
                    WalkDetailsContent(walk: walk)
                } else {
                    VStack {
                        Spacer(minLength: 100)
                        ProgressView("Loading walk details...")
                        Spacer(minLength: 100)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 16)
        }
        .onAppear {
            // Use a slight artificial delay to ensure the UI renders first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoadingDetails = false
            }
        }
        .navigationBarTitle("Walk Details", displayMode: .inline)
    }
}

// Separate the detail content for better performance
struct WalkDetailsContent: View {
    let walk: Walk
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Activities section
            VStack(alignment: .leading) {
                SectionHeader(title: "Activities")
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(walk.activities, id: \.self) { activity in
                            Text(activity)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 16)
            
            Divider()
            
            // Comments section
            VStack(alignment: .leading) {
                SectionHeader(title: "Comments")
                
                Text(walk.comments)
                    .font(.system(size: 16))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
            .padding(.vertical, 16)
            
            Divider()
            
            // Rating section
            VStack(alignment: .leading) {
                SectionHeader(title: "Rating")
                
                HStack {
                    SimpleStarRating(rating: walk.rating)
                    
                    Text("(\(String(format: "%.1f", walk.rating)))")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.vertical, 16)
            
            // Only show photos section if there are photos
            if !walk.photos.isEmpty {
                Divider()
                
                VStack(alignment: .leading) {
                    SectionHeader(title: "Photos")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<min(walk.photos.count, 5), id: \.self) { index in
                                SimplePlaceholderImage()
                                    .frame(width: 120, height: 120)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 16)
            }
            
            // Map placeholder
            Divider()
            
            VStack(alignment: .leading) {
                SectionHeader(title: "Walk Route")
                
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 180)
                        .cornerRadius(12)
                    
                    Label("Map View", systemImage: "map")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding(.vertical, 16)
            
            // Add some space at the bottom for scrolling
            Spacer(minLength: 40)
        }
    }
}

// Ultra-simple section header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
}

// Simple stat badge
struct StatBadge: View {
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

// Super simple star rating
struct SimpleStarRating: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Image(systemName: self.starType(for: i))
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        if Double(index) + 0.5 < rating {
            return "star.fill"
        } else if Double(index) + 0.5 >= rating && Double(index) < rating {
            return "star.leadinghalf.fill"
        } else {
            return "star"
        }
    }
}

// Simple placeholder for images
struct SimplePlaceholderImage: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
            
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(.gray)
        }
    }
}

// Model with static sample data
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
    
    // Static sample data
    static let sampleWalks = [
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
}

struct PastWalksView_Previews: PreviewProvider {
    static var previews: some View {
        PastWalksView()
    }
}


