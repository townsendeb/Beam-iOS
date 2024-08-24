//
//  TransactionTableViewCell.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet private var platformImage: UIImageView!
    @IBOutlet private var transactionName: UILabel!
    @IBOutlet private var transactionAmount: UILabel!
    @IBOutlet private var transactionTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellFor(transaction: Transaction) {
        self.platformImage.image = transaction.platform.imageForPlatform
//        self.transactionTime.text = transaction.sendDate
        self.transactionName.text = transaction.paymentDescription
        self.transactionAmount.text = transaction.paymentAmount
    }
    
    func configureCellFor(withdrawal: Withdraw) {
        self.platformImage.image = withdrawal.platform.selectedPlatform.imageForPlatform
        self.transactionName.text = "Sent funds to \(withdrawal.platform.selectedPlatform.rawValue)"
        self.transactionAmount.text = "$\(withdrawal.withdrawAmount)"
    }

    //TODO: Define what a pending transaction should look like from a small view perspective.
    func configureCellFor(pending: Transaction) {
        
        self.platformImage.image = pending.platform.imageForPlatform
//        self.transactionName.text = pending.
//        self.transactionAmount.text = transaction.paymentAmount
    }
}
