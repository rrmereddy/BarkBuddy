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
                Color.fromHex("F6F6F6")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(Color.fromHex("FF6B6B"))
                                .padding(.trailing, 4)
                        }
                        
                        Text("BarkBuddy")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.fromHex("FF6B6B"))
                        
                        Spacer()
                        
                        Button(action: {
                            // Settings
                            isMenuOpen.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color.fromHex("FF6B6B"))
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
                                    .foregroundColor(Color.fromHex("FF6B6B"))
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
                                        .background(Color.fromHex("FF6B6B"))
                                        .cornerRadius(8)
                                }
                                .padding(.top, 20)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(filteredChatRooms) { chatRoom in
                                        OwnerChatRow(chatRoom: chatRoom, isWalker: false) {
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
                                        .contextMenu {
                                            Button(role: .destructive, action: {
                                                // Delete the chat room
                                                if let chatRoomId = chatRoom.id {
                                                    chatService.deleteChatRoom(chatRoomId: chatRoomId) { result in
                                                        switch result {
                                                        case .success:
                                                            print("✅ Successfully deleted chat room")
                                                        case .failure(let error):
                                                            print("❌ Error deleting chat room: \(error.localizedDescription)")
                                                        }
                                                    }
                                                }
                                            }) {
                                                Label("Delete Chat", systemImage: "trash")
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
                        OwnerChatDetailView(
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
                .foregroundColor(isSelected ? Color.fromHex("FF6B6B") : Color.gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? Color.fromHex("FF6B6B") : Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// Color Utilities - Retain for backward compatibility
struct ColorUtils {
    static func hexStringToColor(hex: String) -> Color {
        // Use the shared implementation instead
        return Color.fromHexCode(hex)
    }
}

// Extension for Color(hex:) to avoid duplicate implementations
extension Color {
    // Use the shared implementation from ChatViewHelpers.swift
    static func fromHex(_ hex: String) -> Color {
        return Color.fromHexCode(hex)
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

struct OwnerAcceptedChatView: View {
    var body: some View {
        DogOwnerChatView()
    }
}

// Helper function for status color (needed by FirebaseChatRow)
extension View {
    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "confirmed":
            return Color.green
        case "en route", "in progress":
            return Color.orange
        case "scheduled":
            return Color.blue
        case "completed":
            return Color.gray
        case "cancelled":
            return Color.red
        default:
            return Color.gray
        }
    }
}

// Implementation of OwnerChatRow (similar to WalkerChatRow)
struct OwnerChatRow: View {
    let chatRoom: ChatRoom
    let isWalker: Bool
    let action: () -> Void
    @StateObject private var chatService = ChatService()
    @State private var isProcessing = false
    
    // Hardcoded demo walker ID for checking
    private let demoWalkerID = "IWWdFgkCojc2y6TFDPVFFickuMm1"
    
    // Helper computed property to check if this is a demo chat
    private var isDemoChat: Bool {
        return chatRoom.walkerId == demoWalkerID
    }
    
    // Computed property to check if this walk needs action
    private var needsAction: Bool {
        if isWalker {
            // Walker sees: Owner accepted but walker hasn't yet
            return chatRoom.ownerAccepted && !chatRoom.walkerAccepted
        } else {
            // Owner sees: Can accept if neither has accepted yet
            return !chatRoom.ownerAccepted && !chatRoom.walkerAccepted
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                if let profileImageURL = isWalker 
                    ? chatRoom.ownerProfileImageURL 
                    : chatRoom.walkerProfileImageURL,
                   !profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: isDemoChat ? "star.circle.fill" : "person.circle.fill")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .foregroundColor(isDemoChat ? Color.yellow : Color.fromHex("FF6B6B"))
                            .background(isDemoChat ? Color.fromHex("FFFAE8") : Color.fromHex("FFE8E8"))
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: isDemoChat ? "star.circle.fill" : "person.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(isDemoChat ? Color.yellow : Color.fromHex("FF6B6B"))
                        .background(isDemoChat ? Color.fromHex("FFFAE8") : Color.fromHex("FFE8E8"))
                        .clipShape(Circle())
                }
                
                // Show badge indicator based on status
                if isWalker && chatRoom.ownerAccepted && !chatRoom.walkerAccepted {
                    // New request badge for walker
                    Image(systemName: "exclamationmark.circle.fill")
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(.red)
                        .offset(x: 2, y: 2)
                } else {
                    // Regular badge
                    Image(systemName: isDemoChat ? "star.fill" : "pawprint.fill")
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(isDemoChat ? Color.yellow : Color.fromHex("FF6B6B"))
                        .offset(x: 2, y: 2)
                }
            }
            
            Button(action: action) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if isWalker {
                            Text("\(chatRoom.ownerName)'s \(chatRoom.dogName)")
                                .font(.system(size: 16, weight: .semibold))
                        } else {
                            Text(isDemoChat ? "\(chatRoom.walkerName) (Demo)" : chatRoom.walkerName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(isDemoChat ? Color.orange : Color.primary)
                        }
                        
                        Spacer()
                        
                        if chatRoom.walkerAccepted && chatRoom.ownerAccepted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                        }
                        
                        Text(chatRoom.walkDateTime.formatDateTime())
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text(chatRoom.walkStatus)
                            .font(.system(size: 14))
                            .foregroundColor(statusColor(for: chatRoom.walkStatus))
                        
                        if isDemoChat {
                            Text("• Demo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        if isWalker && chatRoom.ownerAccepted && !chatRoom.walkerAccepted {
                            Text("• New Request")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)
                                .italic()
                        } else if chatRoom.ownerAccepted && !chatRoom.walkerAccepted {
                            Text("• Awaiting walker")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(chatRoom.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(
            chatRoom.ownerAccepted && !chatRoom.walkerAccepted && isWalker
                ? Color.fromHex("FFECEC") // Brighter red background for pending requests
                : (isDemoChat ? Color.fromHex("FFFEF7") : (needsAction ? Color.fromHex("FFF0F0") : Color.white))
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    chatRoom.ownerAccepted && !chatRoom.walkerAccepted && isWalker
                        ? Color.red
                        : (isDemoChat ? Color.yellow.opacity(0.3) : (needsAction ? Color.red.opacity(0.2) : Color.clear)),
                    lineWidth: chatRoom.ownerAccepted && !chatRoom.walkerAccepted && isWalker ? 2 : 1
                )
        )
        .shadow(
            color: chatRoom.ownerAccepted && !chatRoom.walkerAccepted && isWalker ? Color.red.opacity(0.2) : Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "confirmed":
            return Color.green
        case "en route", "in progress":
            return Color.orange
        case "scheduled":
            return Color.blue
        case "completed":
            return Color.gray
        case "cancelled":
            return Color.red
        default:
            return Color.gray
        }
    }
}

// Implementation of OwnerChatDetailView (similar to WalkerChatDetailView)
struct OwnerChatDetailView: View {
    let chatRoom: ChatRoom
    let onBack: () -> Void
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var isProcessingAccept = false
    
    // Hardcoded demo walker ID for checking
    private let demoWalkerID = "IWWdFgkCojc2y6TFDPVFFickuMm1"
    
    // Helper computed property to check if this is a demo chat
    private var isDemoChat: Bool {
        return chatRoom.walkerId == demoWalkerID
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(Color.fromHex("FF6B6B"))
                }
                
                if let profileImageURL = chatRoom.walkerProfileImageURL,
                   !profileImageURL.isEmpty {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(.leading, 8)
                    } placeholder: {
                        Image(systemName: isDemoChat ? "star.circle.fill" : "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isDemoChat ? Color.yellow : Color.fromHex("FF6B6B"))
                            .padding(.leading, 8)
                    }
                } else {
                    Image(systemName: isDemoChat ? "star.circle.fill" : "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(isDemoChat ? Color.yellow : Color.fromHex("FF6B6B"))
                        .padding(.leading, 8)
                }
                
                VStack(alignment: .leading) {
                    Text(isDemoChat ? "\(chatRoom.walkerName) (Demo)" : chatRoom.walkerName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDemoChat ? Color.orange : Color.primary)
                    
                    Text("Walk: \(chatRoom.walkDateTime.formatDateTime())")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Add menu for options
                Menu {
                    Button(role: .destructive, action: {
                        // Delete the chat room and go back
                        if let chatRoomId = chatRoom.id {
                            chatService.deleteChatRoom(chatRoomId: chatRoomId) { result in
                                switch result {
                                case .success:
                                    print("✅ Successfully deleted chat room")
                                    DispatchQueue.main.async {
                                        onBack()
                                    }
                                case .failure(let error):
                                    print("❌ Error deleting chat room: \(error.localizedDescription)")
                                }
                            }
                        }
                    }) {
                        Label("Delete Chat", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Color.fromHex("FF6B6B"))
                }
                
                // Call button for non-demo chats
                Button(action: {
                    // Call action (could be implemented in a future update)
                }) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.fromHex("FF6B6B"))
                        .padding(8)
                        .background(Color.fromHex("FFE8E8"))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(isDemoChat ? Color.fromHex("FFFEF7") : Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Demo notice banner (only shown for demo chats)
            if isDemoChat {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.orange)
                    
                    Text("This is a demo conversation. The walker will respond automatically to your messages.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.orange)
                    
                    Spacer()
                }
                .padding(8)
                .background(Color.fromHex("FFFAE8"))
                .cornerRadius(0)
            }
            
            // Chat messages
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(chatService.messages) { message in
                            OwnerMessageBubble(
                                message: message,
                                isFromCurrentUser: message.senderId == Auth.auth().currentUser?.uid,
                                isDemoMessage: message.senderId == demoWalkerID
                            )
                            .id(message.id ?? "")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                .onChange(of: chatService.messages.count) { _ in
                    if let lastMessageId = chatService.messages.last?.id {
                        withAnimation {
                            scrollView.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .padding(10)
                    .background(Color.fromHex("F6F6F6"))
                    .cornerRadius(20)
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.fromHex("FF6B6B"))
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
        .onAppear {
            // Fetch messages when the view appears
            if let chatRoomId = chatRoom.id {
                chatService.fetchMessages(chatRoomId: chatRoomId)
            }
        }
        .onDisappear {
            // Detach listeners when view disappears
            chatService.detachListeners()
        }
    }
    
    private func sendMessage() {
        guard let userId = Auth.auth().currentUser?.uid,
              let chatRoomId = chatRoom.id,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Determine if the current user is the walker or owner
        let isWalker = userId == chatRoom.walkerId
        let receiverId = isWalker ? chatRoom.ownerId : chatRoom.walkerId
        let senderName = isWalker ? chatRoom.walkerName : chatRoom.ownerName
        
        chatService.sendMessage(
            chatRoomId: chatRoomId,
            senderId: userId,
            senderName: senderName,
            receiverId: receiverId,
            text: messageText
        ) { result in
            switch result {
            case .success:
                messageText = ""
            case .failure(let error):
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

// Implementation of OwnerMessageBubble (similar to MessageBubble in shared code)
struct OwnerMessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    let isDemoMessage: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .padding(12)
                    .background(
                        isFromCurrentUser 
                            ? Color.fromHex("FF6B6B") 
                            : (isDemoMessage ? Color.fromHex("FFFAE8") : Color.fromHex("F0F0F0"))
                    )
                    .foregroundColor(
                        isFromCurrentUser 
                            ? .white 
                            : (isDemoMessage ? .black : .black)
                    )
                    .cornerRadius(20)
                
                HStack(spacing: 4) {
                    if isDemoMessage && !isFromCurrentUser {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                    
                    Text(message.timestamp.formatTime())
                        .font(.system(size: 12))
                        .foregroundColor(isDemoMessage && !isFromCurrentUser ? .orange : .gray)
                    
                    if isDemoMessage && !isFromCurrentUser {
                        Text("Demo")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 4)
            }
            
            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}
