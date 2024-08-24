//
//  PlatformSheetViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 9/3/22.
//

import UIKit

protocol PlatformSheetDelegate: AnyObject {
    func didConnectPlatform(platform: Platform)
}

class PlatformSheetViewController: UIViewController {

    @IBOutlet private var platformLabel: UILabel!
    @IBOutlet private var platformTextField: UITextField!
    @IBOutlet private var connectButton: UIButton!
    @IBOutlet private var sheetView: UIView!
    
    var selectedPlatform: AvailablePlatforms?
    var delegate: PlatformSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.platformTextField.delegate = self
        self.sheetView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        // Do any additional setup after loading the view.
        if let selectedPlatform = selectedPlatform {
            self.platformLabel.text = selectedPlatform.platformLabel()
            self.platformTextField.placeholder = "Enter here to connect your account.."
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeModal))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .black.withAlphaComponent(0.7)
        }
    }
    
    @objc private func closeModal() {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .clear
        } completion: { _ in
            self.dismiss(animated: true)
        }
    }
    
    @IBAction private func connectPlatform(sender: UIButton) {
        guard platformTextField.text?.isEmpty == false, let username = platformTextField.text else { return }
        guard let selectedPlatform = selectedPlatform else { return }

        let platform = Platform(username: username, userLink: "", selectedPlatform: selectedPlatform, dateConnected: Date())
        self.delegate?.didConnectPlatform(platform: platform)
        self.dismiss(animated: true)
    }
}

extension PlatformSheetViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == false {
            self.connectButton.alpha = 1.0
            self.connectButton.isEnabled = true
        }
    }
}
