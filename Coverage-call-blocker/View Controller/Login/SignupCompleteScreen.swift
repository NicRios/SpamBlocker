//
//  SignupCompleteScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 04/10/21.
//

import UIKit

class SignupCompleteScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupinitialView()
    }
    
    func setupinitialView(){
        self.view.addGradientWithColor()
    }
    
    
    //MARK: - button clicked event
    @IBAction func onBeginApp(_ sender: UIButton) {
        self.App_Delegate.setupViewController()
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        Utility.removeUserData()
        let vc =  STORYBOARD.login.instantiateViewController(withIdentifier: "LoginScreen") as! LoginScreen
        vc.isLogin = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
