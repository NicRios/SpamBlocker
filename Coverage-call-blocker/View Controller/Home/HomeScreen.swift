//
//  HomeScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 07/10/21.
//

import UIKit

class HomeScreen: UIViewController {
    
    var blockNumberArray: [MaxBlockingResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInitialView()
        
        self.view.makeToast("This module is under development")
    }
    
    func setUpInitialView(){
        
    }
    
    //MARK: - button clicked event
    
    @IBAction func onMenu(_ sender: Any)
    {
        self.view.endEditing(true)
        
        if(self.sideMenuController?.isLeftViewVisible)!
        {
            self.sideMenuController?.hideLeftView()
        }
        else
        {
            self.sideMenuController?.showLeftView()
        }
    }
    
}



