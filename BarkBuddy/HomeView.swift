//
//  ClaudeUI.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/7/25.
//

import SwiftUI

struct HomeV: View {
    @State private var searchText = ""
    @State private var selectedTab = "home"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .foregroundColor(Color.teal)
                        .font(.system(size: 24))
                    Text("PawPals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.teal)
                }
                
                Spacer()
                
                Image(systemName: "bell")
                    .foregroundColor(Color.gray)
                    .font(.system(size: 20))
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Main Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello, Emma!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(UIColor.darkGray))
                        Text("Find a trusted walker for Max today")
                            .foregroundColor(Color.gray)
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
                    
                    // Quick Options
                    HStack(spacing: 12) {
                        // Quick Walk Option
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .foregroundColor(Color.teal)
                                Text("Quick Walk")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.teal.opacity(0.8))
                            }
                            Text("Find walkers available now")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.teal.opacity(0.1))
                        .cornerRadius(15)
                        
                        // Schedule Option
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color.blue)
                                Text("Schedule")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.blue.opacity(0.8))
                            }
                            Text("Book walks in advance")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                    }
                    
                    // Walker Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Walkers Nearby")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(UIColor.darkGray))
                        
                        // Walker Card 1
                        WalkerCard(
                            name: "Sarah J.",
                            rating: 4.9,
                            distance: 0.8,
                            availability: "Available today",
                            price: "$18/30 min"
                        )
                        
                        // Walker Card 2
                        WalkerCard(
                            name: "Alex M.",
                            rating: 4.8,
                            distance: 1.2,
                            availability: "Available tomorrow",
                            price: "$20/30 min"
                        )
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            
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
                }
                
                TabButton(image: "message", title: "Messages", isSelected: selectedTab == "messages") {
                    selectedTab = "messages"
                }
                
                TabButton(image: "person", title: "Profile", isSelected: selectedTab == "profile") {
                    selectedTab = "profile"
                }
            }
            .padding(.top, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
        .edgesIgnoringSafeArea(.bottom)
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

struct new_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview{
    ClaudeUI()
}
