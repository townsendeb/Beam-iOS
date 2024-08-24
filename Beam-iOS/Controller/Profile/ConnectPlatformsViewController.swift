//
//  ConnectPlatformsViewController.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit
import SVProgressHUD

// Allow the user to connect any previously unconnected platform here, or disconnect/change/modify existing platforms.

class ConnectPlatformsViewController: UIViewController {

    @IBOutlet private var platformsCollectionView: PlatformsCollectionView!
    @IBOutlet private var continueButtonHeight: NSLayoutConstraint!
    
    private var availablePlatforms: [AvailablePlatforms] = AvailablePlatforms.allCases
    var fromOnboarding: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !fromOnboarding {
            self.continueButtonHeight.constant = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        platformsCollectionView.platformDelegate = self
        platformsCollectionView.showConnectedPlatforms = true
        
        if let platforms = BeamNetworking.shared.sharedUser?.connectedPlatforms {
            let connectedPlatforms = platforms.compactMap({ $0.selectedPlatform })
            platformsCollectionView.connectedPlatforms = connectedPlatforms
            let available = availablePlatforms.filter({ !connectedPlatforms.contains($0) })
            platformsCollectionView.platforms = available
        } else {
            platformsCollectionView.platforms = availablePlatforms
        }
        
        platformsCollectionView.collectionView.reloadData()
    }

    @IBAction private func backButton(sender: UIButton) {
        if fromOnboarding {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction private func completeOnboarding(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension ConnectPlatformsViewController: PlatformSheetDelegate {
    func didConnectPlatform(platform: Platform) {
        guard var user = BeamNetworking.shared.sharedUser else { return }
        user.connectedPlatforms.append(platform)
        
        BeamNetworking.shared.updateUser(user: user) { completed in
            if completed {
                self.platformsCollectionView.connectedPlatforms = user.connectedPlatforms.compactMap({ $0.selectedPlatform })
                self.platformsCollectionView.platforms = self.availablePlatforms.filter({ !self.platformsCollectionView.connectedPlatforms.contains($0) })
                self.platformsCollectionView.collectionView.reloadData()
            }
        }
    }
}

extension ConnectPlatformsViewController: PlatformsCollectionViewDelegate {
    func didSelect(platform: AvailablePlatforms) {
        if availablePlatforms.contains(platform) {
            // Connect the user to the platform via metadata or API connection
            let platformSheet = self.storyboard?.instantiateViewController(withIdentifier: "PlatformSheetViewController") as! PlatformSheetViewController
//            platformSheet.modalPresentationStyle = .popover
//            platformSheet.preferredContentSize = CGSize(width: UIWindow().screen.bounds.width, height: 200)
            platformSheet.delegate = self
            platformSheet.selectedPlatform = platform
            self.present(platformSheet, animated: true)
        } else {
            // Ask the user if they want the platform disconnected from their account
            let alert = UIAlertController(title: "Disconnect Platform", message: "Are you sure you want to disconnect from \(platform.rawValue)? You can always re-connect byt tapping on the platform's tile later on.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { _ in
                guard var user = BeamNetworking.shared.sharedUser else { return }
                
                // Perform disconnect here and then reload the connected
                user.connectedPlatforms.removeAll(where: { $0.selectedPlatform == platform })
                
                // Save user here and update connected platforms
                BeamNetworking.shared.updateUser(user: user) { completed in
                    if completed {
                        let connectedPlatforms = user.connectedPlatforms.compactMap({ $0.selectedPlatform })
                        self.platformsCollectionView.connectedPlatforms = connectedPlatforms
                        let available = self.availablePlatforms.filter({ connectedPlatforms.contains($0) })
                        self.platformsCollectionView.platforms = available
                        self.platformsCollectionView.collectionView.reloadData()
                    } else {
                        // Show Failure
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
    }
}
