//
//  MenuScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 05/10/21.
//

import UIKit

class MenuScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpInitialView()
    }
    
    func setUpInitialView(){
        self.view.layer.cornerRadius = 24
        self.view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
    }
    
    //MARK: - button clicked event
    
    @IBAction func onWhitelistNumber(_ sender: Any) {
        
        self.view.makeToast("This module is under development")
    }
    
    @IBAction func onBlacklistNumber(_ sender: Any) {
        
        self.view.makeToast("This module is under development")
    }
    
    @IBAction func onSetting(_ sender: Any) {
        
        self.view.makeToast("This module is under development")
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        self.sideMenuController?.hideLeftView()
        
        let alert = UIAlertController(title: APPLICATION_NAME, message: "Are you sure want to logout?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            Utility.removeUserData()
            self.App_Delegate.setupViewController()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}