//
//  TransactionDetailViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

class TransactionDetailViewController: UIViewController {

    @IBOutlet private var largeAppImage: UIImageView!
    @IBOutlet private var transactionDate: UILabel!
    @IBOutlet private var transactionName: UILabel!
    @IBOutlet private var transactionAmount: UILabel!
    @IBOutlet private var transactionFullDescription: UILabel!
    
    var transaction: Transaction?
    var pendingTransaction: Transaction?
    
    var dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = ""
        return dateformatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateDetailScreen()
    }
    
    func updateDetailScreen() {
        guard let transaction = transaction else { return }

        self.largeAppImage.image = transaction.platform.imageForPlatform
//        self.transactionDate.text = dateFormatter.string(from: transaction.sendDate)
        self.transactionName.text = transaction.paymentDescription
        self.transactionAmount.text = transaction.paymentAmount
    }
}
