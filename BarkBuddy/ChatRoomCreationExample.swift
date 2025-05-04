import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// This file provides examples of how to create chat rooms when walks are requested/accepted
// These functions should be integrated into your walk request/acceptance flow

struct ChatRoomCreationExample: View {
    @StateObject private var chatService = ChatService()
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    // Example walk data that would come from your walk request
    let exampleWalkData = WalkRequestData(
        walkId: UUID().uuidString,
        ownerId: "owner_user_id", // This would be the actual owner ID from Auth
        ownerName: "Emma Johnson",
        dogName: "Max",
        walkerId: "walker_user_id", // This would be the actual walker ID from Auth
        walkerName: "Jake Smith",
        walkDateTime: Date().addingTimeInterval(86400), // Tomorrow
        walkDuration: 30,
        walkLocation: "Central Park",
        walkStatus: "Scheduled"
    )
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chat Room Creation Example")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This demonstrates how to create a chat room when a walk is requested or accepted")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: createChatRoomExample) {
                Text("Create Chat Room for Walk")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.fromHexCode("FF6B6B"))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Note: In a real app, you would integrate this into your walk request flow")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
        .alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Chat Room Creation"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Example function to create a chat room when a walk is requested/accepted
    private func createChatRoomExample() {
        // In a real app, this would be integrated into the walk acceptance flow
        let data = exampleWalkData
        
        // Create the chat room
        chatService.createChatRoom(
            walkId: data.walkId,
            ownerId: data.ownerId,
            ownerName: data.ownerName,
            walkerId: data.walkerId,
            walkerName: data.walkerName,
            dogName: data.dogName,
            walkDateTime: data.walkDateTime,
            walkStatus: data.walkStatus,
            ownerProfileImageURL: "", // You would provide actual URLs here
            walkerProfileImageURL: ""
        ) { result in
            switch result {
            case .success(let chatRoomId):
                // Send initial welcome message
                sendWelcomeMessage(chatRoomId: chatRoomId, data: data)
            case .failure(let error):
                alertMessage = "Error creating chat room: \(error.localizedDescription)"
                isShowingAlert = true
            }
        }
    }
    
    // Send a welcome message when a chat room is created
    private func sendWelcomeMessage(chatRoomId: String, data: WalkRequestData) {
        // In a real app, you might want to send this message from the system or from the walker
        
        // Example: System sends welcome message
        chatService.sendMessage(
            chatRoomId: chatRoomId,
            senderId: data.walkerId, // Using walker ID for this example
            senderName: data.walkerName,
            receiverId: data.ownerId,
            text: "Hi \(data.ownerName)! I'm excited to walk \(data.dogName) on \(formatDate(data.walkDateTime)). Feel free to send me any special instructions or questions!"
        ) { result in
            switch result {
            case .success:
                alertMessage = "Chat room created and welcome message sent successfully!"
                isShowingAlert = true
            case .failure(let error):
                alertMessage = "Error sending welcome message: \(error.localizedDescription)"
                isShowingAlert = true
            }
        }
    }
    
    // Helper to format date to a readable string
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Example data structure for a walk request
struct WalkRequestData {
    let walkId: String
    let ownerId: String
    let ownerName: String
    let dogName: String
    let walkerId: String
    let walkerName: String
    let walkDateTime: Date
    let walkDuration: Int
    let walkLocation: String
    let walkStatus: String
}

// MARK: - Real-World Integration Instructions

/*
 How to Integrate Chat Room Creation Into Your Walk Flow:
 
 1. When a walk is requested:
    - The owner requests a walk with a specific walker
    - Before completing the request, call chatService.createChatRoom() with all necessary details
    - This creates a document in Firestore that both users can access
 
 2. When a walker accepts a walk:
    - The walker accepts the walk request
    - Update the chat room status using chatService.updateChatRoom()
    - Send an automatic message using chatService.sendMessage() to notify the owner
 
 3. During the walk:
    - Update the chat room status to "In Progress"
    - Both parties can exchange messages through the chat interface
 
 4. After the walk:
    - Update the chat room status to "Completed"
    - Optionally send an automatic message thanking the owner
 
 5. Cancellations:
    - Update the chat room status to "Cancelled"
    - Send an automatic message explaining the cancellation
 
 Note: Ensure you have proper error handling in all these flows
 */ 