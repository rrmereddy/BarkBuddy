//
//  BarkBuddyApp.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 3/31/25.
//

import SwiftUI
import FirebaseCore

@main
struct BarkBuddyApp: App {
    // This registers your AppDelegate so Firebase is configured on launch.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

