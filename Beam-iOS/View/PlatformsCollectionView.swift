//
//  PlatformsCollectionView.swift
//  OneP2P
//
//  Created by Eric Townsend on 6/2/22.
//

import UIKit

protocol PlatformsCollectionViewDelegate: AnyObject {
    func didSelect(platform: AvailablePlatforms)
}

class PlatformsCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Public variables
    var platformDelegate: PlatformsCollectionViewDelegate?
    var platforms: [AvailablePlatforms] = []
    var connectedPlatforms: [AvailablePlatforms] = []
    var showSelected: Bool = false
    var showConnectedPlatforms: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlatformCollectionViewCell", for: indexPath) as! PlatformCollectionViewCell
        let platform = indexPath.section == 0 ? platforms[indexPath.item] : connectedPlatforms[indexPath.item]
        cell.configureCellFor(platform: platform)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return showConnectedPlatforms ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? self.platforms.count : self.connectedPlatforms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: collectionView.frame.width/2 + 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.platformDelegate?.didSelect(platform: platforms[indexPath.item])
        } else {
            self.platformDelegate?.didSelect(platform: connectedPlatforms[indexPath.item])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PlatformHeaderView", for: indexPath) as? PlatformHeaderView else { return UICollectionReusableView() }
        switch indexPath.section {
        case 0:
            headerView.headerLabel.text = platforms.count > 0 ? "Available Platforms" : ""
        default:
            headerView.headerLabel.text = connectedPlatforms.count > 0 ? "Connected Platforms" : ""
        }
        return headerView
    }
}
