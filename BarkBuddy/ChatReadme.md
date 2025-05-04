# BarkBuddy Chat Functionality

This document provides detailed instructions on how to use and integrate the chat functionality implemented in the BarkBuddy app.

## Overview

The chat system in BarkBuddy enables direct communication between dog owners and dog walkers. It's designed to facilitate conversations before, during, and after dog walks, allowing for:

- Pre-walk coordination and instructions
- Real-time updates during walks
- Post-walk feedback and follow-up communications

## Components

The chat system includes:

1. **ChatService.swift** - Core service that manages all Firebase interactions
2. **AcceptedChatsWalker.swift** - Chat interface for dog walkers
3. **AcceptedChatsOwner.swift** - Chat interface for dog owners
4. **ChatRoomCreationExample.swift** - Demonstration of creating chat rooms
5. **FirebaseSecurityRules.txt** - Recommended security rules for Firebase

## Demo Walker Feature

The chat system includes a demonstration feature that automatically creates a chat with a hardcoded demo walker (ID: `IWWdFgkCojc2y6TFDPVFFickuMm1`) for every dog owner. This provides the following benefits:

1. Users can immediately experience the chat functionality without needing a real walker match
2. The demo walker automatically responds to messages, simulating a real conversation
3. Demo chats are visually distinguished with yellow/orange styling and "Demo" labels
4. The automated responses help users understand how to use the chat feature

### How It Works

When a dog owner opens the chat view:
1. The app checks if they already have a chat with the demo walker
2. If not, it creates a new chat room with a welcome message
3. When the user sends a message, the demo walker automatically responds
4. The demo walker's responses are chosen randomly from a predefined list

### Demo Walker Account Access

The system also provides special handling when logged in as the demo walker account:

1. When logged in with the demo walker ID (`IWWdFgkCojc2y6TFDPVFFickuMm1`), you can see all conversations with dog owners
2. The walker view displays a special banner indicating you're using the demo account
3. All automated conversations are accessible and organized by most recent activity
4. This allows administrators to monitor and test the demo conversations from the walker's perspective

This feature can be disabled by removing or commenting out the `checkForDemoChatRoom` call in the `fetchChatRooms` method of `ChatService.swift`.

## Data Models

### ChatRoom

Represents a conversation between a dog owner and walker:

```swift
struct ChatRoom: Identifiable, Codable {
    var id: String?
    let walkId: String
    let ownerId: String
    let ownerName: String
    let dogName: String
    let walkerId: String
    let walkerName: String
    var walkDateTime: Date
    var walkStatus: String
    var lastMessage: String
    var lastMessageTimestamp: Date
    var ownerProfileImageURL: String?
    var walkerProfileImageURL: String?
    var dogProfileImageURL: String?
}
```

### ChatMessage

Represents an individual message within a chat room:

```swift
struct ChatMessage: Identifiable, Codable {
    var id: String?
    let senderId: String
    let senderName: String
    let receiverId: String
    let text: String
    let timestamp: Date
    var isRead: Bool
}
```

## Setup Instructions

### 1. Firebase Configuration

Ensure you have the following Firebase services enabled:

- **Firebase Authentication** - For user identity
- **Cloud Firestore** - For storing chat data
- **Firebase Storage** - For storing profile images and attachments (future)

### 2. Security Rules

Copy the rules from `FirebaseSecurityRules.txt` to your Firebase console:

1. Go to the Firebase Console
2. Select your project
3. Navigate to Firestore Database > Rules
4. Paste the Firestore rules
5. Navigate to Storage > Rules
6. Paste the Storage rules

### 3. Integration Points

#### When a Walk is Requested

```swift
// After a walk request is created and accepted
chatService.createChatRoom(
    walkId: walkData.id,
    ownerId: ownerUserId,
    ownerName: ownerName,
    dogName: dogName,
    walkerId: walkerUserId,
    walkerName: walkerName,
    walkDateTime: walkDateTime,
    walkStatus: "Scheduled",
    ownerProfileImageURL: ownerProfileImageURL,
    walkerProfileImageURL: walkerProfileImageURL
) { result in
    // Handle result
}
```

#### Sending Messages

```swift
chatService.sendMessage(
    chatRoomId: chatRoomId,
    senderId: currentUserId,
    senderName: currentUserName,
    receiverId: otherUserId,
    text: messageText
) { result in
    // Handle result
}
```

#### Updating Walk Status

```swift
chatService.updateChatRoom(
    chatRoomId: chatRoomId,
    updateData: ["walkStatus": "In Progress"]
) { result in
    // Handle result
}
```

## Navigation

### Navigating to Chats from HomeView

For dog owners, add a button in the HomeView that navigates to `DogOwnerChatView()`:

```swift
NavigationLink(destination: DogOwnerChatView()) {
    Image(systemName: "message.fill")
        .font(.system(size: 22))
        .foregroundColor(Color(hex: "FF6B6B"))
}
```

For dog walkers, add a button that navigates to `AcceptedChatView()`:

```swift
NavigationLink(destination: AcceptedChatView()) {
    Image(systemName: "message.fill")
        .font(.system(size: 22))
        .foregroundColor(Color(hex: "FF6B6B"))
}
```

## Using the Chat Interface

Both chat interfaces (for owners and walkers) provide:

1. A list of active chats, filterable by time period
2. A search function to find specific chats
3. A detailed chat view showing the conversation history
4. A text input for sending messages

## Handling Errors

The `ChatService` uses a completion handler pattern with Swift `Result` type to handle success and errors. Always implement proper error handling:

```swift
chatService.someFunction(...) { result in
    switch result {
    case .success(let data):
        // Handle success
    case .failure(let error):
        // Display error to user
        print("Error: \(error.localizedDescription)")
    }
}
```

## Best Practices

1. **Always detach listeners** when views disappear to prevent memory leaks:
   ```swift
   .onDisappear {
       chatService.detachListeners()
   }
   ```

2. **Handle offline state** by implementing proper error messages when no internet connection is available

3. **Mark messages as read** when opening a chat to improve user experience

4. **Implement push notifications** for new messages (future enhancement)

## Firestore Database Structure

The chat functionality uses the following Firestore collections:

```
/chatRooms/{chatRoomId}   // Chat room documents
/chatRooms/{chatRoomId}/messages/{messageId}   // Messages in a chat room
/users/{userId}   // User profiles
/walks/{walkId}   // Walk information
```

## Implementation Notes

### Manual Firestore Data Handling

This implementation manually handles data conversion between Firestore and Swift objects without relying on FirebaseFirestoreSwift. This provides:

1. **Better compatibility** - No need for additional Swift packages
2. **More robust error handling** - Explicit checks for required fields
3. **Flexibility** - Easy to adapt to changing data structures

If you want to use FirebaseFirestoreSwift in the future:

1. Add the Swift Package to your project
2. Replace manual data conversion with `document.data(as: Type.self)`
3. Add `@DocumentID` to the id properties on your model structs

### Timestamp Handling

Remember that Firestore saves dates as Timestamp objects which need to be converted:

```swift
// Converting Timestamp to Date
let timestamp = data["timestamp"] as? Timestamp
let date = timestamp?.dateValue()

// Saving Date to Firestore
let data: [String: Any] = [
    "date": FieldValue.serverTimestamp() // For server-generated timestamps
    // or
    "date": Timestamp(date: myDate) // For client-specified dates
]
```

## Future Enhancements

Consider these enhancements for future versions:

1. **Image/file attachments** - Allow users to share photos during walks
2. **Read receipts** - Show when messages have been read
3. **Typing indicators** - Show when the other user is typing
4. **Push notifications** - Notify users of new messages
5. **Message reactions** - Allow users to react to messages

## Troubleshooting

### Common Issues

1. **Messages not appearing in real-time**
   - Check if listeners are properly attached in `.onAppear`
   - Verify Firestore security rules allow read access

2. **Unable to send messages**
   - Verify user authentication status
   - Check Firestore security rules allow write access
   - Ensure all required fields are provided

3. **Chat rooms not loading**
   - Verify user ID retrieval is working correctly
   - Check network connectivity

For additional help, refer to the Firebase documentation or contact the development team. 