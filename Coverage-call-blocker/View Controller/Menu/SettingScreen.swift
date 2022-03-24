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
        
        emailLabel.text = Utility.getUserData()?.email
        numberLabel.text = Utility.getUserData()?.phone
        
        planLabel.text = Utility.getUserData()?.isPremium == 1 ? "Monthly" : "No plan available"
    }
    
}
