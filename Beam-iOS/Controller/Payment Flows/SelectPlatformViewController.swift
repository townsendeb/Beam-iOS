//
//  ReceivePaymentViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

// A user selects this to start a transaction flow. We must know what platform is being used before continuing.
class SelectPlatformViewController: UIViewController {
    @IBOutlet private var platformCollectionView: PlatformsCollectionView!
    @IBOutlet private var continueButton: UIButton!
    
    private var selectedPlatform: AvailablePlatforms?
    var transactionType: TransactionType = .transaction
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueButton.isEnabled = false
        self.continueButton.alpha = 0.5

        if transactionType == .transaction {
            platformCollectionView.platforms = AvailablePlatforms.allCases
        } else {
            guard let user = BeamNetworking.shared.sharedUser else { return }
            platformCollectionView.showConnectedPlatforms = true
            platformCollectionView.platforms = user.connectedPlatforms.compactMap({ $0.selectedPlatform })
        }
        
        // Allow the user to start the flow in which they select the platform the money is coming from
        platformCollectionView.platformDelegate = self
        platformCollectionView.collectionView.reloadData()
    }
    
    @IBAction private func continuePaymentFlow(sender: UIButton) {
        if transactionType == .transaction {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScanQRCodeViewController") as! ScanQRCodeViewController
            vc.selectedPlatform = selectedPlatform
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmWithdrawViewController") as! ConfirmWithdrawViewController
            vc.selectedPlatform = selectedPlatform
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SelectPlatformViewController: PlatformsCollectionViewDelegate {
    func didSelect(platform: AvailablePlatforms) {
        self.continueButton.isEnabled = true
        self.continueButton.alpha = 1.0
        
        self.selectedPlatform = platform
    }
}
