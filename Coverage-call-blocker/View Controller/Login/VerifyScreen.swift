//
//  VerifyScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import UIKit
import SVPinView

class VerifyScreen: UIViewController {
    
    @IBOutlet weak var messageTextField: UILabel!
    @IBOutlet weak var pinView: SVPinView!
    
    var emailString: String = ""
    var passwordString: String = ""
    var mobileNunberString: String = ""
    var pinString: String = ""
    
    var CountryCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print("countryCode : ", countryCode)
            if countryCode == "IN"
            {
                CountryCode = "+91"
            }
            else{
                CountryCode = "+1"
            }
        }
        
        setupinitialView()
    }
    
    func setupinitialView(){
        
        self.view.backgroundColor = appBackgroundColor
        
        let lastFourDigit = mobileNunberString.suffix(4)
        
        messageTextField.text = "We have sent you a 4 digit code to the mobile number ending in \(lastFourDigit). Enter the digits in below to continue."
        
        pinView.didFinishCallback = { pin in
            print("pin : \(pin)")
            self.pinString = "\(pin)"
        }
        
//        SendOTPAPI()
    }
    
    //MARK:- Check Validation
    func checkValidation() -> String?{
        if pinString == ""{
            return "Please enter OTP"
        }
        return nil
    }
    
    //MARK: - button clicked event
    @IBAction func onResend(_ sender: UIButton) {
        self.view.endEditing(true)
        SendOTPAPI()
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if let error = self.checkValidation(){
            Utility.showAlert(vc: self, message: error)
        }else{
            VerifyOTPAPI()
        }
    }
    
}

//MARK:- API
extension VerifyScreen{
    
    //MARK: - Send OTP API
    func SendOTPAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = SendOTPRequest(phone_number: "\(CountryCode) \(mobileNunberString)")
        LoginServices.shared.SendOTP(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            self?.view.makeToast(response.message ?? "")
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    //MARK: - VerifyOTP API
    func VerifyOTPAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = verifyotpRequest(code: "\(pinString)")
        LoginServices.shared.VerifyOTP(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            self?.goFurtherVerifyOTP()
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    func goFurtherVerifyOTP(){
        SignupAPI()
    }
    
    //MARK: - Signup API
    func SignupAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = SignupRequest(email: emailString, password: passwordString, password_confirmation: passwordString, phone: mobileNunberString)
        LoginServices.shared.Signup(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            if let res = response.loginResponse{
                Utility.saveUserData(data: res.toJSON())
                self?.goFurtherSignupAPI()
            }
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    func goFurtherSignupAPI(){
        self.view.makeToast("This module is under development")
    }
}
