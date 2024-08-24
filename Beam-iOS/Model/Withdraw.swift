//
//  WithdrawlRequest.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum WithdrawStatus: String, Codable {
    case pending
    case completed
}

struct Withdraw: Codable {
    @DocumentID var id: String?
    
    var platform: Platform
    var withdrawRequestDate: Date
    var withdrawCompletedDate: Date?
    var withdrawAmount: Double
    var paymentLink: String
    var userId: String
    var withdrawStatus: WithdrawStatus
}
