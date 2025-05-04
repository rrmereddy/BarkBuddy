//
//  AcceptedChatsWalker.swift
//  BarkBuddy
//
//  Created by Ravathur, Nishanth on 4/21/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AcceptedChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var searchText = ""
    @State private var selectedChatRoom: ChatRoom?
    @State private var messageText = ""
    @State private var selectedFilter = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var pendingRequests: Int = 0
    
    // Hardcoded demo walker ID - matching the one in ChatService
    private let demoWalkerID = "IWWdFgkCojc2y6TFDPVFFickuMm1"
    
    // Filters
    let filters = ["All Walks", "Today", "This Week"]
    
    var filteredChatRooms: [ChatRoom] {
        let rooms = chatService.chatRooms
        
        // First apply search filter
        var filtered = searchText.isEmpty ? rooms : rooms.filter {
            $0.ownerName.localizedCaseInsensitiveContains(searchText) ||
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
    
    // Computed property to get pending requests count
    private var pendingRequestsRooms: [ChatRoom] {
        return chatService.chatRooms.filter { room in
            guard let userId = Auth.auth().currentUser?.uid else { return false }
            return userId == room.walkerId && room.ownerAccepted && !room.walkerAccepted
        }
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
                            // Profile action
                        }) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "FF6B6B"))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Search bar with pending request indicator
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
                    
                    // Heading with notification count
                    HStack {
                        Text("Accepted Walks")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if pendingRequests > 0 {
                            Text("\(pendingRequests) new \(pendingRequests == 1 ? "request" : "requests")")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // Pending requests section (only show if there are pending requests)
                    if pendingRequestsRooms.count > 0 && selectedChatRoom == nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pending Walk Requests")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(pendingRequestsRooms) { chatRoom in
                                        FirebaseChatRow(chatRoom: chatRoom, isWalker: true) {
                                            selectedChatRoom = chatRoom
                                            // Mark messages as read when opening chat
                                            if let userId = Auth.auth().currentUser?.uid {
                                                if let chatRoomId = chatRoom.id {
                                                    chatService.markMessagesAsRead(
                                                        chatRoomId: chatRoomId,
                                                        userId: userId
                                                    ) { _ in }
                                                }
                                            }
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.red, lineWidth: 2)
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .frame(height: min(CGFloat(pendingRequestsRooms.count) * 100, 200))
                        }
                    }
                    
                    // Chat list
                    if selectedChatRoom == nil {
                        if Auth.auth().currentUser?.uid == demoWalkerID {
                            // Special case: Demo walker account
                            VStack {
                                // Demo walker banner
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("Demo Walker Account")
                                        .font(.headline)
                                        .foregroundColor(.orange)
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "FFFAE8"))
                                .cornerRadius(8)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                // Explanation text
                                Text("You are logged in as the demo walker account. Below are all the automated conversations with dog owners using the app.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding([.horizontal, .bottom])
                                
                                if chatService.chatRooms.isEmpty {
                                    VStack {
                                        Spacer()
                                        Text("No chats yet")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        Text("When users start conversations with the demo walker, they will appear here")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                        
                                        Button(action: {
                                            // Refresh the chat rooms
                                            if let user = Auth.auth().currentUser {
                                                print("🔄 Manually refreshing chat rooms for demo walker")
                                                chatService.fetchChatRooms(userId: user.uid, isWalker: true)
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
                                                FirebaseChatRow(chatRoom: chatRoom, isWalker: true) {
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
                            }
                        } else if chatService.chatRooms.isEmpty {
                            VStack {
                                Spacer()
                                Text("No chats yet")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("When you accept walk requests, chats will appear here")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(filteredChatRooms) { chatRoom in
                                        FirebaseChatRow(chatRoom: chatRoom, isWalker: true) {
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
                    let isDemo = user.uid == demoWalkerID
                    print("📱 AcceptedChatView: User is authenticated with ID: \(user.uid)")
                    if isDemo {
                        print("📱 AcceptedChatView: Demo walker account detected!")
                    }
                    
                    chatService.fetchChatRooms(userId: user.uid, isWalker: true)
                } else {
                    print("⚠️ AcceptedChatView: No authenticated user found")
                }
            }
            .onChange(of: chatService.chatRooms) { newChatRooms in
                // Update pending requests count whenever chat rooms change
                updatePendingRequestsCount()
            }
            .onDisappear {
                // Detach listeners when view disappears
                chatService.detachListeners()
            }
        }
    }
    
    // Helper to update the pending requests count
    private func updatePendingRequestsCount() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Count chat rooms where walker acceptance is needed
        pendingRequests = chatService.chatRooms.filter { room in
            return userId == room.walkerId && room.ownerAccepted && !room.walkerAccepted
        }.count
        
        print("📱 Pending walk requests: \(pendingRequests)")
    }
}

struct FirebaseChatRow: View {
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
                            .foregroundColor(isDemoChat ? Color.yellow : Color(hex: "FF6B6B"))
                            .background(isDemoChat ? Color(hex: "FFFAE8") : Color(hex: "FFE8E8"))
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: isDemoChat ? "star.circle.fill" : "person.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(isDemoChat ? Color.yellow : Color(hex: "FF6B6B"))
                        .background(isDemoChat ? Color(hex: "FFFAE8") : Color(hex: "FFE8E8"))
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
                        .foregroundColor(isDemoChat ? Color.yellow : Color(hex: "FF6B6B"))
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
            
            if isWalker && chatRoom.ownerAccepted && !chatRoom.walkerAccepted {
                Button(action: {
                    acceptWalkAsWalker()
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(20)
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("Accept")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                    }
                }
                .disabled(isProcessing)
            }
        }
        .padding(12)
        .background(
            chatRoom.ownerAccepted && !chatRoom.walkerAccepted && isWalker
                ? Color(hex: "FFECEC") // Brighter red background for pending requests
                : (isDemoChat ? Color(hex: "FFFEF7") : (needsAction ? Color(hex: "FFF0F0") : Color.white))
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
    
    private func acceptWalkAsWalker() {
        guard let chatRoomId = chatRoom.id, !isProcessing else { return }
        
        isProcessing = true
        
        chatService.walkerAcceptWalk(chatRoomId: chatRoomId) { result in
            DispatchQueue.main.async {
                isProcessing = false
                
                switch result {
                case .success:
                    print("✅ Successfully accepted walk as walker")
                case .failure(let error):
                    print("⚠️ Failed to accept walk: \(error.localizedDescription)")
                }
            }
        }
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

struct FirebaseChatDetailView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var isProcessingAccept = false
    let chatRoom: ChatRoom
    let onBack: () -> Void
    
    // Hardcoded demo walker ID for checking
    private let demoWalkerID = "IWWdFgkCojc2y6TFDPVFFickuMm1"
    
    // Helper computed property to check if this is a demo chat
    private var isDemoChat: Bool {
        return chatRoom.walkerId == demoWalkerID
    }
    
    // Helper computed property to check if this chat needs walker acceptance
    private var needsWalkerAcceptance: Bool {
        let isWalker = Auth.auth().currentUser?.uid == chatRoom.walkerId
        return isWalker && chatRoom.ownerAccepted && !chatRoom.walkerAccepted
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
                
                if let profileImageURL = Auth.auth().currentUser?.uid == chatRoom.walkerId
                   ? chatRoom.ownerProfileImageURL
                   : chatRoom.walkerProfileImageURL,
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
                            .foregroundColor(isDemoChat ? Color.yellow : Color(hex: "FF6B6B"))
                            .padding(.leading, 8)
                    }
                } else {
                    Image(systemName: isDemoChat ? "star.circle.fill" : "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(isDemoChat ? Color.yellow : Color(hex: "FF6B6B"))
                        .padding(.leading, 8)
                }
                
                VStack(alignment: .leading) {
                    if Auth.auth().currentUser?.uid == chatRoom.walkerId {
                        Text("\(chatRoom.ownerName)'s \(chatRoom.dogName)")
                            .font(.system(size: 16, weight: .semibold))
                    } else {
                        Text(isDemoChat ? "\(chatRoom.walkerName) (Demo)" : chatRoom.walkerName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isDemoChat ? Color.orange : Color.primary)
                    }
                    
                    Text("Walk: \(chatRoom.walkDateTime.formatDateTime())")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isDemoChat {
                    // For demo chats, show an info button instead of a call button
                    Button(action: {
                        // Show demo information (could be implemented in the future)
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.yellow)
                            .padding(8)
                            .background(Color(hex: "FFFAE8"))
                            .clipShape(Circle())
                    }
                } else {
                    // Regular call button for non-demo chats
                    Button(action: {
                        // Call action (could be implemented in a future update)
                    }) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .padding(8)
                            .background(Color(hex: "FFE8E8"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
            .background(isDemoChat ? Color(hex: "FFFEF7") : Color.white)
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
                .background(Color(hex: "FFFAE8"))
                .cornerRadius(0)
            }
            
            // Walk request acceptance banner for walkers
            if needsWalkerAcceptance {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("New Walk Request!")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(chatRoom.ownerName) has requested you to walk \(chatRoom.dogName) on \(chatRoom.walkDateTime.formatDateTime())")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        acceptWalkAsWalker()
                    }) {
                        if isProcessingAccept {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 100, height: 36)
                                .background(Color.green.opacity(0.6))
                                .cornerRadius(18)
                        } else {
                            Text("Accept")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 36)
                                .background(Color.green)
                                .cornerRadius(18)
                        }
                    }
                    .disabled(isProcessingAccept)
                }
                .padding(12)
                .background(Color(hex: "4CAF50"))
                .cornerRadius(0)
            }
            
            // Chat messages
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(chatService.messages) { message in
                            MessageBubble(
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
                    .background(Color(hex: "F6F6F6"))
                    .cornerRadius(20)
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "FF6B6B"))
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
    
    private func acceptWalkAsWalker() {
        guard let chatRoomId = chatRoom.id, !isProcessingAccept else { return }
        
        isProcessingAccept = true
        
        chatService.walkerAcceptWalk(chatRoomId: chatRoomId) { result in
            DispatchQueue.main.async {
                isProcessingAccept = false
                
                switch result {
                case .success:
                    print("✅ Successfully accepted walk as walker")
                case .failure(let error):
                    print("⚠️ Failed to accept walk: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MessageBubble: View {
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
                            ? Color(hex: "FF6B6B") 
                            : (isDemoMessage ? Color(hex: "FFFAE8") : Color(hex: "F0F0F0"))
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

// Helper for hex colors
extension Color {
    init(hex: String) {
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
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ChatView: View {
    var body: some View {
        AcceptedChatView()
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

