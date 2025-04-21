//
//  AcceptedChatsWalker.swift
//  BarkBuddy
//
//  Created by Ravathur, Nishanth on 4/21/25.
//
import SwiftUI

struct AcceptedChatView: View {
    @State private var searchText = ""
    @State private var selectedChat: Chat?
    @State private var messageText = ""
    
    // Sample data
    let chats = [
        Chat(id: "1", dogOwnerName: "Emma", dogName: "Max", breed: "Golden Retriever", walkTime: "Today, 4:30 PM", lastMessage: "Hey! Looking forward to meeting Max today!", avatar: "person.circle.fill", dogAvatar: "dog1"),
        Chat(id: "2", dogOwnerName: "Jackson", dogName: "Luna", breed: "Husky", walkTime: "Tomorrow, 3:00 PM", lastMessage: "Luna loves the park by the river!", avatar: "person.circle.fill", dogAvatar: "dog2"),
        Chat(id: "3", dogOwnerName: "Olivia", dogName: "Bailey", breed: "Labrador", walkTime: "Today, 6:00 PM", lastMessage: "Bailey needs a good 30-minute walk today.", avatar: "person.circle.fill", dogAvatar: "dog3"),
        Chat(id: "4", dogOwnerName: "Liam", dogName: "Coco", breed: "Poodle", walkTime: "Wednesday, 5:15 PM", lastMessage: "Thanks for accepting! Coco can't wait!", avatar: "person.circle.fill", dogAvatar: "dog4")
    ]
    
    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter {
                $0.dogOwnerName.localizedCaseInsensitiveContains(searchText) ||
                $0.dogName.localizedCaseInsensitiveContains(searchText)
            }
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
                    Picker("Filter", selection: .constant(0)) {
                        Text("All Walks").tag(0)
                        Text("Today").tag(1)
                        Text("This Week").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    Text("Accepted Walks")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    
                    // Chat list
                    if selectedChat == nil {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredChats) { chat in
                                    ChatRow(chat: chat) {
                                        selectedChat = chat
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
                    } else {
                        // Chat detail view
                        ChatDetailView(chat: $selectedChat, messageText: $messageText)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct Chat: Identifiable {
    let id: String
    let dogOwnerName: String
    let dogName: String
    let breed: String
    let walkTime: String
    let lastMessage: String
    let avatar: String
    let dogAvatar: String
}

struct ChatRow: View {
    let chat: Chat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: chat.avatar)
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .background(Color(hex: "FFE8E8"))
                        .clipShape(Circle())
                    
                    Image(systemName: "pawprint.fill")
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .offset(x: 2, y: 2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(chat.dogOwnerName)'s \(chat.dogName)")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                        
                        Text(chat.walkTime)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Text(chat.breed)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChatDetailView: View {
    @Binding var chat: Chat?
    @Binding var messageText: String
    
    // Sample messages for the demo
    let messages = [
        Message(id: "1", isFromCurrentUser: false, text: "Hey! Looking forward to meeting Max today!", time: "1:24 PM"),
        Message(id: "2", isFromCurrentUser: true, text: "Hi! I'll be at the park entrance with Max. He's excited for the walk!", time: "1:30 PM"),
        Message(id: "3", isFromCurrentUser: false, text: "Perfect! I'll be wearing a blue jacket so you can spot me easily.", time: "1:32 PM"),
        Message(id: "4", isFromCurrentUser: true, text: "Great, see you at 4:30!", time: "1:35 PM"),
        Message(id: "5", isFromCurrentUser: false, text: "One question - does Max need a special leash or harness?", time: "1:40 PM")
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
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(hex: "FF6B6B"))
                    .padding(.leading, 8)
                
                VStack(alignment: .leading) {
                    Text("\(chat?.dogOwnerName ?? "")'s \(chat?.dogName ?? "")")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Walk: \(chat?.walkTime ?? "")")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    // Call action
                }) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .padding(8)
                        .background(Color(hex: "FFE8E8"))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Chat messages
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
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
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
                
                TextField("Message", text: $messageText)
                    .padding(10)
                    .background(Color(hex: "F6F6F6"))
                    .cornerRadius(20)
                
                Button(action: {
                    // Send message
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
        }
    }
}

struct Message: Identifiable {
    let id: String
    let isFromCurrentUser: Bool
    let text: String
    let time: String
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(message.text)
                    .padding(12)
                    .background(message.isFromCurrentUser ? Color(hex: "FF6B6B") : Color(hex: "F0F0F0"))
                    .foregroundColor(message.isFromCurrentUser ? .white : .black)
                    .cornerRadius(20)
                
                Text(message.time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromCurrentUser {
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

