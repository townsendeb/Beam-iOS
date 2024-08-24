//
//  OneUser.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable {
    @DocumentID var id: String?
    
    var firstName: String?
    var lastName: String?
    var userEmail: String
    var phoneNumber: String?
    var walletBalance: Int = 0
    var connectedPlatforms: [Platform] = []
    
    //TODO: Create a way to keep this balance in sync - this should be calculated after every load of the users transactions. total from transactions - total of withdraws = current balance.
    
    var fullName: String {
        return (firstName ?? "") + " " + (lastName ?? "")
    }
    
    var onboardingComplete: Bool {
        return firstName != nil && lastName != nil && phoneNumber != nil
    }
}
