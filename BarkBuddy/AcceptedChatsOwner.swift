import SwiftUI

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
    @State private var searchText = ""
    @State private var selectedChat: WalkerChat?
    @State private var messageText = ""
    @State private var activeTab = 0
    
    // Sample data
    let chats = [
        WalkerChat(id: "1", walkerName: "Alex", rating: "4.9", walkStatus: "Confirmed", walkTime: "Today, 4:30 PM", lastMessage: "I'll be at your place at 4:30 PM sharp!", avatar: "person.circle.fill"),
        WalkerChat(id: "2", walkerName: "Jordan", rating: "4.7", walkStatus: "En Route", walkTime: "Today, 1:15 PM", lastMessage: "I'm about 5 minutes away from your location.", avatar: "person.circle.fill"),
        WalkerChat(id: "3", walkerName: "Taylor", rating: "4.8", walkStatus: "Scheduled", walkTime: "Tomorrow, 10:00 AM", lastMessage: "Looking forward to meeting Max tomorrow morning!", avatar: "person.circle.fill"),
        WalkerChat(id: "4", walkerName: "Casey", rating: "5.0", walkStatus: "Completed", walkTime: "Yesterday, 3:30 PM", lastMessage: "Max was such a good boy today! See you next week.", avatar: "person.circle.fill")
    ]
    
    var filteredChats: [WalkerChat] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter {
                $0.walkerName.localizedCaseInsensitiveContains(searchText) ||
                $0.walkStatus.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorUtils.colorFromHex("F8F6FF")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("BakBuddy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                        
                        Spacer()
                        
                        Button(action: {
                            // Notifications action
                        }) {
                            Image(systemName: "bell")
                                .font(.system(size: 20))
                                .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                        }
                        
                        Button(action: {
                            // Profile action
                        }) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 22))
                                .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                                .padding(.leading, 12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search walkers", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Tab selector
                    HStack(spacing: 0) {
                        TabButtonView(title: "Active Walks", isSelected: activeTab == 0) {
                            activeTab = 0
                        }
                        
                        TabButtonView(title: "History", isSelected: activeTab == 1) {
                            activeTab = 1
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    if selectedChat == nil {
                        // Chat list view when no chat is selected
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredChats) { chat in
                                    WalkerChatRow(chat: chat) {
                                        selectedChat = chat
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        
                        // Bottom navigation bar
                        BottomNavBar(selectedTab: 2)
                    } else {
                        // Detail view when chat is selected
                        WalkerChatDetailView(chat: $selectedChat, messageText: $messageText)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Supporting Views
struct TabButtonView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .foregroundColor(isSelected ? ColorUtils.colorFromHex("6B7AFF") : .gray)
                .background(
                    VStack {
                        Spacer()
                        if isSelected {
                            Rectangle()
                                .fill(ColorUtils.colorFromHex("6B7AFF"))
                                .frame(height: 3)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WalkerChatRow: View {
    let chat: WalkerChat
    let action: () -> Void
    
    var statusColor: Color {
        switch chat.walkStatus {
        case "Confirmed":
            return Color.green
        case "En Route":
            return Color.orange
        case "Scheduled":
            return Color.blue
        case "Completed":
            return Color.gray
        default:
            return Color.black
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: chat.avatar)
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                        .background(ColorUtils.colorFromHex("E8EAFF"))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(chat.walkerName)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("★ \(chat.rating)")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            Text(chat.walkTime)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text(chat.walkStatus)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(statusColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(statusColor.opacity(0.1))
                                .cornerRadius(10)
                            
                            Spacer()
                        }
                        
                        Text(chat.lastMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .padding(12)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WalkerChatDetailView: View {
    @Binding var chat: WalkerChat?
    @Binding var messageText: String
    
    // Sample messages for the demo
    let messages = [
        WalkerMessage(id: "1", isFromWalker: true, text: "I'll be at your place at 4:30 PM sharp!", time: "1:24 PM"),
        WalkerMessage(id: "2", isFromWalker: false, text: "Perfect! Max will be ready. He usually likes to bring his blue ball for fetch.", time: "1:30 PM"),
        WalkerMessage(id: "3", isFromWalker: true, text: "Great, I'll make sure to include some playtime with his ball.", time: "1:32 PM"),
        WalkerMessage(id: "4", isFromWalker: false, text: "Thanks! Also, the apartment gate code is #2468 if you need it.", time: "1:35 PM"),
        WalkerMessage(id: "5", isFromWalker: true, text: "Got it! Do you want me to text you when we start and finish the walk?", time: "1:40 PM")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                Button(action: {
                    chat = nil
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                }
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                    .padding(.leading, 8)
                
                VStack(alignment: .leading) {
                    Text(chat?.walkerName ?? "")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("★ \(chat?.rating ?? "") • \(chat?.walkStatus ?? "")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Call action
                }) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                        .padding(8)
                        .background(ColorUtils.colorFromHex("E8EAFF"))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Walk info card
            VStack(alignment: .leading, spacing: 6) {
                Text("Walk Details")
                    .font(.system(size: 16, weight: .semibold))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Date & Time")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(chat?.walkTime ?? "")
                            .font(.system(size: 14, weight: .medium))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Duration")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("30 minutes")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                
                Divider()
                    .padding(.vertical, 6)
                
                HStack {
                    Button(action: {
                        // Track walk action
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Track Walk")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .foregroundColor(.white)
                        .background(ColorUtils.colorFromHex("6B7AFF"))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    if chat?.walkStatus == "Scheduled" || chat?.walkStatus == "Confirmed" {
                        Button(action: {
                            // Cancel walk action
                        }) {
                            Text("Cancel Walk")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .foregroundColor(ColorUtils.colorFromHex("FF6B6B"))
                                .background(ColorUtils.colorFromHex("FFEEEE"))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Chat messages
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(messages) { message in
                        WalkerMessageBubble(message: message)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            
            // Message input
            HStack(spacing: 12) {
                Button(action: {
                    // Attach photo or media
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                }
                
                TextField("Message", text: $messageText)
                    .padding(10)
                    .background(ColorUtils.colorFromHex("F8F6FF"))
                    .cornerRadius(20)
                
                Button(action: {
                    // Send message
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(ColorUtils.colorFromHex("6B7AFF"))
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
    }
}

struct WalkerMessageBubble: View {
    let message: WalkerMessage
    
    var body: some View {
        HStack {
            if message.isFromWalker {
                Spacer()
            }
            
            VStack(alignment: message.isFromWalker ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .padding(12)
                    .background(message.isFromWalker ? ColorUtils.colorFromHex("E8EAFF") : ColorUtils.colorFromHex("6B7AFF"))
                    .foregroundColor(message.isFromWalker ? .black : .white)
                    .cornerRadius(20)
                
                Text(message.time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromWalker {
                Spacer()
            }
        }
    }
}

struct BottomNavBar: View {
    let selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            BottomNavButton(icon: "house.fill", title: "Home", isSelected: selectedTab == 0)
            BottomNavButton(icon: "magnifyingglass", title: "Search", isSelected: selectedTab == 1)
            BottomNavButton(icon: "message.fill", title: "Chats", isSelected: selectedTab == 2)
            BottomNavButton(icon: "calendar", title: "Schedule", isSelected: selectedTab == 3)
            BottomNavButton(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4)
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
    }
}

struct BottomNavButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? ColorUtils.colorFromHex("6B7AFF") : .gray)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? ColorUtils.colorFromHex("6B7AFF") : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Utilities
struct ColorUtils {
    static func colorFromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
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
