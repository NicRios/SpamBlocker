//
//  MobileScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import UIKit
import SVPinView

class MobileScreen: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var termsAndConditionLabel: UILabel!
    
    var emailString: String = ""
    var passwordString: String = ""
    var mobileNunberString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupinitialView()
    }
    
    func setupinitialView(){
        
        self.view.backgroundColor = appBackgroundColor
        
        mobileNumberTextField.delegate = self
        mobileNumberTextField.setLeftPaddingPoints(16)
        
        pinView.shouldSecureText = false
        pinView.didFinishCallback = { pin in
            print("phone number : \(pin)")
            self.mobileNunberString = "\(pin)"
        }
        
        let myAttributeLight = [ NSAttributedString.Key.font: UIFont(name: "Roboto-Light", size: 14.0)! ]
        let myStringLight = NSMutableAttributedString(string: "By registering you accept the policys under ", attributes: myAttributeLight )
        
        let myAttributeBold = [ NSAttributedString.Key.font: UIFont(name: "Roboto-Bold", size: 14.0)! ]
        let myStringBold = NSMutableAttributedString(string: "Terms and Conditions", attributes: myAttributeBold )
        
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(myStringLight)
        attributedString.append(myStringBold)
        
        termsAndConditionLabel.attributedText = attributedString
        
    }
    
    //MARK:- Check Validation
    func checkValidation() -> String?{
        if mobileNunberString.count == 0{
            return "Please enter phone number"
        }else if mobileNunberString.count != 13{
            return "Please enter Valid phone number"
        }
        return nil
    }
    
    //MARK: - button clicked event
    @IBAction func onRegister(_ sender: UIButton) {
        self.view.endEditing(true)
        
        mobileNunberString = mobileNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        mobileNunberString = mobileNunberString.removeWhitespace()
        
        if let error = self.checkValidation(){
            Utility.showAlert(vc: self, message: error)
        }else{
            self.SendOTPAPI()
        }
    }
    
    /// mask example: `+X (XXX) XXX-XXXX`
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator
        
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                
                // move numbers iterator to the next index
                index = numbers.index(after: index)
                
            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = format(with: "(XXX) XXX-XXXX", phone: newString)
        return false
    }
    
}

extension MobileScreen{
    
    //MARK: - Send OTP API
    func SendOTPAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = SendOTPRequest(phone_number: "\(CountryCode) \(mobileNunberString)")
        LoginServices.shared.SendOTP(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            self?.goFurtherSendOTP()
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    func goFurtherSendOTP(){
        let vc =  STORYBOARD.login.instantiateViewController(withIdentifier: "VerifyScreen") as! VerifyScreen
        vc.emailString = emailString
        vc.passwordString = passwordString
        vc.mobileNunberString = mobileNunberString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
