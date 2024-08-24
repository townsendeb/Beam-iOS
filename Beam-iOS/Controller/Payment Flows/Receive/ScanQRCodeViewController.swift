//
//  ScanQRCodeViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 6/2/22.
//

import UIKit
import CoreImage

// Display the One P2P code here to start the receive flow, whomever is sending money to this user should scan this code
class ScanQRCodeViewController: UIViewController {

    @IBOutlet private var qrCode: UIImageView!
    @IBOutlet private var platformLabel: UILabel!
    
    var selectedPlatform: AvailablePlatforms!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.qrCode.image = self.generateQRCode(from: selectedPlatform.qrCodeLink)
    }
    
    @IBAction private func continuePaymentFlow(sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompleteTransactionViewController") as! CompleteTransactionViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
