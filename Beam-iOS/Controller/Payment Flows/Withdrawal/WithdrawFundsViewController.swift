//
//  WithdrawFundsViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

class WithdrawFundsViewController: UIViewController {

    @IBOutlet private var availableBalance: UILabel!
    @IBOutlet private var withdrawlAmount: UILabel!
    @IBOutlet private var continueButton: UIButton!
    
    var withdrawAmount: Double = 0.0
    var withdrawString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toggleContinueButton()
        
        guard let walletBalance = BeamNetworking.shared.sharedUser?.walletBalance else { return }
        self.availableBalance.text = "Avaliable Funds: $\(walletBalance)"
    }
    
    private func toggleContinueButton() {
        if withdrawAmount > 0 {
            self.continueButton.alpha = 1.0
            self.continueButton.isEnabled = true
        } else {
            self.continueButton.alpha = 0.5
            self.continueButton.isEnabled = false
        }
    }

    @IBAction private func updateWithdrawAmount(sender: UIButton) {
        // Allow the user to add or subtract numbers with the on screen number pad, if no value is available then put a 0 and make the continue button dim
        if sender.tag < 10 {
            // Add the number to the
            self.withdrawString.append(contentsOf: "\(sender.tag)")
        } else if sender.tag == 10 {
            self.withdrawString.append(".")
        } else {
            // Check if button is deleting
            self.withdrawString = self.withdrawString.dropLast().description
        }
        
        self.withdrawAmount = Double(withdrawString) ?? 0
        self.withdrawlAmount.text = "$" + withdrawString
        self.toggleContinueButton()
    }
    
    @IBAction private func continueWithdrawFlow(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlatformWithdrawViewController") as! SelectPlatformViewController
        vc.transactionType = .withdraw
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
