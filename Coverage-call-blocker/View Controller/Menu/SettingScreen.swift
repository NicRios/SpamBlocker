//
//  SettingScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 20/10/21.
//

import UIKit

class SettingScreen: UIViewController {

    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var planLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupinitialView()
    }
    
    func setupinitialView(){
        self.view.addGradientWithColor()
        
//        let gradientTOP = CAGradientLayer()
//        gradientTOP.frame = self.viewTop.bounds
//        gradientTOP.colors = [UIColor.init(hex: "34A6E6").cgColor, UIColor.init(hex: "000000").cgColor]
//        self.viewTop.layer.insertSublayer(gradientTOP, at: UInt32(0.5))
//
//        let gradient = CAGradientLayer()
//        gradient.frame = self.viewTop.bounds
//        gradient.colors = [UIColor.init(hex: "36A9EA").cgColor, UIColor.init(hex: "015787").cgColor]
//        self.bottomView.layer.insertSublayer(gradient, at: UInt32(0.5))
        
        emailLabel.text = Utility.getUserData()?.email
        numberLabel.text = Utility.getUserData()?.phone
        
        planLabel.text = Utility.getUserData()?.isPremium == 1 ? "Monthly" : "No plan available"
    }
    
    
    
}
