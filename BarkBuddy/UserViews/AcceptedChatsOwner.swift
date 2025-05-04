import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Models
struct WalkerChat: Identifiable {
    let id: String
    let walkerName: String
    let rating: String
    let walkStatus: String
    let walkTime: String
    let lastMessage: String
    let avatar: String
}

struct WalkerMessage: Identifiable {
    let id: String
    let isFromWalker: Bool
    let text: String
    let time: String
}

// MARK: - Main View
struct DogOwnerChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var searchText = ""
    @State private var selectedChatRoom: ChatRoom?
    @State private var messageText = ""
    @State private var selectedFilter = 0
    @State private var isMenuOpen = false
    @Environment(\.presentationMode) var presentationMode
    
    // Filters
    let filters = ["All Walks", "Today", "This Week"]
    
    var filteredChatRooms: [ChatRoom] {
        let rooms = chatService.chatRooms
        
        // First apply search filter
        var filtered = searchText.isEmpty ? rooms : rooms.filter {
            $0.walkerName.localizedCaseInsensitiveContains(searchText) ||
            $0.dogName.localizedCaseInsensitiveContains(searchText)
        }
        
        // Then apply date filter
        if selectedFilter == 1 { // Today
            let today = Calendar.current.startOfDay(for: Date())
            filtered = filtered.filter {
                Calendar.current.isDate($0.walkDateTime, inSameDayAs: today)
            }
        } else if selectedFilter == 2 { // This Week
            let today = Date()
            let calendar = Calendar.current
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            
            filtered = filtered.filter {
                $0.walkDateTime >= weekStart && $0.walkDateTime < weekEnd
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F6F6F6")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "FF6B6B"))
                                .padding(.trailing, 4)
                        }
                        
                        Text("BarkBuddy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "FF6B6B"))
                        
                        Spacer()
                        
                        Button(action: {
                            // Settings
                            isMenuOpen.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "FF6B6B"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search chats", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Segmented control for filters
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(0..<filters.count, id: \.self) { index in
                            Text(filters[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    Text("Your Dogs' Walks")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
                    // Chat list
                    if selectedChatRoom == nil {
                        if Auth.auth().currentUser == nil {
                            // User is not authenticated
                            VStack {
                                Spacer()
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                    .padding(.bottom, 10)
                                Text("Not Signed In")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Text("You need to be signed in to view your messages.\nPlease sign in using the profile icon on the home screen.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        } else if chatService.chatRooms.isEmpty {
                            VStack {
                                Spacer()
                                Image(systemName: "message.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(hex: "FF6B6B"))
                                    .padding(.bottom, 10)
                                Text("No chats available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("You should have a demo conversation with our virtual walker. If it's not showing, please check your internet connection and try again.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button(action: {
                                    // Refresh the chat rooms
                                    if let userId = Auth.auth().currentUser?.uid {
                                        print("🔄 Manually refreshing chat rooms for user: \(userId)")
                                        chatService.fetchChatRooms(userId: userId, isWalker: false)
                                    }
                                }) {
                                    Text("Refresh")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(Color(hex: "FF6B6B"))
                                        .cornerRadius(8)
                                }
                                .padding(.top, 20)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(filteredChatRooms) { chatRoom in
                                        FirebaseChatRow(chatRoom: chatRoom, isWalker: false) {
                                            selectedChatRoom = chatRoom
                                            // Mark messages as read when opening chat
                                            if let userId = Auth.auth().currentUser?.uid {
                                                if let chatRoomId = chatRoom.id {
                                                    print("📱 Marking messages as read in chat room: \(chatRoomId)")
                                                    chatService.markMessagesAsRead(
                                                        chatRoomId: chatRoomId,
                                                        userId: userId
                                                    ) { result in
                                                        switch result {
                                                        case .success():
                                                            print("✅ Messages marked as read successfully")
                                                        case .failure(let error):
                                                            print("⚠️ Error marking messages as read: \(error.localizedDescription)")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        Divider()
                                            .padding(.leading, 80)
                                    }
                                }
                                .padding(.top, 8)
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Chat detail view
                        FirebaseChatDetailView(
                            chatRoom: selectedChatRoom!,
                            onBack: { selectedChatRoom = nil }
                        )
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Fetch chat rooms when the view appears
                if let user = Auth.auth().currentUser {
                    print("📱 DogOwnerChatView: User is authenticated with ID: \(user.uid)")
                    chatService.fetchChatRooms(userId: user.uid, isWalker: false)
                    
                    // Check if demo chat should be created
                    print("📱 DogOwnerChatView: Checking for demo chat room for user \(user.uid)")
                } else {
                    print("⚠️ DogOwnerChatView: No authenticated user found")
                }
            }
            .onDisappear {
                // Detach listeners when view disappears
                chatService.detachListeners()
            }
        }
    }
}

// Bottom Navigation Bar
struct BottomNavBar: View {
    let selected: Int
    
    var body: some View {
        HStack {
            BottomNavButton(iconName: "house.fill", text: "Home", isSelected: selected == 0)
            BottomNavButton(iconName: "message.fill", text: "Chats", isSelected: selected == 1)
            BottomNavButton(iconName: "calendar", text: "Calendar", isSelected: selected == 2)
            BottomNavButton(iconName: "person.fill", text: "Profile", isSelected: selected == 3)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .padding(.bottom, 10)
        .padding(.horizontal)
    }
}

struct BottomNavButton: View {
    let iconName: String
    let text: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? Color(hex: "FF6B6B") : Color.gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? Color(hex: "FF6B6B") : Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Color Utilities
struct ColorUtils {
    static func hexStringToColor(hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
}

struct BligView: View {
    var body: some View {
        AcceptedChatView()
    }
}

struct BligView_Previews: PreviewProvider {
    static var previews: some View {
        BligView()
    }
}

struct new_AcceptedChatView: View {
    var body: some View {
        DogOwnerChatView()
    }
}
