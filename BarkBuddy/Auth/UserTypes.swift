//
//  UserTypes.swift
//  BarkBuddy
//
//  Created by Ritin Mereddy on 4/21/25.
//

import SwiftUI

enum UserType: String, CaseIterable, Identifiable {
    case dogOwner = "Dog Owner"
    case dogWalker = "Dog Walker"
    
    var id: String { self.rawValue }
}
