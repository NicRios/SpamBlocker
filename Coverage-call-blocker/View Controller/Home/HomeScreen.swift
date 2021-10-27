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
        max_blockingAPI()
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

//MARK: - API
extension HomeScreen{
    
    //MARK:- max_blocking API
    func max_blockingAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        ServeyServices.shared.max_blocking(success: {  (statusCode, response) in
            
            if let res = response?.maxBlockingResponse{
                self.blockNumberArray = res
//                self.mainTableView.reloadData()
//                self.mainTableView.isHidden = false
            }
            
            Utility.hideIndicator()
            
        }, failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        })
    }
}

