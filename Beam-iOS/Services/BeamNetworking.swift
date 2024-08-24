//
//  OneNetworking.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class BeamNetworking {
    static let shared = BeamNetworking()
    
    var sharedUser: User?
    
    private enum FirestoreEndpoints {
        case users
        case transactions
        case withdraws
        
        func firestoreReference() -> CollectionReference {
            switch self {
            case .transactions:
                return Firestore.firestore().collection("Transactions")
            case .users:
                return Firestore.firestore().collection("Users")
            case .withdraws:
                return Firestore.firestore().collection("Withdrawls")
            }
        }
    }
    
    //MARK: USER PROFILE DATA CALLS
    
    /// Update the information for an existing user
    func createUser(userId: String, email: String, completionHandler: @escaping (Bool) -> Void) {
        let user = User(id: userId, userEmail: email, walletBalance: 0)
        
        do {
            try FirestoreEndpoints.users.firestoreReference().document(userId).setData(from: user)
            self.sharedUser = user // Update shared user with most recent instance.
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
    
    /// Get the currently logged in user's information
    func getUser(userId: String, completionHandler: @escaping (Bool) -> Void) {
        FirestoreEndpoints.users.firestoreReference().document(userId).getDocument { snapshot, error in
            if error != nil {
                completionHandler(false)
            } else {
                do {
                    let user = try snapshot?.data(as: User.self)
                    self.sharedUser = user
                    completionHandler(true)
                } catch {
                    completionHandler(false)
                }
            }
        }
    }
    
    /// Update the information for an existing user
    func updateUser(user: User, completionHandler: @escaping (Bool) -> Void) {
        guard let userId = user.id else { return completionHandler(false) }
        
        do {
            try FirestoreEndpoints.users.firestoreReference().document(userId).setData(from: user)
            self.sharedUser = user // Update shared user with most recent instance.
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
    
    // MARK: PAYMENT TRANSACTION DATA CALLS
    
    /// Transaction Functions
    func getAllTransactionsForUser(completionHandler: @escaping ([Transaction]?) -> Void) {
        guard let userId = self.sharedUser?.id else { return completionHandler(nil) }
        
        FirestoreEndpoints.transactions.firestoreReference().whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if error != nil {
                completionHandler(nil)
            } else {
                let transactions = snapshot?.documents.compactMap { try? $0.data(as: Transaction.self) }
                completionHandler(transactions)
            }
        }
    }
    
    //Pending Transactions
    func createPendingTransaction(transaction: Transaction, completionHandler: @escaping (Bool) -> Void) {
        do {
            try FirestoreEndpoints.transactions.firestoreReference().document().setData(from: transaction)
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
    
    // Match new transaction with a user on the platform.
    func matchTransaction(transaction: Transaction, completionHandler: @escaping (Bool) -> Void) {
        do {
            try FirestoreEndpoints.transactions.firestoreReference().document().setData(from: transaction)
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
    
    //MARK: WITHDRAW TRANSACTION DATA CALLS
    
    /// Withdrawl Functions
    func getAllWithdrawsForUser(completionHandler: @escaping ([Withdraw]?) -> Void) {
        guard let userId = self.sharedUser?.id else { return completionHandler(nil) }
        
        FirestoreEndpoints.withdraws.firestoreReference().whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if error != nil {
                completionHandler(nil)
            } else {
                let transactions = snapshot?.documents.compactMap { try? $0.data(as: Withdraw.self) }
                completionHandler(transactions)
            }
        }
    }
    
    func startWithdrawForUser(request: Withdraw, completionHandler: @escaping (Bool) -> Void) {
        // Perform a withdrawl transaction that sends a withdrawal request to the backend
        do {
            try FirestoreEndpoints.withdraws.firestoreReference().document().setData(from: request)
            completionHandler(true)
        } catch {
            completionHandler(false)
        }
    }
}
