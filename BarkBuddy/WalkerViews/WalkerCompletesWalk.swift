//
//  WalkerCompletesWalk.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/10/25.
//

import SwiftUI

struct WalkerCompletesWalk: View {
    // Walk details
    let customerName = "Sarah"
    let dogName = "Buddy"
    let walkDuration = "30 min"
    let walkDistance = "1.2 miles"
    let walkDate = "April 10, 2025"
    let walkTime = "3:30 PM"
    let basePayment = 15.00
    let tipAmount = 3.00
    
    // Optional received review and rating
    let receivedRating: Int? = 5 // nil if no rating was given
    let receivedReview: String? = "Alex was amazing with Buddy! Very attentive and sent cute photos during the walk. Will definitely book again!" // nil if no review was given
    
    // State for giving ratings and reviews
    @State private var ownerRating: Int = 0
    @State private var petRating: Int = 0
    @State private var ownerReview: String = ""
    @State private var petReview: String = ""
    @State private var showEarningsSummary = false
    @State private var showTodayWalks = false
    @State private var showConfetti = true
    @State private var hasSubmittedReviews = false
    
    // Computed properties
    var totalPayment: Double {
        basePayment + tipAmount
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(spacing: 20) {
                    // Success banner
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Walk Completed!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Great job with \(dogName)'s walk")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 30)
                    
                    // Walk Details Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Walk Details")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Customer and dog info
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Text(String(customerName.prefix(1)))
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(customerName)'s \(dogName)")
                                    .fontWeight(.medium)
                                Text("\(walkDate) • \(walkTime)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Walk stats
                        HStack {
                            VStack {
                                Text(walkDuration)
                                    .font(.headline)
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 30)
                            
                            VStack {
                                Text(walkDistance)
                                    .font(.headline)
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Received Rating and Review Card (if available)
                    if receivedRating != nil || receivedReview != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Customer Feedback")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Rating
                            if let rating = receivedRating {
                                HStack {
                                    Text("Rating:")
                                        .foregroundColor(.gray)
                                    
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= rating ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.subheadline)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            // Review
                            if let review = receivedReview {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Review:")
                                        .foregroundColor(.gray)
                                    
                                    Text("\"\(review)\"")
                                        .italic()
                                        .padding(.vertical, 6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Payment Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Earnings")
                                .font(.headline)
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Payment breakdown
                        VStack(spacing: 12) {
                            HStack {
                                Text("Base pay")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(String(format: "%.2f", basePayment))")
                            }
                            
                            HStack {
                                Text("Tip")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$\(String(format: "%.2f", tipAmount))")
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Total earnings")
                                    .fontWeight(.bold)
                                Spacer()
                                Text("$\(String(format: "%.2f", totalPayment))")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Rate Pet Owner & Pet
                    if !hasSubmittedReviews {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Leave Your Feedback")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            Divider()
                            
                            // Rate Pet Owner
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rate \(customerName):")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= ownerRating ? "star.fill" : "star")
                                            .foregroundColor(star <= ownerRating ? .yellow : .gray)
                                            .font(.title3)
                                            .onTapGesture {
                                                ownerRating = star
                                            }
                                    }
                                    Spacer()
                                }
                                
                                TextField("Comments about \(customerName) (optional)", text: $ownerReview, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.bottom, 16)
                            
                            // Rate Pet
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rate \(dogName):")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= petRating ? "star.fill" : "star")
                                            .foregroundColor(star <= petRating ? .yellow : .gray)
                                            .font(.title3)
                                            .onTapGesture {
                                                petRating = star
                                            }
                                    }
                                    Spacer()
                                }
                                
                                TextField("Comments about \(dogName) (optional)", text: $petReview, axis: .vertical)
                                    .lineLimit(3...5)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Submit reviews
                                hasSubmittedReviews = true
                            }) {
                                Text("Submit Feedback")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    } else {
                        // Feedback submitted confirmation
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text("Thank you for your feedback!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Payment status
                    VStack(spacing: 8) {
                        Text("Payment will be deposited to your account")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Standard deposit (2-3 business days)")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.vertical, 10)
                }
                .padding()
                
                // Confetti overlay when page opens
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .onAppear {
                            // Auto hide confetti after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showConfetti = false
                                }
                            }
                        }
                }
            }
        }
        .navigationTitle("Walk Complete")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // Handle share action
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        // Report an issue
                    }) {
                        Label("Report an issue", systemImage: "exclamationmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                // Primary action button
                Button(action: {
                    showTodayWalks = true
                }) {
                    Text("See Today's Walks")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                // Secondary action button
                Button(action: {
                    showEarningsSummary = true
                }) {
                    Text("View Earnings Summary")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color.white.shadow(radius: 2))
        }
    }
}

// Confetti Animation View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    init() {
        // Create initial confetti pieces
        var pieces: [ConfettiPiece] = []
        for _ in 0..<100 {
            pieces.append(ConfettiPiece())
        }
        _confettiPieces = State(initialValue: pieces)
    }
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(piece.position)
                    .opacity(piece.opacity)
                    .rotationEffect(Angle(degrees: piece.rotation))
            }
        }
        .onAppear {
            animateConfetti()
        }
    }
    
    func animateConfetti() {
        for i in 0..<confettiPieces.count {
            // Animate each piece to fall down and fade out
            withAnimation(Animation.easeOut(duration: Double.random(in: 1.0...3.0))) {
                let newY = UIScreen.main.bounds.height + 50
                let newX = confettiPieces[i].position.x + CGFloat.random(in: -100...100)
                confettiPieces[i].position.y = newY
                confettiPieces[i].position.x = newX
                confettiPieces[i].opacity = 0
                confettiPieces[i].rotation += Double.random(in: 180...720)
            }
        }
    }
}

// Model for confetti pieces
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var rotation: Double
    var size: CGFloat
    var opacity: Double = 1.0
    
    init() {
        // Random starting position from top of screen
        let screenWidth = UIScreen.main.bounds.width
        position = CGPoint(
            x: CGFloat.random(in: 0...screenWidth),
            y: CGFloat.random(in: -50...100)
        )
        
        // Random color from festive palette
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        color = colors.randomElement()!
        
        // Random initial rotation
        rotation = Double.random(in: 0...360)
        
        // Random size for variety
        size = CGFloat.random(in: 5...12)
    }
}

struct WalkerCompletionScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalkerCompletesWalk()
        }
    }
}
