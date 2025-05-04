import SwiftUI
import FirebaseFirestore // Make sure Firestore is imported

// Restore the original DogWalker struct definition
struct DogWalker: Identifiable, Equatable {
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
    let firebaseDocId: String? // Keep the Firestore document ID

    static func == (lhs: DogWalker, rhs: DogWalker) -> Bool {
        lhs.id == rhs.id
    }
}

// Minimal struct to help parse availability days minimally
struct AvailabilityDayMinimal: Codable {
    let isAvailable: Bool?
}


public struct DogWalkerProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    let userID: String
    @State private var dogWalkers: [DogWalker] = []
    @State private var skippedWalkers: [DogWalker] = []
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showRatingModal = false
    @State private var selectedDogWalker: DogWalker?
    @State private var userRating: Int = 0
    @State private var showMessageView = false
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    // Access Firestore instance
    private var db = Firestore.firestore()
    
    public init(userID: String) {
        self.userID = userID
        print("DogWalkerProfileView initialized with userID: \(userID)")
        // Could add validation here if needed
    }

    public var body: some View {
        VStack {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "arrow.left").font(.system(size: 22)).foregroundColor(.blue)
                }
                Text("Dog Walkers").font(.largeTitle).fontWeight(.bold).padding(.leading, 8)
                Spacer()
                Button(action: { /* Filter action */ }) {
                    Image(systemName: "slider.horizontal.3").font(.title2)
                }
            }
            .padding()

            // Skipped walkers list
            if !skippedWalkers.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recently Skipped").font(.headline).padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(skippedWalkers) { walker in
                                Button(action: {
                                    dogWalkers.insert(walker, at: currentIndex)
                                    if let index = skippedWalkers.firstIndex(where: { $0.id == walker.id }) {
                                        skippedWalkers.remove(at: index)
                                    }
                                }) {
                                    VStack {
                                        Image(walker.profileImage).resizable().aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60).clipShape(Circle()).foregroundColor(.gray)
                                        Text(walker.name).font(.caption).lineLimit(1)
                                    }.frame(width: 80)
                                }
                            }
                        }.padding(.horizontal)
                    }
                }.padding(.bottom)
            }

            // Main Content Area
            ZStack {
                if isLoading {
                    ProgressView("Finding Walkers...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)").foregroundColor(.red).padding()
                } else if dogWalkers.isEmpty && currentIndex >= dogWalkers.count {
                    Text("No more dog walkers found.").foregroundColor(.gray).padding()
                } else {
                    // Walker cards stack
                    ZStack {
                        ForEach(Array(dogWalkers.enumerated()), id: \.element.id) { index, walker in
                            if abs(index - currentIndex) <= 2 {
                                let isCurrentCard = index == currentIndex
                                DogWalkerCard(
                                    dogWalker: walker,
                                    onRate: {
                                        selectedDogWalker = walker
                                        showRatingModal = true
                                    }
                                )
                                .zIndex(Double(-index))
                                .offset(x: isCurrentCard ? offset.width : 0, y: isCurrentCard ? offset.height : CGFloat(min(index - currentIndex, 2)) * 10)
                                .scaleEffect(isCurrentCard ? 1.0 : max(1.0 - (CGFloat(abs(index - currentIndex)) * 0.05), 0.9))
                                .opacity(isCurrentCard ? 1.0 : (index > currentIndex ? (1.0 - (CGFloat(abs(index - currentIndex)-1) * 0.3)) : 0))
                                .rotationEffect(.degrees(isCurrentCard ? Double(offset.width / 20) : 0))
                                .gesture(
                                    isCurrentCard ?
                                    DragGesture()
                                        .onChanged { gesture in
                                            offset = gesture.translation
                                        }
                                        .onEnded { gesture in
                                            withAnimation(.spring()) {
                                                // Pass the specific walker to handleSwipe
                                                handleSwipe(width: gesture.translation.width, walker: walker)
                                            }
                                        } : nil
                                )
                            }
                        }
                    } // End Card ZStack

                    // Action buttons
                    VStack {
                         Spacer()
                         HStack(spacing: 50) {
                             Button(action: { // SKIP BUTTON
                                 if currentIndex < dogWalkers.count {
                                      let walkerToSkip = dogWalkers[currentIndex]
                                      withAnimation(.spring()) {
                                          offset = CGSize(width: -500, height: 0)
                                          handleSwipe(width: -500, walker: walkerToSkip) // Trigger swipe logic
                                      }
                                 }
                             }) {
                                 Image(systemName: "xmark").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                     .padding(20).background(Color.red).clipShape(Circle())
                             }.disabled(currentIndex >= dogWalkers.count)

                             Button(action: { // ACCEPT/CONNECT BUTTON
                                 if currentIndex < dogWalkers.count {
                                      let walkerToConnect = dogWalkers[currentIndex]
                                      selectedDogWalker = walkerToConnect // Keep for message view
                                      withAnimation(.spring()) {
                                          offset = CGSize(width: 500, height: 0)
                                          handleSwipe(width: 500, walker: walkerToConnect) // Trigger swipe logic
                                      }
                                      // Show message view slightly delayed (optional)
                                      // DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                      //     showMessageView = true
                                      // }
                                 }
                             }) {
                                 Image(systemName: "checkmark") // Changed icon to checkmark for 'accept'
                                     .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                     .padding(20).background(Color.green).clipShape(Circle())
                             }.disabled(currentIndex >= dogWalkers.count)
                         }
                         .padding(.bottom, 30)
                    } // End Action Buttons VStack
                    .zIndex(10)
                } // End Else
            } // End Main Content ZStack
            .padding(.top)
            Spacer()
        }
         // Modals and Navigation Modifiers (remain the same)
         .overlay(
              Group {
                  if showRatingModal, let walker = selectedDogWalker {
                      Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { showRatingModal = false }.zIndex(20)
                      RatingModalView(dogWalker: walker, rating: $userRating, isPresented: $showRatingModal)
                          .transition(.move(edge: .bottom)).zIndex(21)
                  }
              }
          )
         .sheet(isPresented: $showMessageView) {
              if let walker = selectedDogWalker {
                  MessageView(dogWalker: walker, isPresented: $showMessageView)
              }
          }
        .navigationBarHidden(true)
        .onAppear {
            fetchDogWalkers()
        }
    }

    // --- MODIFIED handleSwipe ---
    private func handleSwipe(width: CGFloat, walker: DogWalker) {
        guard let swipedWalkerIndex = dogWalkers.firstIndex(where: { $0.id == walker.id }),
              swipedWalkerIndex == currentIndex else {
            offset = .zero
            return
        }

        let swipeThreshold: CGFloat = 150
        var performStateUpdate: (() -> Void)? = nil

        if width > swipeThreshold { // Right swipe (like/accept)
            print("Accepted \(walker.name)")

            // --- Firestore Update Logic ---
            // Check if userID is valid before attempting to update Firestore
            if self.userID.isEmpty {
                print("Error: Invalid userID ('\(self.userID)'). Cannot update Firestore.")
                // Reset offset but let the UI continue (optional behavior)
                offset = .zero
                // If you want to prevent the UI update on invalid ID, return here
                // return
            } else {
                // Valid userID, proceed with Firestore update
                let userDocRef = db.collection("users").document(self.userID)
                
                guard let walkerID = walker.firebaseDocId else {
                    print("❌ Walker ID missing for \(walker.name)")
                    return
                }

                let acceptedWalkerEntry: [String: String] = [
                    "name": walker.name,
                    "id": walkerID
                ]

                userDocRef.updateData([
                    "accepted_walkers": FieldValue.arrayUnion([acceptedWalkerEntry])
                ]) { error in
                    if let error = error {
                        print("❌ Error updating accepted_walkers: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully added \(walker.name) (ID: \(walkerID)) to accepted_walkers for user \(self.userID)")
                    }
                }
            }
            // --- End Firestore Update Logic ---

            performStateUpdate = { self.advanceIndex() }

        } else if width < -swipeThreshold { // Left swipe (skip)
            print("Skipped \(walker.name)")
            performStateUpdate = {
                self.skippedWalkers.insert(walker, at: 0)
                if self.skippedWalkers.count > 10 { self.skippedWalkers.removeLast() }
                self.advanceIndex()
            }
        }

        // Reset offset smoothly if it's not a decisive swipe
        if performStateUpdate == nil {
            offset = .zero
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                performStateUpdate?()
                self.offset = .zero
            }
        }
    }

    // Helper function to advance the index
    private func advanceIndex() {
         if self.currentIndex < self.dogWalkers.count - 1 {
            self.currentIndex += 1
         } else {
             self.currentIndex = self.dogWalkers.count // Indicate end reached
         }
    }

    // Function to fetch and map to the ORIGINAL DogWalker struct (Unchanged from previous)
    private func fetchDogWalkers() {
        isLoading = true
        errorMessage = nil
        // let db = Firestore.firestore() // db already defined as property

        db.collection("walkers")
            .whereField("profileComplete", isEqualTo: true)
            .limit(to: 20)
            .getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching dog walkers: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    self.dogWalkers = []
                    self.isLoading = false
                    return
                }

                self.dogWalkers = documents.compactMap { doc -> DogWalker? in
                    let data = doc.data()
                    let firstName = data["firstName"] as? String ?? "Unknown"
                    let lastName = data["lastName"] as? String ?? "Walker"
                    let name = "\(firstName) \(lastName)"
                    let profileImage = "person.crop.circle.fill" // Default image
                    let rating = data["rating"] as? Double ?? 0.0
                    let reviews = data["reviews"] as? Int ?? 0
                    let isBackgroundChecked = data["isBackgroundChecked"] as? Bool ?? false
                    let bio = data["bio"] as? String ?? "No bio provided."
                    let rateValue = data["hourlyRate"] as? Int
                    let rate = rateValue != nil ? "$\(rateValue!)/hour" : "Rate N/A"

                    let city = data["city"] as? String
                    let state = data["state"] as? String
                    var distance = "Distance unknown"
                     if let city = city, let state = state { distance = "\(city), \(state)" }
                     else if city != nil || state != nil { distance = "\(city ?? "")\(state ?? "")" }

                    let specialties = data["servicesOffered"] as? [String] ?? []

                    var availabilityString = "Availability not specified"
                    if let availabilityData = data["availability"] as? [String: Any] {
                         let availableDays = availabilityData.compactMap { (day, dayData) -> String? in
                             if let dayDict = dayData as? [String: Any], let isAvailable = dayDict["isAvailable"] as? Bool, isAvailable {
                                 return day.capitalized // Capitalize day names
                             }
                             return nil
                         }.sorted() // Sort days

                         if !availableDays.isEmpty {
                             // Simple join for display
                             if availableDays.count > 3 {
                                 availabilityString = "Available: \(availableDays.prefix(3).joined(separator: ", "))..."
                             } else {
                                availabilityString = "Available: \(availableDays.joined(separator: ", "))"
                             }
                         } else {
                              availabilityString = "Check availability"
                         }
                    }

                    return DogWalker(
                        name: name,
                        profileImage: profileImage,
                        rating: rating,
                        reviews: reviews,
                        isBackgroundChecked: isBackgroundChecked,
                        bio: bio,
                        rate: rate,
                        distance: distance,
                        specialties: specialties,
                        availability: availabilityString,
                        firebaseDocId: doc.documentID // Ensure this is populated
                    )
                }

                print("Fetched \(self.dogWalkers.count) walkers.")
                self.isLoading = false
                self.currentIndex = 0
                self.offset = .zero
                self.skippedWalkers = []
            }
        }
    }
}


// MARK: - Subviews (DogWalkerCard, RatingModalView, MessageView) - Unchanged
// (These should remain the same as the previous version)
// ... (Include the DogWalkerCard, InfoTag, RatingModalView, MessageView structs here) ...

struct DogWalkerCard: View {
    let dogWalker: DogWalker // Expects the original struct
    let onRate: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(Color.gray.opacity(0.3))
                 .overlay(
                      Image(dogWalker.profileImage).resizable().aspectRatio(contentMode: .fit)
                           .padding(50).foregroundColor(.white)
                 )
                 .frame(width: UIScreen.main.bounds.width - 40, height: 450).cornerRadius(20)
            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.8)]), startPoint: .center, endPoint: .bottom)
                 .frame(height: 250).cornerRadius(20).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dogWalker.name).font(.title).fontWeight(.bold).foregroundColor(.white)
                    Spacer()
                    if dogWalker.isBackgroundChecked {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill").foregroundColor(.blue)
                            Text("Verified").font(.caption).foregroundColor(.white)
                        }.padding(.vertical, 4).padding(.horizontal, 8).background(Color.black.opacity(0.3)).cornerRadius(8)
                    }
                }
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", dogWalker.rating)).foregroundColor(.white)
                        Text("(\(dogWalker.reviews))").foregroundColor(.gray)
                    }
                    Spacer()
                }
                Text(dogWalker.bio).font(.subheadline).foregroundColor(.white.opacity(0.9)).lineLimit(2).padding(.bottom, 4)
                ScrollView(.horizontal, showsIndicators: false) {
                     HStack(spacing: 8) {
                         InfoTag(text: dogWalker.distance)
                         InfoTag(text: dogWalker.rate)
                         InfoTag(text: dogWalker.availability)
                         ForEach(dogWalker.specialties, id: \.self) { specialty in
                             InfoTag(text: specialty, color: .blue.opacity(0.7))
                         }
                     }
                 }.frame(height: 30).padding(.bottom, 10)
            }.padding(20).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }.frame(width: UIScreen.main.bounds.width - 40, height: 450).shadow(radius: 8).cornerRadius(20)
    }
}

// Helper View for Tags (same as before)
struct InfoTag: View {
    let text: String
    var color: Color = Color.gray.opacity(0.5)
    var textColor: Color = .white
    var body: some View {
        Text(text)
            .font(.caption)
            .lineLimit(1)
            .foregroundColor(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .cornerRadius(10)
    }
}

struct RatingModalView: View {
    let dogWalker: DogWalker // Expects original struct
    @Binding var rating: Int
    @Binding var isPresented: Bool
    @State private var reviewText: String = ""

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Rate \(dogWalker.name)").font(.title3).fontWeight(.bold)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.gray.opacity(0.7))
                }
            }

            // Use the profileImage name with Image()
            Image(dogWalker.profileImage)
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 80, height: 80)
                 .clipShape(Circle())
                 .padding(5)
                 .background(Circle().fill(Color.gray.opacity(0.2)))
                 .foregroundColor(.gray) // Color for system image

            HStack { /* Star rating logic (same) */
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.title).foregroundColor(.yellow)
                        .onTapGesture { rating = star }
                }
            }

            TextEditor(text: $reviewText) /* Review text field (same) */
                 .frame(height: 100)
                 .padding(8)
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)
                 // Placeholder logic can be added here if needed

            Button(action: { /* Submit logic (same) */
                 print("Rating: \(rating), Review: \(reviewText) for \(dogWalker.firebaseDocId ?? "Unknown FBID")")
                 isPresented = false
            }) {
                 Text("Submit Rating").font(.headline).foregroundColor(.white)
                     .frame(maxWidth: .infinity).padding()
                     .background(rating > 0 ? Color.blue : Color.gray).cornerRadius(15)
            }.disabled(rating == 0)

        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 30, trailing: 20))
        .background(Color(.systemBackground)).cornerRadius(25).shadow(radius: 10)
        .padding(.horizontal, 15)
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
    }
}

struct MessageView: View {
    let dogWalker: DogWalker // Expects original struct
    @Binding var isPresented: Bool
    @State private var messageText: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
         NavigationView {
              VStack(spacing: 0) {
                  ScrollView { /* Message Area (same placeholder logic) */
                       VStack(alignment: .center, spacing: 20) {
                           VStack(spacing: 10) {
                               // Use profileImage name with Image()
                               Image(dogWalker.profileImage)
                                   .resizable().aspectRatio(contentMode: .fit)
                                   .frame(width: 80, height: 80).clipShape(Circle())
                                   .padding(5).background(Circle().fill(Color.gray.opacity(0.2)))
                                   .foregroundColor(.gray) // Color for system image

                               Text("You matched with \(dogWalker.name)!").font(.headline)
                               Text("Start a conversation...").font(.subheadline).foregroundColor(.gray)
                                   .multilineTextAlignment(.center).padding(.horizontal)
                           }.padding(.vertical, 40)
                           Text("Messages will appear here...").foregroundColor(.gray).font(.caption)
                           Spacer()
                       }.padding()
                  }
                  .frame(maxWidth: .infinity, maxHeight: .infinity)

                  HStack(spacing: 15) { /* Input field (same) */
                       TextField("Message...", text: $messageText).padding(12)
                           .background(Color.gray.opacity(0.1)).cornerRadius(20)
                       Button(action: sendMessage) {
                           Image(systemName: "paperplane.fill").font(.headline).foregroundColor(.white)
                               .padding(12).background(messageText.isEmpty ? Color.gray : Color.blue).clipShape(Circle())
                       }.disabled(messageText.isEmpty)
                  }.padding().background(Color(.systemGray6))
              }
              .navigationTitle(dogWalker.name)
              .navigationBarTitleDisplayMode(.inline)
              .navigationBarItems(leading: Button("Close") { dismiss() })
         }
    }

    func sendMessage() {
        print("Sending message to \(dogWalker.firebaseDocId ?? "Unknown FBID"): \(messageText)")
        messageText = ""
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


// MARK: - Previews (Adjusted for Original Struct)

#Preview("Dog Walker Card") {
     let previewWalker = DogWalker(
         name: "Sarah Johnson (Preview)",
         profileImage: "person.crop.circle.fill.badge.checkmark", // System image name
         rating: 4.8,
         reviews: 124,
         isBackgroundChecked: true,
         bio: "Professional dog trainer preview bio.",
         rate: "$18/walk",
         distance: "0.8 miles away",
         specialties: ["High-energy dogs", "Puppy training"],
         availability: "Weekdays 9am-5pm",
         firebaseDocId: "preview123"
     )
     return DogWalkerCard(
         dogWalker: previewWalker,
         onRate: {}
     )
     .padding()
}

#Preview("Rating Modal") {
    let previewWalker = DogWalker(
        name: "Marcus Rivera (Preview)",
        profileImage: "person.crop.circle.fill", // System image name
        rating: 4.9,
        reviews: 87,
        isBackgroundChecked: true,
        bio: "Former vet tech preview bio.",
        rate: "$20/walk",
        distance: "1.2 miles away",
        specialties: ["Anxious dogs", "Medication admin"],
        availability: "Evenings and weekends",
        firebaseDocId: "preview456"
    )
    return RatingModalView(
        dogWalker: previewWalker,
        rating: .constant(4),
        isPresented: .constant(true)
    )
}

#Preview("Message View") {
     let previewWalker = DogWalker(
        name: "Emily Chen (Preview)",
        profileImage: "figure.walk.circle.fill", // System image name
        rating: 4.7,
        reviews: 56,
        isBackgroundChecked: true,
        bio: "Part-time dog walker preview bio.",
        rate: "$15/walk",
        distance: "0.5 miles away",
        specialties: ["Long walks", "Running buddy"],
        availability: "Mornings and weekends",
        firebaseDocId: "preview789"
     )
     return MessageView(
         dogWalker: previewWalker,
         isPresented: .constant(true)
     )
}
