//
//  CompleteTransactionViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 6/2/22.
//

import UIKit

// Allow the user to enter a transaction id for the funds sent after showing details, warn them this step is important.
// Confirm money has been received (long spinner of some sort) - Firebase hook.
class CompleteTransactionViewController: UIViewController {
    
    @IBOutlet private var transactionIDTextField: UITextField!
    @IBOutlet private var transactionFoundLabel: UILabel!
    @IBOutlet private var finishButton: UIButton!
    
    var selectedPlatform: AvailablePlatforms!
    
    private var transactionsFromListener: [Transaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.finishButton.alpha = 0.5
        self.finishButton.isEnabled = false
        self.transactionIDTextField.delegate = self
    }
    
    //TODO: Need a firebase listener for new transactions created and make sure we find the right one after data is entered into the ID field.
    private func startListeningForTransaction() {
        BeamNetworking.shared.getAllTransactionsForUser { transactions in
            if let transactions = transactions {
                self.transactionsFromListener = transactions
                self.attemptToMatchTransaction()
            }
        }
    }
    
    private func attemptToMatchTransaction() {
        // Updated the matched transaction label here if the listener has found a paired transaction
        guard let transactionID = self.transactionIDTextField.text else { return }
        
        if var transaction = transactionsFromListener.first(where: { $0.transactionId == transactionID }) {
            // Update the transaction on the backend so that we can confirm this one has been paired.
            
            if let userId = BeamNetworking.shared.sharedUser?.id {
                transaction.userId = userId
                
                BeamNetworking.shared.matchTransaction(transaction: transaction) { success in
                    if success {
                        self.transactionFoundLabel.text = "Your transaction has been found and paired. The funds have been deposited into your account. Please tap the button below to complete your transaction."
                    }
                }
            }
        }
    }
    
    @IBAction private func howToFindID(sender: UIButton) {
        //TODO: Show the user how to find the ID per platform
    }
    
    @IBAction private func finishPaymentFlow(sender: UIButton) {
        // If the transaction is not paired while on the screen, create a temporary transaction here..
        guard let userId = BeamNetworking.shared.sharedUser?.id, let transactionId = self.transactionIDTextField.text else { return }
//        let pendingTransaction = Transaction(platform: selectedPlatform, sendDate: Date(), userId: userId, transactionId: transactionId, transactionStatus: .unpaired)
        let pendingTransaction = Transaction(platform: selectedPlatform, userId: userId, transactionId: transactionId, transactionStatus: .unpaired)
        BeamNetworking.shared.createPendingTransaction(transaction: pendingTransaction) { completed in
            if completed {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

extension CompleteTransactionViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.count ?? 0) > 0 {
            self.finishButton.alpha = 1.0
            self.finishButton.isEnabled = true
        }
    }
}
