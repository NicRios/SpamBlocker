//
//  SurveyScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 04/10/21.
//

import UIKit

class SurveyScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = appBackgroundColor
    }
    
    
    //MARK: - button clicked event
    @IBAction func onNext(_ sender: UIButton) {
        let vc =  STORYBOARD.Survey.instantiateViewController(withIdentifier: "Question1Screen") as! Question1Screen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onSkip(_ sender: UIButton) {
        self.App_Delegate.setupViewController()
    }
    
}
