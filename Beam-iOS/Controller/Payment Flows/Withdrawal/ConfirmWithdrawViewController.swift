//
//  ConfirmWithdrawViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 6/2/22.
//

import UIKit

class ConfirmWithdrawViewController: UITableViewController {
    
    @IBOutlet private var withdrawAmount: UILabel!
    @IBOutlet private var platformName: UILabel!
//    @IBOutlet private var platformIcon: UIImageView!
    @IBOutlet private var receiveAmount: UILabel!
    @IBOutlet private var feeAmount: UILabel!
    @IBOutlet private var currentBalance: UILabel!
    
    var selectedPlatform: AvailablePlatforms!
    var withdrawlAmount: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction private func withdrawFunds(sender: UIButton) {
        guard let user = BeamNetworking.shared.sharedUser,
              let userId = user.id,
              let platform = user.connectedPlatforms.first(where: { $0.selectedPlatform == selectedPlatform }) else { return }
        
        // Send withdraw request to the backend
        let withdrawRequest = Withdraw(platform: platform,
                                       withdrawRequestDate: Date(),
                                       withdrawAmount: withdrawlAmount,
                                       paymentLink: platform.userLink,
                                       userId: userId,
                                       withdrawStatus: .pending)
        BeamNetworking.shared.startWithdrawForUser(request: withdrawRequest) { complete in
            if complete {
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                //TODO: Show an errorhere
            }
        }
    }
}
