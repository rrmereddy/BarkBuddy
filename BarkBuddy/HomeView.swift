import SwiftUI
import FirebaseAuth // <--- Import FirebaseAuth

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedTab = "home"
    @State private var showProfileModal = false
    @State private var showAllWalkersModal = false
    @State private var showFutureWalksModal = false
    @State private var showProfileDogWalkerModal = false
    @State private var showPastWalksModal = false
    @State private var showAcceptedChatsOwner = false
    @State private var showUserDuringWalkView = false
    @State private var showWalkerDuringWalkView = false

    // State variable to store the current user's ID
    @State private var currentUserID: String? = nil // <-- Initialize as optional String
    @State private var showProfileDogWalkerModalPending = false



    var body: some View {
        VStack(spacing: 0) {
            // Header (remains the same)
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
                    // Welcome Section
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


                    // Quick Options
                    VStack(spacing: 12) {
                        // Quick Walk Option
                        Button(action: {
                            if currentUserID != nil {
                                showProfileDogWalkerModalPending = true
                            } else {
                                print("⚠️ User ID not ready yet.")
                            }
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

                        // Past Walks Option
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

                        // User During Walk View Option
                        Button(action: {
                            showUserDuringWalkView = true
                        }) {
                            QuickOptionButton(
                                icon: "figure.walk",
                                title: "Track Current Walk",
                                description: "See your dog's active walk",
                                color: .green
                            )
                        }

                        // Walker During Walk View Option
                        Button(action: {
                            showWalkerDuringWalkView = true
                        }) {
                            QuickOptionButton(
                                icon: "person.fill.and.arrow.left.and.arrow.right",
                                title: "Walker Mode",
                                description: "Start or continue a dog walk",
                                color: .orange
                            )
                        }
                    }

                    // Recent Walkers
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Walkers")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(UIColor.darkGray))
                            Spacer()
                            Button(action: {
                                showPastWalksModal = true // Or potentially showAllWalkersModal
                            }) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(Color.teal)
                            }
                        }

                        // Use the renamed WalkerCard if needed (or keep original if that exists)
                        // Assuming WalkerCard struct exists elsewhere. Using new_WalkerCard for now.
                        new_WalkerCard(
                             name: "Sarah J.",
                             rating: 4.9,
                             distance: 0.8,
                             availability: "Last walked: Yesterday",
                             price: "$18/30 min"
                         )

                        new_WalkerCard(
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
            // --- Modals ---
             .sheet(isPresented: $showProfileModal) {
                  // Replace Text with your actual ProfileEditView or similar
                  Text("Profile Editor Modal")
                     .font(.title).padding()
                     .onAppear { print("Showing profile edit modal") }
              }
             .sheet(isPresented: $showAllWalkersModal) {
                  // Replace Text with your actual view for all walkers
                  Text("All Walkers List Modal")
                     .font(.title).padding()
                     .onAppear { print("Showing all walkers modal") }
              }
             .sheet(isPresented: $showProfileDogWalkerModalPending) {
                 // Safely unwrap the optional userID *inside* the sheet's content closure
                     DogWalkerProfileView(userID: "gwcZGcoKNwa1iS7424utiwzY1G62") // Pass the non-optional String
             }
             .sheet(isPresented: $showFutureWalksModal) {
                     FutureWalksView(userID: "gwcZGcoKNwa1iS7424utiwzY1G62")
              }
             .sheet(isPresented: $showPastWalksModal) {
                  PastWalksView() // Assuming this view exists
              }
             .sheet(isPresented: $showAcceptedChatsOwner) {
                  BligView() // Assuming this view exists
              }
             .sheet(isPresented: $showUserDuringWalkView) {
                  PetOwnerWalkView() // Assuming this view exists
              }
             .sheet(isPresented: $showWalkerDuringWalkView) {
                  WalkerDuringWalkView() // Assuming this view exists
              }

            // Bottom Navigation (remains the same)
             HStack(spacing: 0) {
                 // Using the renamed new_TabButton if needed
                 new_TabButton(image: "house", title: "Home", isSelected: selectedTab == "home") { selectedTab = "home" }
                 new_TabButton(image: "magnifyingglass", title: "Search", isSelected: selectedTab == "search") { selectedTab = "search" /* TODO: Add search action or view */ }
                 new_TabButton(image: "calendar", title: "Bookings", isSelected: selectedTab == "bookings") { selectedTab = "bookings"; showFutureWalksModal = true }
                 new_TabButton(image: "message", title: "Messages", isSelected: selectedTab == "messages") { selectedTab = "messages"; showAcceptedChatsOwner = true }
                 new_TabButton(image: "person", title: "Settings", isSelected: selectedTab == "settings") { selectedTab = "settings" /* TODO: Add settings action or view */ }
             }
             .padding(.top, 8)
             .background(Color.white)
             .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
        .edgesIgnoringSafeArea(.bottom)
        // .navigationBarBackButtonHidden(true) // Only use if within NavigationView
        .onAppear { // <-- Fetch User ID when the view appears
            fetchUserID()
        }
    }

    // --- Function to fetch the User ID ---
    private func fetchUserID() {
        // Get the current user from Firebase Auth
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
            print("✅ Current User ID: \(self.currentUserID ?? "N/A")")
            // You can now use self.currentUserID where needed (e.g., pass it to other views or use in Firestore queries)
        } else {
            self.currentUserID = nil // Ensure it's nil if no user is logged in
            print("⚠️ No user logged in.")
            // Handle the case where the user is not logged in (e.g., show login screen)
        }
    }
}

// QuickOptionButton (remains the same)
struct QuickOptionButton: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.darkGray))
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            Spacer()
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

// WalkerCard (Using the new_ version provided)
struct new_WalkerCard: View {
    let name: String
    let rating: Double
    let distance: Double
    let availability: String
    let price: String

    var body: some View {
        HStack(spacing: 12) {
            Circle() // Placeholder Image
                .fill(Color.gray.opacity(0.2))
                .frame(width: 64, height: 64)
                .overlay(Text("\(name.prefix(1))").font(.title).fontWeight(.medium).foregroundColor(.gray))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name).fontWeight(.semibold).foregroundColor(Color(UIColor.darkGray))
                    Spacer()
                    HStack(spacing: 2) { // Rating
                        Text(String(format: "%.1f", rating)).font(.subheadline).foregroundColor(Color.yellow)
                        Text("★").foregroundColor(Color.yellow)
                    }
                }
                HStack(spacing: 4) { // Distance
                    Image(systemName: "mappin").font(.system(size: 12)).foregroundColor(Color.gray)
                    Text("\(String(format: "%.1f", distance)) miles away").font(.subheadline).foregroundColor(Color.gray)
                }
                Text("\(availability) · \(price)").font(.subheadline).foregroundColor(Color.gray) // Availability & Price
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// TabButton (Using the new_ version provided)
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
