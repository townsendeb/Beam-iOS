//
//  UIViewController+Extension.swift
//  OneP2P
//
//  Created by Eric Townsend on 8/27/22.
//

import Foundation
import UIKit

extension UIViewController {
    @IBAction public func goBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction public func closeScreen(sender: UIButton) {
        self.dismiss(animated: true)
    }
}
