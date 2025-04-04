//
//  AppModels.swift
//  BarkBuddy
//
//  Created by Storms, Trinity on 4/5/25.
//

//using this file as a way to hold structures we need for the app to run properly

import SwiftUI

class Users{ //naming the structure after the collection in firebase
    // Properties to store user information
    var first: String
    var last: String
    var email: String
    var phone: String
    var ID: String //this is the corresponding ID from the document in firebase
    var currentLocation: String // For a current user, this allows the app to determine what services are nearby
    var futureAppointments:[String] //not exactly sure how we're gonna store this data, but [String] should work for now
    var pastAppointments:[String] //^^ same situation as futureAppointments
    
    
    init(first: String, last: String, email: String, phone: String, ID: String, currentLocation: String, sessionStart: Date, futureAppointments: [String], pastAppointments: [String]) {
        self.first = first
        self.last = last
        self.email = email
        self.phone = phone
        self.ID = ID
        self.currentLocation = currentLocation
        self.futureAppointments = futureAppointments
        self.pastAppointments = pastAppointments
    }
} //end of Users class
// ***Notes for Users class***
// in a file holding functions for the app (or maybe we just have one purely for our firebase related functions?), we need to have a function that creates a user from firebase
// We'll probably want a pet class? Connect it to owner with the owner's ID maybe?
// We might want to add a variable to keep track of who our current user is

// separate class for Walkers, they do different duties in the app so it should make sense?

class Walker {
    var ID: String
    var first: String
    var last: String
    var email: String
    var phone: String
    var photo: String
    var rating: Int
    var location: String
    var isAvailable: Bool //this will be calculated with a func probably
    var futureAppointments: [String] // this will help us determine availability
    var services: [String]
    var tags: [String]
    
    init(ID: String, first: String, last: String, email: String, phone: String, photo: String, rating: Int, location: String, isAvailable: Bool = true, futureAppointments: [String], services: [String], tags: [String]) {
            self.ID = ID
            self.first = first
            self.last = last
            self.email = email
            self.phone = phone
            self.photo = photo
            self.rating = rating
            self.location = location
            self.isAvailable = isAvailable
            self.futureAppointments = futureAppointments
            self.services = services
            self.tags = tags
        }
    

    } //end of walker class
// this class will need to be connected to firebase
// going to need some functions to calculate availability
