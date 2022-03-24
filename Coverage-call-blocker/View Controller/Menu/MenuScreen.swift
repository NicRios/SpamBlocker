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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpInitialView(){
        self.view.layer.cornerRadius = 24
        self.view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
    }
    
    //MARK: - button clicked event
    
    @IBAction func onWhitelistNumber(_ sender: Any) {
        self.sideMenuController?.hideLeftView()
        
        let vc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "WhitelistNumberScreen") as! WhitelistNumberScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onBlacklistNumber(_ sender: Any) {
        
        if isBlockingNumberInProgress == true{
            self.view.makeToast("Number blocking is in progress, Please try again after finished progress.")
            return
        }
        
        self.sideMenuController?.hideLeftView()
        
        let vc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "BlacklistNumberScreen") as! BlacklistNumberScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSurvey(_ sender: Any) {
        self.sideMenuController?.hideLeftView()
        
        let vc =  STORYBOARD.Survey.instantiateViewController(withIdentifier: "Question1Screen") as! Question1Screen
        vc.isFromMenuScreen = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func onSetting(_ sender: Any) {
        self.sideMenuController?.hideLeftView()
        
        let vc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "SettingScreen") as! SettingScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        self.sideMenuController?.hideLeftView()
        
        let alert = UIAlertController(title: APPLICATION_NAME, message: "Are you sure want to logout?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            Utility.removeUserData()
            sleep(UInt32(4.0))
            self.App_Delegate.setupViewController()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
