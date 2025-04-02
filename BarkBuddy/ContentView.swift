//
//  ContentView.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 3/31/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
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
            Task {
                await addTestUser()
            }
        }
    }
    
    func addTestUser() async {
        let db = Firestore.firestore()
        do {
            let ref = try await db.collection("Users").addDocument(data: [
                "first": "Ada",
                "last": "Lovelace",
                "born": 1815
            ])
            print("Document added with ID: \(ref.documentID)")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
        }
    }
}


#Preview {
    ContentView()
}
