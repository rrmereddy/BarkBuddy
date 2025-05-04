import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct UserIDWrapper: Identifiable {
  let id: String
}

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
    @State private var showAcceptedChatsWalker = false
    @State private var pendingWalkRequests: Int = 0
    @State private var isWalker: Bool = false
    @State private var selectedProfileUser: UserIDWrapper? = nil
    @State private var selectedFutureWalkUser: UserIDWrapper? = nil
    @State private var showProfileDogWalkerModalPending = false
    @State private var showLogoutAlert = false
    @State private var showLoginModal = false  // Added for logout navigation
    
    // Chat service for checking unread messages
    @StateObject private var chatService = ChatService()

    // State variable to store the current user's ID
    @State private var currentUserID: String = ""
    
    // Variable to track if user ID has been fetched
    @State private var isUserIDLoaded = false

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
                     Button(action: {
                         if isWalker {
                             showAcceptedChatsWalker = true
                         } else {
                             showAcceptedChatsOwner = true
                         }
                     }) {
                         ZStack(alignment: .topTrailing) {
                             Image(systemName: "bell")
                                 .foregroundColor(Color.gray)
                                 .font(.system(size: 20))
                             
                             if chatService.unreadMessagesCount > 0 || pendingWalkRequests > 0 {
                                 let totalCount = chatService.unreadMessagesCount + pendingWalkRequests
                                 Text("\(totalCount)")
                                     .font(.system(size: 10, weight: .bold))
                                     .foregroundColor(.white)
                                     .frame(minWidth: 16, minHeight: 16)
                                     .background(Color.red)
                                     .clipShape(Circle())
                                     .offset(x: 8, y: -6)
                             }
                         }
                     }
                     
                     Button(action: {
                         logout()
                     }) {
                         Image(systemName: "rectangle.portrait.and.arrow.right")
                             .foregroundColor(.red)
                             .font(.system(size: 20))
                     }
                     .alert(isPresented: $showLogoutAlert) {
                         Alert(
                             title: Text("Log Out"),
                             message: Text("Are you sure you want to log out?"),
                             primaryButton: .destructive(Text("Log Out")) {
                                 performLogout()
                             },
                             secondaryButton: .cancel()
                         )
                     }

                     Button(action: {
                         showProfileModal = true
                     }) {
                         Image(systemName: "person.circle")
                             .resizable()
                             .frame(width: 30, height: 30)
                             .foregroundColor(.blue)
                     }
                 }
             }
             .padding()
             .background(Color.white)
             .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
             
            // Pending walk requests banner (only shown for walkers)
            if isWalker && pendingWalkRequests > 0 {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.white)
                    
                    Text("You have \(pendingWalkRequests) pending walk \(pendingWalkRequests == 1 ? "request" : "requests")!")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: {
                        showAcceptedChatsWalker = true
                    }) {
                        Text("View")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(12)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.red)
                .onTapGesture {
                    showAcceptedChatsWalker = true
                }
            }


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
                            guard isUserIDLoaded else { print("⚠️ not ready"); return }
                            selectedProfileUser = UserIDWrapper(id: currentUserID)
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
                            guard isUserIDLoaded else { print("⚠️ not ready"); return }
                            selectedFutureWalkUser = UserIDWrapper(id: currentUserID)
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
                 ProfileEditView()
              }
             .sheet(isPresented: $showAllWalkersModal) {
                  // Replace Text with your actual view for all walkers
                  Text("All Walkers List Modal")
                     .font(.title).padding()
                     .onAppear { print("Showing all walkers modal") }
              }
             .sheet(item: $selectedProfileUser) { wrapper in
               DogWalkerProfileView(userID: wrapper.id)
             }
             .sheet(item: $selectedFutureWalkUser) { wrapper in
                 FutureWalksView(userID: wrapper.id, isWalker: self.isWalker)
              }
             .sheet(isPresented: $showPastWalksModal) {
                  PastWalksView() // Assuming this view exists
              }
             .sheet(isPresented: $showAcceptedChatsOwner) {
                  DogOwnerChatView() // Direct reference to the proper chat view for owners
              }
             .sheet(isPresented: $showUserDuringWalkView) {
                  PetOwnerWalkView() // Assuming this view exists
              }
             .sheet(isPresented: $showWalkerDuringWalkView) {
                  WalkerDuringWalkView() // Assuming this view exists
              }
             .sheet(isPresented: $showAcceptedChatsWalker) {
                AcceptedChatView() // Correct view for walkers
             }
//             .sheet(isPresented: $showLoginModal) {
//                LoginView() // Show Login modal when logout is performed
//             }

            // Bottom Navigation (remains the same)
             HStack(spacing: 0) {
                 // Using the renamed new_TabButton if needed
                 new_TabButton(image: "house", title: "Home", isSelected: selectedTab == "home") { selectedTab = "home" }
                 new_TabButton(image: "magnifyingglass", title: "Search", isSelected: selectedTab == "search") { selectedTab = "search" /* TODO: Add search action or view */ }
                 new_TabButton(image: "calendar", title: "Bookings", isSelected: selectedTab == "bookings") { selectedTab = "bookings"; showFutureWalksModal = true }
                 new_TabButton(image: "message", title: "Messages", isSelected: selectedTab == "messages", badgeCount: chatService.unreadMessagesCount) { selectedTab = "messages"; showAcceptedChatsOwner = true }
                 new_TabButton(image: "person", title: "Settings", isSelected: selectedTab == "settings") { selectedTab = "settings" /* TODO: Add settings action or view */ }
             }
             .padding(.top, 8)
             .background(Color.white)
             .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showLoginModal) {
            LoginView()
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            fetchUserID()
        }
        .onDisappear {
            // Detach listeners when view disappears
            chatService.detachListeners()
        }
    }

    // --- Function to fetch the User ID ---
    private func fetchUserID() {
        // Get the current user from Firebase Auth
        if let user = Auth.auth().currentUser {
            self.currentUserID = user.uid
            self.isUserIDLoaded = true
            print("✅ HomeView: Current User ID: \(self.currentUserID)")
            print("✅ HomeView: User Email: \(user.email ?? "No email")")
            print("✅ HomeView: User Display Name: \(user.displayName ?? "No display name")")
            print("✅ HomeView: User Phone: \(user.phoneNumber ?? "No phone")")
            
            // Start checking for unread messages
            chatService.checkUnreadMessages(userId: user.uid)
            
            // Check if this user is a walker by querying the walkers collection
            let db = Firestore.firestore()
            db.collection("walkers").document(user.uid).getDocument { snapshot, error in
                if let error = error {
                    print("❌ Error checking if user is a walker: \(error.localizedDescription)")
                    return
                }
                
                // If the document exists, this is a walker
                if let snapshot = snapshot, snapshot.exists {
                    self.isWalker = true
                    print("✅ HomeView: User is a walker")
                    
                    // For walkers, check if they have any pending requests
                    self.checkPendingWalkRequests(walkerId: user.uid)
                } else {
                    self.isWalker = false
                    print("✅ HomeView: User is not a walker")
                }
            }
        } else {
            self.currentUserID = ""
            self.isUserIDLoaded = false
            print("⚠️ HomeView: No user logged in. Auth.auth().currentUser is nil")
            // Handle the case where the user is not logged in (e.g., show login screen)
        }
    }
    
    // Function to handle logout button tap
    private func logout() {
        showLogoutAlert = true
    }
    
    // Function to perform the actual logout
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            print("✅ Successfully logged out")
            // Show the Login modal
            showLoginModal = true
        } catch let error {
            print("❌ Error signing out: \(error.localizedDescription)")
        }
    }
    
    // Function to check for pending walk requests
    private func checkPendingWalkRequests(walkerId: String) {
        let db = Firestore.firestore()
        
        // Query chat rooms where this user is the walker, owner has accepted, but walker hasn't
        db.collection("chatRooms")
            .whereField("walkerId", isEqualTo: walkerId)
            .whereField("ownerAccepted", isEqualTo: true)
            .whereField("walkerAccepted", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error checking pending walk requests: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    self.pendingWalkRequests = documents.count
                    print("✅ HomeView: Found \(self.pendingWalkRequests) pending walk requests")
                }
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
    let badgeCount: Int
    let action: () -> Void
    
    init(image: String, title: String, isSelected: Bool, badgeCount: Int = 0, action: @escaping () -> Void) {
        self.image = image
        self.title = title
        self.isSelected = isSelected
        self.badgeCount = badgeCount
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: image)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? Color.teal : Color.gray)
                    
                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 8, y: -6)
                    }
                }
                
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
