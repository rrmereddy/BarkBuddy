import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Model Structures
struct ChatMessage: Identifiable, Codable, Equatable {
    var id: String?
    let senderId: String
    let senderName: String
    let receiverId: String
    let text: String
    let timestamp: Date
    let isRead: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case senderName
        case receiverId
        case text
        case timestamp
        case isRead
    }
    
    // Custom implementation of Equatable to compare ChatMessage objects
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        // Check if IDs are the same (if both have IDs)
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId == rhsId
        }
        
        // If either doesn't have an ID, compare all relevant fields
        return lhs.senderId == rhs.senderId &&
               lhs.senderName == rhs.senderName &&
               lhs.receiverId == rhs.receiverId &&
               lhs.text == rhs.text &&
               lhs.timestamp == rhs.timestamp &&
               lhs.isRead == rhs.isRead
    }
}

struct ChatRoom: Identifiable, Codable, Equatable {
    var id: String?
    let walkId: String
    let ownerId: String
    let ownerName: String
    let walkerId: String
    let walkerName: String
    let dogName: String
    let walkStatus: String
    let walkDateTime: Date
    let lastMessage: String
    let lastMessageTimestamp: Date
    let ownerProfileImageURL: String?
    let walkerProfileImageURL: String?
    let dogProfileImageURL: String?
    let ownerAccepted: Bool
    let walkerAccepted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case walkId
        case ownerId
        case ownerName
        case walkerId
        case walkerName
        case dogName
        case walkStatus
        case walkDateTime
        case lastMessage
        case lastMessageTimestamp
        case ownerProfileImageURL
        case walkerProfileImageURL
        case dogProfileImageURL
        case ownerAccepted
        case walkerAccepted
    }
    
    // Custom implementation of Equatable to compare ChatRoom objects
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        // Check if IDs are the same (if both have IDs)
        if let lhsId = lhs.id, let rhsId = rhs.id {
            return lhsId == rhsId
        }
        
        // If either doesn't have an ID, compare all relevant fields
        return lhs.walkId == rhs.walkId &&
               lhs.ownerId == rhs.ownerId &&
               lhs.ownerName == rhs.ownerName &&
               lhs.walkerId == rhs.walkerId &&
               lhs.walkerName == rhs.walkerName &&
               lhs.dogName == rhs.dogName &&
               lhs.walkStatus == rhs.walkStatus &&
               lhs.walkDateTime == rhs.walkDateTime &&
               lhs.lastMessage == rhs.lastMessage &&
               lhs.lastMessageTimestamp == rhs.lastMessageTimestamp &&
               lhs.ownerAccepted == rhs.ownerAccepted &&
               lhs.walkerAccepted == rhs.walkerAccepted
    }
}

// MARK: - Chat Service
class ChatService: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var chatRooms: [ChatRoom] = []
    @Published var messages: [ChatMessage] = []
    @Published var unreadMessagesCount: Int = 0
    
    private var chatRoomsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    private var unreadMessagesListener: ListenerRegistration?
    
    // Hardcoded demo walker ID
    private let demoWalkerID = "IWWdFgkCojc2y6TFDPVFFickuMm1"
    private let demoWalkerName = "Bella Anderson"
    
    // Demo walker automated responses
    private let demoResponses = [
        "Thanks for your message! This is a demo conversation to show how the chat system works.",
        "I've been working with dogs for over 5 years and would love to walk your dog!",
        "I'm available most days between 9am-5pm. When would work best for you?",
        "Your dog sounds wonderful! I can't wait to meet them.",
        "I always bring treats and toys on my walks. Does your dog have any favorites?",
        "Feel free to send any special instructions about your dog's needs.",
        "I'll make sure to follow all of your instructions for the walk.",
        "I can send you photos during our walk if you'd like!",
        "I've worked with many different breeds and temperaments.",
        "I'll make sure your dog gets plenty of exercise and attention!"
    ]
    
    // MARK: - Chat Rooms Functions
    
    /// Fetch chat rooms for a specific user (owner or walker)
    func fetchChatRooms(userId: String, isWalker: Bool) {
        // Remove any existing listener
        chatRoomsListener?.remove()
        
        // If this user is the demo walker, we want to show all chats with the demo walker
        if userId == demoWalkerID {
            print("📱 Demo walker logged in. Fetching all demo conversations.")
            
            // Set up listener for all chats where the demo walker is involved
            chatRoomsListener = db.collection("chatRooms")
                .whereField("walkerId", isEqualTo: demoWalkerID)
                .order(by: "lastMessageTimestamp", descending: true)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self, let snapshot = snapshot else {
                        print("Error fetching demo walker chat rooms: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    self.parseAndStoreChatRooms(snapshot: snapshot)
                }
            return
        }
        
        // Standard flow for regular users below
        
        // Determine the field to query based on user type
        let field = isWalker ? "walkerId" : "ownerId"
        
        // If this is an owner (not a walker), check if they already have 
        // a chat with our demo walker
        if !isWalker && userId != demoWalkerID {
            checkForDemoChatRoom(ownerId: userId)
        }
        
        // Set up listener for real-time updates
        chatRoomsListener = db.collection("chatRooms")
            .whereField(field, isEqualTo: userId)
            .order(by: "lastMessageTimestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else {
                    print("Error fetching chat rooms: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.parseAndStoreChatRooms(snapshot: snapshot)
            }
    }
    
    /// Helper method to parse chat room documents and update the published property
    private func parseAndStoreChatRooms(snapshot: QuerySnapshot) {
        // First parse all chat rooms from the snapshot
        var parsedRooms: [ChatRoom] = []
        
        for document in snapshot.documents {
            do {
                let data = document.data()
                
                // Extract fields manually
                guard let walkId = data["walkId"] as? String,
                      let ownerId = data["ownerId"] as? String,
                      let ownerName = data["ownerName"] as? String,
                      let walkerId = data["walkerId"] as? String,
                      let walkerName = data["walkerName"] as? String,
                      let dogName = data["dogName"] as? String,
                      let walkStatus = data["walkStatus"] as? String,
                      let walkDateTimeTimestamp = data["walkDateTime"] as? Timestamp,
                      let lastMessage = data["lastMessage"] as? String,
                      let lastMessageTimestampTimestamp = data["lastMessageTimestamp"] as? Timestamp else {
                    print("Missing required fields in chat room document")
                    continue
                }
                
                // Convert Timestamp to Date
                let walkDateTime = walkDateTimeTimestamp.dateValue()
                let lastMessageTimestamp = lastMessageTimestampTimestamp.dateValue()
                
                // Optional fields
                let ownerProfileImageURL = data["ownerProfileImageURL"] as? String
                let walkerProfileImageURL = data["walkerProfileImageURL"] as? String
                let dogProfileImageURL = data["dogProfileImageURL"] as? String
                
                // Create the ChatRoom object
                let chatRoom = ChatRoom(
                    id: document.documentID,
                    walkId: walkId,
                    ownerId: ownerId,
                    ownerName: ownerName,
                    walkerId: walkerId,
                    walkerName: walkerName,
                    dogName: dogName,
                    walkStatus: walkStatus,
                    walkDateTime: walkDateTime,
                    lastMessage: lastMessage,
                    lastMessageTimestamp: lastMessageTimestamp,
                    ownerProfileImageURL: ownerProfileImageURL,
                    walkerProfileImageURL: walkerProfileImageURL,
                    dogProfileImageURL: dogProfileImageURL,
                    ownerAccepted: data["ownerAccepted"] as? Bool ?? false,
                    walkerAccepted: data["walkerAccepted"] as? Bool ?? false
                )
                
                parsedRooms.append(chatRoom)
            } catch {
                print("Error parsing chat room: \(error)")
            }
        }
        
        // Sort the chat rooms - prioritize pending requests
        let currentUserId = Auth.auth().currentUser?.uid
        parsedRooms.sort { room1, room2 in
            // Check if the current user is a walker and has pending requests
            let isUserWalker1 = currentUserId == room1.walkerId
            let isUserWalker2 = currentUserId == room2.walkerId
            
            // For walkers: Pending requests (owner accepted, walker not yet) go to the top
            let isPending1 = isUserWalker1 && room1.ownerAccepted && !room1.walkerAccepted
            let isPending2 = isUserWalker2 && room2.ownerAccepted && !room2.walkerAccepted
            
            // First sort by pending status
            if isPending1 && !isPending2 {
                return true
            } else if !isPending1 && isPending2 {
                return false
            }
            
            // Then sort by timestamp (most recent first)
            return room1.lastMessageTimestamp > room2.lastMessageTimestamp
        }
        
        // Update the published property
        self.chatRooms = parsedRooms
    }
    
    /// Check if a demo chat room exists for this user with the demo walker
    private func checkForDemoChatRoom(ownerId: String) {
        db.collection("chatRooms")
            .whereField("ownerId", isEqualTo: ownerId)
            .whereField("walkerId", isEqualTo: demoWalkerID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                // If there's an error or no documents, create a demo chat room
                if let error = error {
                    print("Error checking for demo chat room: \(error.localizedDescription)")
                    self.createDemoChatRoom(ownerId: ownerId)
                    return
                }
                
                guard let snapshot = snapshot else {
                    self.createDemoChatRoom(ownerId: ownerId)
                    return
                }
                
                if snapshot.documents.isEmpty {
                    // No demo chat room exists, create one
                    self.createDemoChatRoom(ownerId: ownerId)
                } else {
                    // Chat room exists, but check if it's old (more than 2 days)
                    // If it is, update the timestamp to make it appear at the top
                    let document = snapshot.documents.first!
                    let data = document.data()
                    
                    if let lastMessageTimestamp = data["lastMessageTimestamp"] as? Timestamp {
                        let lastMessageDate = lastMessageTimestamp.dateValue()
                        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
                        
                        if lastMessageDate < twoDaysAgo {
                            // Update the timestamp to make it more recent
                            let updateData: [String: Any] = [
                                "lastMessageTimestamp": FieldValue.serverTimestamp()
                            ]
                            
                            self.db.collection("chatRooms").document(document.documentID).updateData(updateData) { error in
                                if let error = error {
                                    print("Error updating demo chat room timestamp: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
            }
    }
    
    /// Create a demo chat room with the hardcoded walker
    private func createDemoChatRoom(ownerId: String) {
        // First, get the owner's name from their user document
        db.collection("users").document(ownerId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            var ownerName = "Dog Owner"
            var dogName = "Max"
            
            if let document = document, document.exists {
                let data = document.data()
                // Try to extract owner's name from their user profile
                if let firstName = data?["firstName"] as? String,
                   let lastName = data?["lastName"] as? String {
                    ownerName = "\(firstName) \(lastName)"
                }
                
                // Try to get dog's name if it exists
                if let dogs = data?["dogs"] as? [[String: Any]],
                   let firstDog = dogs.first,
                   let firstDogName = firstDog["name"] as? String {
                    dogName = firstDogName
                }
            }
            
            // Create unique walk ID for the demo
            let walkId = "demo-\(ownerId)-\(UUID().uuidString)"
            
            // Create a future walk date (tomorrow)
            let walkDateTime = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            
            // Chat room data
            let chatRoomData: [String: Any] = [
                "walkId": walkId,
                "ownerId": ownerId,
                "ownerName": ownerName, 
                "walkerId": self.demoWalkerID,
                "walkerName": self.demoWalkerName,
                "dogName": dogName,
                "walkStatus": "Scheduled",
                "walkDateTime": walkDateTime,
                "lastMessage": "Hi! I'm your BarkBuddy guide. Tap here to see how messaging works.",
                "lastMessageTimestamp": FieldValue.serverTimestamp(),
                "ownerProfileImageURL": "",
                "walkerProfileImageURL": "",
                "dogProfileImageURL": "",
                "ownerAccepted": false,
                "walkerAccepted": false
            ]
            
            // Create the chat room document
            let docRef = self.db.collection("chatRooms").document()
            docRef.setData(chatRoomData) { error in
                if let error = error {
                    print("Error creating demo chat room: \(error.localizedDescription)")
                    return
                }
                
                // Add a welcome message
                let messageData: [String: Any] = [
                    "senderId": self.demoWalkerID,
                    "senderName": self.demoWalkerName,
                    "receiverId": ownerId,
                    "text": "Hi \(ownerName)! I'm excited to walk \(dogName) tomorrow. This is a demo conversation to show how BarkBuddy messaging works. Feel free to send me any questions!",
                    "timestamp": FieldValue.serverTimestamp(),
                    "isRead": false
                ]
                
                self.db.collection("chatRooms").document(docRef.documentID)
                    .collection("messages").addDocument(data: messageData) { error in
                        if let error = error {
                            print("Error adding demo message: \(error.localizedDescription)")
                        }
                    }
            }
        }
    }
    
    /// Create a new chat room for a walk
    func createChatRoom(walkId: String, ownerId: String, ownerName: String, walkerId: String, walkerName: String, dogName: String, walkDateTime: Date, walkStatus: String, ownerProfileImageURL: String?, walkerProfileImageURL: String?, completion: @escaping (Result<String, Error>) -> Void) {
        
        // Create the chat room data
        let chatRoomData: [String: Any] = [
            "walkId": walkId,
            "ownerId": ownerId,
            "ownerName": ownerName,
            "walkerId": walkerId,
            "walkerName": walkerName,
            "dogName": dogName,
            "walkStatus": walkStatus,
            "walkDateTime": walkDateTime,
            "lastMessage": "Chat started",
            "lastMessageTimestamp": FieldValue.serverTimestamp(),
            "ownerProfileImageURL": ownerProfileImageURL ?? "",
            "walkerProfileImageURL": walkerProfileImageURL ?? "",
            "dogProfileImageURL": "",
            "ownerAccepted": false,
            "walkerAccepted": false
        ]
        
        // Add document to Firestore
        let docRef = db.collection("chatRooms").document()
        docRef.setData(chatRoomData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(docRef.documentID))
            }
        }
    }
    
    /// Update chat room details
    func updateChatRoom(chatRoomId: String, updateData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("chatRooms").document(chatRoomId).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// Delete a chat room and its messages
    func deleteChatRoom(chatRoomId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // First, delete all messages in the chat room
        db.collection("chatRooms").document(chatRoomId).collection("messages").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting messages to delete: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Create a batch to delete all messages
            let batch = self.db.batch()
            snapshot?.documents.forEach { document in
                let messageRef = self.db.collection("chatRooms").document(chatRoomId).collection("messages").document(document.documentID)
                batch.deleteDocument(messageRef)
            }
            
            // Commit the batch deletion of messages
            batch.commit { error in
                if let error = error {
                    print("Error deleting messages: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                // Then delete the chat room document
                self.db.collection("chatRooms").document(chatRoomId).delete { error in
                    if let error = error {
                        print("Error deleting chat room: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("✅ Chat room and messages successfully deleted")
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    // MARK: - Messages Functions
    
    /// Fetch messages for a specific chat room
    func fetchMessages(chatRoomId: String) {
        // Remove any existing listener
        messagesListener?.remove()
        
        // Set up listener for real-time updates
        messagesListener = db.collection("chatRooms").document(chatRoomId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else {
                    print("Error fetching messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.messages = snapshot.documents.compactMap { document in
                    do {
                        let data = document.data()
                        
                        // Extract fields manually
                        guard let senderId = data["senderId"] as? String,
                              let senderName = data["senderName"] as? String,
                              let receiverId = data["receiverId"] as? String,
                              let text = data["text"] as? String,
                              let timestampValue = data["timestamp"] as? Timestamp else {
                            print("Missing required fields in message document")
                            return nil
                        }
                        
                        let isRead = data["isRead"] as? Bool ?? false
                        let timestamp = timestampValue.dateValue()
                        
                        // Create the Message object
                        var message = ChatMessage(
                            id: document.documentID,
                            senderId: senderId,
                            senderName: senderName,
                            receiverId: receiverId,
                            text: text,
                            timestamp: timestamp,
                            isRead: isRead
                        )
                        
                        return message
                    } catch {
                        print("Error parsing message: \(error)")
                        return nil
                    }
                }
            }
    }
    
    /// Send a new message
    func sendMessage(chatRoomId: String, senderId: String, senderName: String, receiverId: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        // Create the message data
        let messageData: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "receiverId": receiverId,
            "text": text,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ]
        
        // Add the message to the subcollection
        db.collection("chatRooms").document(chatRoomId).collection("messages").addDocument(data: messageData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update the chat room with the last message
            let updateData: [String: Any] = [
                "lastMessage": text,
                "lastMessageTimestamp": FieldValue.serverTimestamp()
            ]
            
            self.db.collection("chatRooms").document(chatRoomId).updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                    
                    // If this is a message to our demo walker, generate an automatic response
                    if receiverId == self.demoWalkerID {
                        self.sendAutomatedResponse(chatRoomId: chatRoomId, userId: senderId, userName: senderName)
                    }
                }
            }
        }
    }
    
    /// Send an automated response from the demo walker
    private func sendAutomatedResponse(chatRoomId: String, userId: String, userName: String) {
        // Wait 1-3 seconds before responding to simulate a real person typing
        let delaySeconds = Double.random(in: 1...3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            guard let self = self else { return }
            
            // Pick a random response from our list
            let randomIndex = Int.random(in: 0..<self.demoResponses.count)
            let responseText = self.demoResponses[randomIndex]
            
            // Create the message data
            let messageData: [String: Any] = [
                "senderId": self.demoWalkerID,
                "senderName": self.demoWalkerName,
                "receiverId": userId,
                "text": responseText,
                "timestamp": FieldValue.serverTimestamp(),
                "isRead": false
            ]
            
            // Add the message to the subcollection
            self.db.collection("chatRooms").document(chatRoomId).collection("messages").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending automated response: \(error.localizedDescription)")
                    return
                }
                
                // Update the chat room with the last message
                let updateData: [String: Any] = [
                    "lastMessage": responseText,
                    "lastMessageTimestamp": FieldValue.serverTimestamp()
                ]
                
                self.db.collection("chatRooms").document(chatRoomId).updateData(updateData) { error in
                    if let error = error {
                        print("Error updating chat room with automated response: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Mark all unread messages in a chat room as read
    func markMessagesAsRead(chatRoomId: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("chatRooms").document(chatRoomId).collection("messages")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion(.success(()))
                    return
                }
                
                let batch = self.db.batch()
                
                for document in documents {
                    let docRef = self.db.collection("chatRooms").document(chatRoomId)
                        .collection("messages").document(document.documentID)
                    batch.updateData(["isRead": true], forDocument: docRef)
                }
                
                batch.commit { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    // Clean up listeners when no longer needed
    func detachListeners() {
        chatRoomsListener?.remove()
        messagesListener?.remove()
        unreadMessagesListener?.remove()
    }
    
    /// Check for unread messages for the current user
    func checkUnreadMessages(userId: String) {
        // Remove any existing listener
        unreadMessagesListener?.remove()
        
        // Set up a listener across all chat rooms for messages where this user is the receiver and messages are unread
        unreadMessagesListener = db.collectionGroup("messages")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let snapshot = snapshot else {
                    print("Error checking for unread messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Update the unread messages count
                self.unreadMessagesCount = snapshot.documents.count
                print("📱 Unread messages for user \(userId): \(self.unreadMessagesCount)")
            }
    }
    
    /// Mark a walk as accepted by the owner
    func ownerAcceptWalk(chatRoomId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let updateData: [String: Any] = [
            "ownerAccepted": true,
            "lastMessage": "Owner accepted the walk request",
            "lastMessageTimestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("chatRooms").document(chatRoomId).updateData(updateData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error updating owner acceptance: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                // Get the chat room data to send a notification message
                self.db.collection("chatRooms").document(chatRoomId).getDocument { [weak self] snapshot, error in
                    guard let self = self, let data = snapshot?.data() else { return }
                    
                    if let ownerId = data["ownerId"] as? String,
                       let ownerName = data["ownerName"] as? String,
                       let walkerId = data["walkerId"] as? String,
                       let dogName = data["dogName"] as? String,
                       let walkDateTime = data["walkDateTime"] as? Timestamp {
                        
                        // Format the walk date for the message
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                        let formattedDate = dateFormatter.string(from: walkDateTime.dateValue())
                        
                        // Send a notification message to the walker about the new request
                        self.sendWalkRequestNotification(
                            chatRoomId: chatRoomId,
                            senderId: ownerId,
                            senderName: ownerName,
                            receiverId: walkerId,
                            dogName: dogName,
                            walkDateTime: formattedDate
                        )
                    }
                    
                    // If this is a demo chat, automatically accept from the walker side too after a delay
                    self.checkAndAutoAcceptForDemo(chatRoomId: chatRoomId)
                }
                
                completion(.success(()))
            }
        }
    }
    
    /// Send a notification message about a new walk request
    private func sendWalkRequestNotification(chatRoomId: String, senderId: String, senderName: String, receiverId: String, dogName: String, walkDateTime: String) {
        // Create a notification message
        let notificationText = "🔔 NEW WALK REQUEST: \(senderName) has requested you to walk \(dogName) on \(walkDateTime). Please accept or decline this request."
        
        // Create the message data
        let messageData: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "receiverId": receiverId,
            "text": notificationText,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ]
        
        // Add the message to the subcollection
        db.collection("chatRooms").document(chatRoomId)
            .collection("messages").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending walk request notification: \(error.localizedDescription)")
                } else {
                    print("✅ Walk request notification sent successfully")
                }
            }
    }
    
    /// Mark a walk as accepted by the walker
    func walkerAcceptWalk(chatRoomId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let updateData: [String: Any] = [
            "walkerAccepted": true,
            "walkStatus": "Confirmed",
            "lastMessage": "Walker accepted the walk. You're all set!",
            "lastMessageTimestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("chatRooms").document(chatRoomId).updateData(updateData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error updating walker acceptance: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                // Add a confirmation message to the chat
                self.db.collection("chatRooms").document(chatRoomId).getDocument { [weak self] snapshot, error in
                    guard let self = self, let data = snapshot?.data() else { return }
                    
                    if let ownerId = data["ownerId"] as? String, 
                       let walkerId = data["walkerId"] as? String,
                       let walkerName = data["walkerName"] as? String {
                        
                        let messageData: [String: Any] = [
                            "senderId": walkerId,
                            "senderName": walkerName,
                            "receiverId": ownerId,
                            "text": "Great! I've accepted the walk. I'm looking forward to meeting your dog!",
                            "timestamp": FieldValue.serverTimestamp(),
                            "isRead": false
                        ]
                        
                        self.db.collection("chatRooms").document(chatRoomId)
                            .collection("messages").addDocument(data: messageData) { error in
                                if let error = error {
                                    print("Error adding confirmation message: \(error.localizedDescription)")
                                }
                            }
                    }
                }
                
                completion(.success(()))
            }
        }
    }
    
    /// For demo chats: automatically accept from walker side after a short delay
    private func checkAndAutoAcceptForDemo(chatRoomId: String) {
        // Check if this is a demo chat
        db.collection("chatRooms").document(chatRoomId).getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            
            if let walkerId = data["walkerId"] as? String, walkerId == self.demoWalkerID {
                print("📱 This is a demo chat - will auto-accept from walker side after delay")
                
                // Wait 2-4 seconds before walker accepts (simulating real user)
                let delay = Double.random(in: 2...4)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let self = self else { return }
                    
                    self.walkerAcceptWalk(chatRoomId: chatRoomId) { result in
                        switch result {
                        case .success:
                            print("✅ Demo walker auto-accepted the walk")
                        case .failure(let error):
                            print("⚠️ Error in demo walker auto-accept: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Utility Extensions
extension ChatRoom {
    func partnerId(forUserId userId: String) -> String {
        return userId == ownerId ? walkerId : ownerId
    }
    
    func partnerName(forUserId userId: String) -> String {
        return userId == ownerId ? walkerName : ownerName
    }
    
    func partnerProfileImage(forUserId userId: String) -> String? {
        return userId == ownerId ? walkerProfileImageURL : ownerProfileImageURL
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formatDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
} 