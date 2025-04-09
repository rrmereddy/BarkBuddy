//
//  UserDuringWalkView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/9/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct PetOwnerWalkView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var walkDuration: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var walkDistance = 0.0
    @State private var walkPath: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        CLLocationCoordinate2D(latitude: 37.7752, longitude: -122.4189),
        CLLocationCoordinate2D(latitude: 37.7758, longitude: -122.4180),
        CLLocationCoordinate2D(latitude: 37.7765, longitude: -122.4175)
    ]
    
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
                
                Text("Max's Walk")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.darkGray))
                
                Spacer()
                
                Button(action: {
                    // Settings or help action
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
                    // Map View - Top section
                    ZStack(alignment: .topTrailing) {
                        Map(coordinateRegion: $region, annotationItems: [WalkAnnotation(coordinate: walkPath.first ?? region.center)]) { item in
                            MapAnnotation(coordinate: item.coordinate) {
                                VStack {
                                    Image(systemName: "figure.walk")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.teal)
                                        .clipShape(Circle())
                                        .shadow(radius: 2)
                                    
                                    Text("Sarah & Max")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .padding(3)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .shadow(radius: 1)
                                }
                            }
                        }
                        .frame(height: 220)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
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
                    
                    // Walker Info Card
                    VStack {
                        HStack(alignment: .center, spacing: 12) {
                            // Walker Image
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("👱‍♀️")
                                        .font(.title)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sarah")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.darkGray))
                                
                                Text("Professional Dog Walker")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                                    
                                // Adding walker rating
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text("4.9")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("(143 walks)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Contact walker action
                            }) {
                                Image(systemName: "phone.fill")
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
                    
                    // Walk stats card
                    VStack(spacing: 0) {
                        // Section title
                        HStack {
                            Text("Walk Progress")
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
                                value: "2",
                                label: "Potty Breaks"
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Activity timeline
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Live Updates")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.darkGray))
                            
                            Spacer()
                            
                            Text("Real-time")
                                .font(.caption)
                                .padding(4)
                                .padding(.horizontal, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            TimelineItemView(
                                time: "2:32 PM",
                                activity: "Max had a potty break",
                                icon: "checkmark.circle.fill",
                                iconColor: .green
                            )
                            
                            TimelineSeparator()
                            
                            TimelineItemView(
                                time: "2:28 PM",
                                activity: "Sarah sent a photo",
                                icon: "photo.fill",
                                iconColor: .blue
                            )
                            
                            TimelineSeparator()
                            
                            TimelineItemView(
                                time: "2:15 PM",
                                activity: "Walk started",
                                icon: "figure.walk",
                                iconColor: .teal
                            )
                        }
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Photo section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Photos")
                            .font(.headline)
                            .foregroundColor(Color(UIColor.darkGray))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(1...3, id: \.self) { _ in
                                    ZStack(alignment: .bottomTrailing) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                Image(systemName: "pawprint.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 30))
                                            )
                                        
                                        Text("2:28 PM")
                                            .font(.caption2)
                                            .padding(4)
                                            .background(Color.black.opacity(0.6))
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                            .padding(6)
                                    }
                                }
                                
                                // See all photos button
                                Button(action: {
                                    // View all photos
                                }) {
                                    VStack {
                                        Image(systemName: "photo.stack.fill")
                                            .font(.system(size: 24))
                                        Text("See All")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.teal)
                                    .frame(width: 80, height: 120)
                                    .background(Color.teal.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Action button
                    Button(action: {
                        // Contact walker
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                            Text("Message Sarah")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.teal)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 16)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var formattedDuration: String {
        let minutes = Int(walkDuration) / 60
        let seconds = Int(walkDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            walkDuration += 1
            
            // Simulate distance increase
            if walkDuration.truncatingRemainder(dividingBy: 15) == 0 {
                walkDistance += 0.02
            }
        }
    }
}

// Helper model for map annotations
struct User_WalkAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Helper view for walk stats
struct User_WalkStatView: View {
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
struct User_TimelineItemView: View {
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

struct User_TimelineSeparator: View {
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

// Preview provider
struct PetOwnerWalkView_Previews: PreviewProvider {
    static var previews: some View {
        PetOwnerWalkView()
    }
}
