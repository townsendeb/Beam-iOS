//
//  OnePlatform.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

enum AvailablePlatforms: String, CaseIterable, Codable {
    case cashapp = "Cash App"
    case venmo = "Venmo"
    case zelle = "Zelle"
    case paypal = "Paypal"
    
    var imageForPlatform: UIImage? {
        return UIImage(named: self.rawValue)
    }
    
    func platformLabel() -> String {
        switch self {
        case .cashapp:
            return "Add your Ca$h tag or link"
        case .venmo:
            return "Add your Venmo username or link"
        case .zelle:
            return "Add your Zelle phone number"
        case .paypal:
            return "Add your Paypal username or link"
        }
    }
    
    var qrCodeLink: String {
        switch self {
        case .cashapp:
            return "https://cash.app/\(platformUserName)"
        case .venmo:
            return "https://venmo.com/code?user_id=3620849118610743400"
        case .paypal:
            return "https://www.paypal.me/beampayments"
        case .zelle:
            return "https://enroll.zellepay.com/qr-codes? data=ewogICJ0b2tlbiIgOiAiajJrZWludmVzdG1lbnRzQGdtYWlsLmNvbSIsCiAgIm5hbWUiIDogIkoyS0UgVkVOVFVSRVMgTExDIiwKICAiYWN0aW9uIiA6ICJwYXltZW50Igp9"
        }
    }
    
    var platformUserName: String {
        switch self {
        case .cashapp:
            return "$BeamPayments"
        case .venmo:
            return "@BeamPayments"
        case .zelle:
            return "j2keinvestments@gmail.com"
        case .paypal:
            return "@BeamPayments"
        }
    }
}

struct Platform: Codable {
    @DocumentID var id: String?
    
    var username: String
    var userLink: String
    var selectedPlatform: AvailablePlatforms
    var dateConnected: Date
}
