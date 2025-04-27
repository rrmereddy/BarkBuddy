//
//  ClaudeUI.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/7/25.
//

import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedTab = "home"
    @State private var showProfileModal = false
    @State private var showAllWalkersModal = false
    @State private var showFutureWalksModal = false
    @State private var showProfileDogWalkerModal = false
    @State private var showPastWalksModal = false
    @State private var showAcceptedChatsOwner = false

    
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(Color.teal)
                        .font(.system(size: 24))
                    Text("BarkBuddy")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.teal)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Image(systemName: "bell")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 20))
                    
                    // Added profile button
                    Button(action: {
                        showProfileModal = true
                    }) {
                        Image(systemName: "person.circle")
                            .foregroundColor(Color.teal)
                            .font(.system(size: 22))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Main Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome Section - with profile icon aligned
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color(UIColor.darkGray))
                            Text("Find a trusted walker today")
                                .foregroundColor(Color.gray)
                        }
                        
                        Spacer()
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.gray)
                        TextField("Search for dog walkers nearby...", text: $searchText)
                            .foregroundColor(Color(UIColor.darkGray))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    
                    // Quick Options - now in vertical layout
                    VStack(spacing: 12) {
                        // Quick Walk Option - Updated with ProfileDogWalker modal action
                        Button(action: {
                            showProfileDogWalkerModal = true  // Open the ProfileDogWalker modal
                        }) {
                            QuickOptionButton(
                                icon: "clock",
                                title: "Quick Walk",
                                description: "Find walkers available now",
                                color: .teal
                            )
                        }
                        
                        // Schedule Option
                        Button(action: {
                            showFutureWalksModal = true
                        }) {
                            QuickOptionButton(
                                icon: "calendar",
                                title: "Schedule",
                                description: "See your upcoming walks",
                                color: .blue
                            )
                        }
                        
                        // Past Walks Option (New)
                        Button(action: {
                            showPastWalksModal = true
                        }) {
                            QuickOptionButton(
                                icon: "clock.arrow.circlepath",
                                title: "Past Walks",
                                description: "View your walking history",
                                color: .purple
                            )
                        }
                    }
                    
                    // Recent Walkers (Renamed from Top Walkers Nearby)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Walkers")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(UIColor.darkGray))
                            
                            Spacer()
                            
                            // Expand button
                            Button(action: {
                                showPastWalksModal = true
                            }) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(Color.teal)
                            }
                        }
                        
                        // Recent Walker Card 1
                        WalkerCard(
                            name: "Sarah J.",
                            rating: 4.9,
                            distance: 0.8,
                            availability: "Last walked: Yesterday",
                            price: "$18/30 min"
                        )
                        
                        // Recent Walker Card 2
                        WalkerCard(
                            name: "Alex M.",
                            rating: 4.8,
                            distance: 1.2,
                            availability: "Last walked: April 20",
                            price: "$20/30 min"
                        )
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .sheet(isPresented: $showProfileModal) {
                Text("Profile Editor")
                    .font(.title)
                    .padding()
                // Your profile editing view would go here
            }
            .sheet(isPresented: $showAllWalkersModal) {
            }
            .sheet(isPresented: $showFutureWalksModal) {
                FutureWalksView()
            }
            .sheet(isPresented: $showProfileDogWalkerModal) {
                DogWalkerProfileView()  // Present the ProfileDogWalker view
            }
            .sheet(isPresented: $showPastWalksModal) {
                PastWalksView()  // Connect to your existing PastWalksView
            }
            .sheet(isPresented: $showAcceptedChatsOwner) {
                BligView()
            }
            
            // Bottom Navigation
            HStack(spacing: 0) {
                TabButton(image: "house", title: "Home", isSelected: selectedTab == "home") {
                    selectedTab = "home"
                }
                
                TabButton(image: "magnifyingglass", title: "Search", isSelected: selectedTab == "search") {
                    selectedTab = "search"
                }
                
                TabButton(image: "calendar", title: "Bookings", isSelected: selectedTab == "bookings") {
                    selectedTab = "bookings"
                    showFutureWalksModal = true
                }
                
                TabButton(image: "message", title: "Messages", isSelected: selectedTab == "messages") {
                    selectedTab = "messages"
                    showAcceptedChatsOwner = true
                }
                
                TabButton(image: "person", title: "Settings", isSelected: selectedTab == "settings") {
                    selectedTab = "settings"
                }
            }
            .padding(.top, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Revised QuickOptionButton for vertical layout
struct QuickOptionButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon on the left
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(12)
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.darkGray))
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            // Arrow icon
            Image(systemName: "chevron.right")
                .foregroundColor(color)
                .font(.system(size: 14))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct new_WalkerCard: View {
    let name: String
    let rating: Double
    let distance: Double
    let availability: String
    let price: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 64, height: 64)
                .overlay(
                    Text("\(name.prefix(1))")
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                )
            
            // Walker Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(UIColor.darkGray))
                    
                    Spacer()
                    
                    // Rating
                    HStack(spacing: 2) {
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(Color.yellow)
                        Text("★")
                            .foregroundColor(Color.yellow)
                    }
                }
                
                // Distance
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                    Text("\(String(format: "%.1f", distance)) miles away")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                
                // Availability & Price
                Text("\(availability) · \(price)")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct new_TabButton: View {
    let image: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: image)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.teal : Color.gray)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color.teal : Color.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview{
    HomeView()
}
