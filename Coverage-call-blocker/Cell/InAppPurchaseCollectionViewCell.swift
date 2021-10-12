//
//  InAppPurchaseCollectionViewCell.swift
//  Coverage-call-blocker
//
//  Created by iroid on 09/10/21.
//

import UIKit

class InAppPurchaseCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backGroundView.addGradientWithColor()
    }

}
