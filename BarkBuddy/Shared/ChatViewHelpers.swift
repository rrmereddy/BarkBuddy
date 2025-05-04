import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Common Utility Extensions

// Shared utilities for hex colors - renamed to avoid conflicts
extension Color {
    // This is the shared implementation that should be used app-wide
    static func fromHexCode(_ hex: String) -> Color {
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

// Helper function for status color
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

// MARK: - Shared Chat Components

// MessageBubble view that can be shared between owner and walker
struct MessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    let isDemoMessage: Bool
    private let demoWalkerID = "IWWdFgkCojc2y6TFDPVFFickuMm1"
    
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
                            ? Color.fromHexCode("FF6B6B") 
                            : (isDemoMessage ? Color.fromHexCode("FFFAE8") : Color.fromHexCode("F0F0F0"))
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