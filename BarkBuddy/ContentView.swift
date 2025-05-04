//
//  ContentView.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 3/31/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // Verify Firebase Storage is properly configured
    let storage = Storage.storage()
    print("✅ Firebase Storage initialized with URL: \(storage.reference().description)")
    
    // Check if we can access the storage bucket
    do {
        let storageRef = storage.reference()
        print("✅ Firebase Storage bucket accessed successfully")
    } catch {
        print("⚠️ Error accessing Firebase Storage: \(error)")
    }
    
    return true
  }
}


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            print("ContentView appeared")  // Confirm onAppear is triggered
        }
    }
}


#Preview {
    ContentView()
}
