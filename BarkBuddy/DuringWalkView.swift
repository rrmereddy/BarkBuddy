//
//  DuringWalkView.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/7/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct DuringWalkView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var walkDuration: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isWalking = true
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
                
                Text("Walk in Progress")
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
            
            // Map View
            ZStack(alignment: .bottom) {
                // Map
                Map(coordinateRegion: $region, annotationItems: [WalkAnnotation(coordinate: walkPath.first ?? region.center)]) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.teal)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                            
                            Text("Max")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 1)
                        }
                    }
                }
                .overlay(
                    Path { path in
                        guard let firstCoord = walkPath.first else { return }
                        
                        path.move(to: CGPoint(x: 0, y: 0)) // Placeholder - will be replaced by map points
                        
                        for coordinate in walkPath {
                            path.addLine(to: CGPoint(x: 0, y: 0)) // Placeholder - will be replaced by map points
                        }
                    }
                    .stroke(Color.teal, lineWidth: 4)
                    .opacity(0.7)
                )
                .edgesIgnoringSafeArea(.all)
                
                // Walk Stats Card
                VStack(spacing: 0) {
                    // Dog and walker info
                    HStack(alignment: .center, spacing: 12) {
                        // Dog Image
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("🐶")
                                    .font(.title)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Max with Sarah")
                                .font(.headline)
                                .foregroundColor(Color(UIColor.darkGray))
                            
                            Text("Walk in progress")
                                .font(.subheadline)
                                .foregroundColor(Color.teal)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Contact walker action
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
                    
                    Divider()
                    
                    // Walk stats
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
                    
                    // Action Button
                    Button(action: {
                        isWalking.toggle()
                    }) {
                        Text(isWalking ? "End Walk" : "Resume Walk")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(isWalking ? Color.red : Color.teal)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                }
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        }
        .onAppear {
            startTimer()
            
            // In a real app, this would be replaced with actual location tracking
            // via CLLocationManager and would update the map accordingly
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
            if isWalking {
                walkDuration += 1
                
                // Simulate distance increase
                // In a real app, this would calculate actual distance from GPS coordinates
                if walkDuration.truncatingRemainder(dividingBy: 15) == 0 {
                    walkDistance += 0.02
                }
            }
        }
    }
}

// Helper model for map annotations
struct WalkAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Helper view for walk stats
struct WalkStatView: View {
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

// Extension to apply rounded corners to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Preview provider



#Preview {
    DuringWalkView()
}
