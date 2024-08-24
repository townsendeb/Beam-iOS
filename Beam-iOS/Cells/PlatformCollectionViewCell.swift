//
//  PlatformCollectionViewCell.swift
//  OneP2P
//
//  Created by Eric Townsend on 5/30/22.
//

import UIKit

class PlatformCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var platformImage: UIImageView!
    @IBOutlet private var platformName: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCellFor(platform: AvailablePlatforms) {
        self.platformName.text = platform.rawValue
        self.platformImage.image = platform.imageForPlatform
    }
}
