import SwiftUI

struct DogWalker: Identifiable {
    let id = UUID()
    let name: String
    let profileImage: String
    let rating: Double
    let reviews: Int
    let isBackgroundChecked: Bool
    let bio: String
    let rate: String
    let distance: String
    let specialties: [String]
    let availability: String
}

struct DogWalkerProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var dogWalkers: [DogWalker] = [
        DogWalker(
            name: "Sarah Johnson",
            profileImage: "sarah_profile",
            rating: 4.8,
            reviews: 124,
            isBackgroundChecked: true,
            bio: "Professional dog trainer with 5+ years experience. I love all breeds and specialize in high-energy dogs.",
            rate: "$18/walk",
            distance: "0.8 miles away",
            specialties: ["High-energy dogs", "Puppy training", "Senior dogs"],
            availability: "Weekdays 9am-5pm"
        ),
        DogWalker(
            name: "Marcus Rivera",
            profileImage: "marcus_profile",
            rating: 4.9,
            reviews: 87,
            isBackgroundChecked: true,
            bio: "Former vet tech who loves spending time with furry friends. I'm reliable, punctual, and great with anxious dogs.",
            rate: "$20/walk",
            distance: "1.2 miles away",
            specialties: ["Anxious dogs", "Medication administration", "Dog first aid"],
            availability: "Evenings and weekends"
        ),
        DogWalker(
            name: "Emily Chen",
            profileImage: "emily_profile",
            rating: 4.7,
            reviews: 56,
            isBackgroundChecked: true,
            bio: "Part-time dog walker and full-time dog lover! I'm a marathon runner, so I'm great with active dogs who need longer walks.",
            rate: "$15/walk",
            distance: "0.5 miles away",
            specialties: ["Long walks", "Running with dogs", "Basic training"],
            availability: "Mornings and weekends"
        )
    ]
    
    @State private var skippedWalkers: [DogWalker] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showRatingModal = false
    @State private var selectedDogWalker: DogWalker?
    @State private var userRating: Int = 0
    @State private var showMessageView = false
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
                
                Text("Dog Walkers")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 8)
                
                Spacer()
                
                Button(action: {
                    // Filter action
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                }
            }
            .padding()
            
            // Skipped walkers list
            if !skippedWalkers.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recently Skipped")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(skippedWalkers) { walker in
                                Button(action: {
                                    // Add back to main stack
                                    dogWalkers.insert(walker, at: currentIndex)
                                    if let index = skippedWalkers.firstIndex(where: { $0.id == walker.id }) {
                                        skippedWalkers.remove(at: index)
                                    }
                                }) {
                                    VStack {
                                        Image(walker.profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                        
                                        Text(walker.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 80)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            
            ZStack {
                // Walker cards
                ZStack {
                    ForEach(dogWalkers.indices.reversed(), id: \.self) { index in
                        if index >= currentIndex && index <= currentIndex + 2 {
                            let isCurrentCard = index == currentIndex
                            
                            DogWalkerCard(
                                dogWalker: dogWalkers[index],
                                onRate: {
                                    selectedDogWalker = dogWalkers[index]
                                    showRatingModal = true
                                }
                            )
                            .offset(isCurrentCard ? offset : .zero)
                            .scaleEffect(isCurrentCard ? 1.0 : 0.9)
                            .opacity(isCurrentCard ? 1.0 : 0.7)
                            .rotationEffect(.degrees(isCurrentCard ? Double(offset.width / 20) : 0))
                            .gesture(
                                isCurrentCard ?
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        withAnimation(.spring()) {
                                            handleSwipe(width: gesture.translation.width)
                                        }
                                    } : nil
                            )
                        }
                    }
                }
                
                // Action buttons
                VStack {
                    Spacer()
                    HStack(spacing: 50) {
                        Button(action: {
                            withAnimation(.spring()) {
                                offset = CGSize(width: -500, height: 0)
                                handleSwipe(width: -500)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                offset = CGSize(width: 500, height: 0)
                                handleSwipe(width: 500)
                                // Open message view when swiping right
                                if currentIndex < dogWalkers.count {
                                    selectedDogWalker = dogWalkers[currentIndex]
                                    showMessageView = true
                                }
                            }
                        }) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .padding(.top)
            
            // Rating Modal
            if showRatingModal, let walker = selectedDogWalker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showRatingModal = false
                    }
                
                RatingModalView(
                    dogWalker: walker,
                    rating: $userRating,
                    isPresented: $showRatingModal
                )
                .transition(.move(edge: .bottom))
            }
            
            // Message View
            if showMessageView, let walker = selectedDogWalker {
                MessageView(dogWalker: walker, isPresented: $showMessageView)
                    .transition(.move(edge: .trailing))
            }
        }
        .navigationBarHidden(true)
    }
    
    private func handleSwipe(width: CGFloat) {
        // Determine swipe direction and threshold
        if width > 150 {
            // Right swipe (like)
            if currentIndex < dogWalkers.count - 1 {
                currentIndex += 1
            }
        } else if width < -150 {
            // Left swipe (dislike)
            if currentIndex < dogWalkers.count {
                // Add to skipped walkers
                skippedWalkers.insert(dogWalkers[currentIndex], at: 0)
                // Limit skipped walkers list to 10
                if skippedWalkers.count > 10 {
                    skippedWalkers.removeLast()
                }
                
                if currentIndex < dogWalkers.count - 1 {
                    currentIndex += 1
                }
            }
        }
        
        // Reset offset
        offset = .zero
    }
}

struct DogWalkerCard: View {
    let dogWalker: DogWalker
    let onRate: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image with reduced size
            Image(dogWalker.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width - 40, height: 450) // Reduced height
                .cornerRadius(20)
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(
                    colors: [Color.clear, Color.black.opacity(0.8)]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: UIScreen.main.bounds.width - 40, height: 450) // Reduced height
            .cornerRadius(20)
            
            // Profile info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(dogWalker.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if dogWalker.isBackgroundChecked {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.blue)
                            Text("Verified")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                HStack {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", dogWalker.rating))
                            .foregroundColor(.white)
                        Text("(\(dogWalker.reviews))")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: onRate) {
                        Text("Rate")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                // Bio
                Text(dogWalker.bio)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Tags
                HStack {
                    Text(dogWalker.distance)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                    
                    Text(dogWalker.rate)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                }
                
                // Swipe instructions
                HStack {
                    Spacer()
                    Text("Swipe left to pass • Swipe right to connect")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 5)
            }
            .padding(20)
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 450) // Reduced height
        .shadow(radius: 10)
    }
}

struct RatingModalView: View {
    let dogWalker: DogWalker
    @Binding var rating: Int
    @Binding var isPresented: Bool
    @State private var reviewText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Rate \(dogWalker.name)")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            // Profile image
            Image(dogWalker.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            // Star rating
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
            
            // Review text field
            TextField("Write your review...", text: $reviewText)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            // Submit button
            Button(action: {
                // Submit rating logic
                isPresented = false
            }) {
                Text("Submit Rating")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
}

struct MessageView: View {
    let dogWalker: DogWalker
    @Binding var isPresented: Bool
    @State private var messageText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Spacer()
                
                Text(dogWalker.name)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    // View profile
                }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 1)
            
            // Messages area
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // Connection message
                    VStack(spacing: 10) {
                        Image(dogWalker.profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        Text("You matched with \(dogWalker.name)!")
                            .font(.headline)
                        
                        Text("Start a conversation to discuss your dog walking needs")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                    
                    // Conversation would go here
                    
                    Spacer()
                }
                .padding()
            }
            
            // Message input
            HStack(spacing: 15) {
                TextField("Message...", text: $messageText)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: {
                    // Send message logic
                    if !messageText.isEmpty {
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 1)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Previews

#Preview {
    DogWalkerProfileView()
}

#Preview("Dog Walker Card") {
    DogWalkerCard(
        dogWalker: DogWalker(
            name: "Sarah Johnson",
            profileImage: "sarah_profile",
            rating: 4.8,
            reviews: 124,
            isBackgroundChecked: true,
            bio: "Professional dog trainer with 5+ years experience. I love all breeds and specialize in high-energy dogs.",
            rate: "$18/walk",
            distance: "0.8 miles away",
            specialties: ["High-energy dogs", "Puppy training", "Senior dogs"],
            availability: "Weekdays 9am-5pm"
        ),
        onRate: {}
    )
}

#Preview("Rating Modal") {
    RatingModalView(
        dogWalker: DogWalker(
            name: "Marcus Rivera",
            profileImage: "marcus_profile",
            rating: 4.9,
            reviews: 87,
            isBackgroundChecked: true,
            bio: "Former vet tech who loves spending time with furry friends.",
            rate: "$20/walk",
            distance: "1.2 miles away",
            specialties: ["Anxious dogs", "Medication administration"],
            availability: "Evenings and weekends"
        ),
        rating: .constant(4),
        isPresented: .constant(true)
    )
}

#Preview("Message View") {
    MessageView(
        dogWalker: DogWalker(
            name: "Emily Chen",
            profileImage: "emily_profile",
            rating: 4.7,
            reviews: 56,
            isBackgroundChecked: true,
            bio: "Part-time dog walker and full-time dog lover!",
            rate: "$15/walk",
            distance: "0.5 miles away",
            specialties: ["Long walks", "Running with dogs"],
            availability: "Mornings and weekends"
        ),
        isPresented: .constant(true)
    )
}
