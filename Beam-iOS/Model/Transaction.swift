//
//  ReceivedTransaction.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum TransactionStatus: String, Codable {
    case unpaired
    case paired
}

enum TransactionType: Int, CaseIterable {
    case transaction = 0
    case withdraw = 1
    case pendingTransaction = 2
    case pendingWithdraw = 3
}

struct Transaction: Codable {
    @DocumentID var id: String?
    
    var platform: AvailablePlatforms
//    var sendDate: Date
    var paymentDescription: String?
    var userId: String?
    var transactionId: String
    var transactionStatus: TransactionStatus
    
    var paymentAmount: String {
        return paymentDescription?.components(separatedBy: " ").first(where: { $0.contains("$") }) ?? "$0.00"
    }
}
