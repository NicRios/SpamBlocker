//
//  Question1Screen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 08/10/21.
//

import UIKit
import TCProgressBar

class Question1Screen: UIViewController {
    
    @IBOutlet weak var multipleTimeImageView: UIImageView!
    @IBOutlet weak var EveryFewDaysImageView: UIImageView!
    @IBOutlet weak var ByWeekImageView: UIImageView!
    @IBOutlet weak var progressBarView: TCProgressBar!
    @IBOutlet weak var progressLabel: UILabel!
    
    var selectedAnswer1String: String = ""
    var isFromMenuScreen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupinitialView()
    }
    
    func setupinitialView(){
        self.view.addGradientWithColor()
        
        multipleTimeImageView.isHidden = true
        EveryFewDaysImageView.isHidden = true
        ByWeekImageView.isHidden = true
        
        progressBarView.value = 0
        progressLabel.text = "0% completed"
        
        selectedAnswer1String = "1"
        multipleTimeImageView.isHidden = false
        EveryFewDaysImageView.isHidden = true
        ByWeekImageView.isHidden = true
        
        if let surveyArray = UserDefaults.standard.value(forKey: SURVEYARRAY) as? [[String : Any]] {
            print("surveyArray : ", surveyArray)
            
            if surveyArray.count >= 1{
                selectedAnswer1String = surveyArray[0]["answer"] as? String ?? ""
            }
            
            if selectedAnswer1String == "1"
            {
                self.multipleTimeImageView.isHidden = false
                self.EveryFewDaysImageView.isHidden = true
                self.ByWeekImageView.isHidden = true
            }
            else if selectedAnswer1String == "2"
            {
                self.multipleTimeImageView.isHidden = true
                self.EveryFewDaysImageView.isHidden = false
                self.ByWeekImageView.isHidden = true
            }
            else if selectedAnswer1String == "3"
            {
                self.multipleTimeImageView.isHidden = true
                self.EveryFewDaysImageView.isHidden = true
                self.ByWeekImageView.isHidden = false
            }
        }
    }
    
    //MARK: - button clicked event
    @IBAction func onMultipleTime(_ sender: Any) {
        selectedAnswer1String = "1"
        multipleTimeImageView.isHidden = false
        EveryFewDaysImageView.isHidden = true
        ByWeekImageView.isHidden = true
    }
    
    @IBAction func onEveryFewDays(_ sender: Any) {
        selectedAnswer1String = "2"
        multipleTimeImageView.isHidden = true
        EveryFewDaysImageView.isHidden = false
        ByWeekImageView.isHidden = true
    }
    
    @IBAction func onByWeek(_ sender: Any) {
        selectedAnswer1String = "3"
        multipleTimeImageView.isHidden = true
        EveryFewDaysImageView.isHidden = true
        ByWeekImageView.isHidden = false
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        if selectedAnswer1String == ""{
            self.view.makeToast("Please selecte any one")
        }
        else{
            
            progressBarView.value = 0.3
            progressLabel.text = "33% completed"
            
            let vc =  STORYBOARD.Survey.instantiateViewController(withIdentifier: "Question2Screen") as! Question2Screen
            vc.selectedAnswer1String = selectedAnswer1String
            vc.isFromMenuScreen = isFromMenuScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
