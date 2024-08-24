//
//  OnboardingViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

// Set up profile data for user here.
class OnboardingViewController: UIViewController {
    
    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var phoneNumberTextField: UITextField!
    @IBOutlet private var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.phoneNumberTextField.delegate = self
    }
    
    @IBAction private func continueToNextStep(sender: UIButton) {
        guard var user = BeamNetworking.shared.sharedUser else { return } // Show an error here.
        
        user.firstName = self.firstNameTextField.text
        user.lastName = self.lastNameTextField.text
        user.phoneNumber = self.phoneNumberTextField.text
        
        BeamNetworking.shared.updateUser(user: user) { userUpdated in
            if userUpdated {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConnectPlatformsViewController") as! ConnectPlatformsViewController
                vc.fromOnboarding = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                // Show an error
            }
        }
    }

    func toggleContinueButton(isEnabled: Bool) {
        self.continueButton.alpha = isEnabled ? 1.0 : 0.5
        self.continueButton.isEnabled = isEnabled
    }
    // Give the user the opportunity to connect their platforms now, also a few screens about how the process works.
}

extension OnboardingViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard firstNameTextField.text?.isEmpty == false else { return toggleContinueButton(isEnabled: false) }
        guard lastNameTextField.text?.isEmpty == false else { return toggleContinueButton(isEnabled: false) }
        guard phoneNumberTextField.text?.count == 10 else { return toggleContinueButton(isEnabled: false) }
        
        self.toggleContinueButton(isEnabled: true)
    }
}
