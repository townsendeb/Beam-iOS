//
//  WithdrawalDetailViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

class WithdrawalDetailViewController: UIViewController {
    
    @IBOutlet private var largeAppImage: UIImageView!
    @IBOutlet private var transactionDate: UILabel!
    @IBOutlet private var transactionName: UILabel!
    @IBOutlet private var transactionAmount: UILabel!
    @IBOutlet private var transactionFullDescription: UILabel!

    var transaction: Withdraw?
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
        guard let withdraw = transaction else { return }

        self.largeAppImage.image = withdraw.platform.selectedPlatform.imageForPlatform
        self.transactionDate.text = dateFormatter.string(from: withdraw.withdrawRequestDate)
        self.transactionName.text = "Sent funds to \(withdraw.platform.selectedPlatform.rawValue)"
        self.transactionAmount.text = "$\(withdraw.withdrawAmount)"
    }
}
