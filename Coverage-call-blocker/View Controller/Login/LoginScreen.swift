//
//  LoginScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import UIKit

class LoginScreen: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var labelLoginSignupScreen: UILabel!
    @IBOutlet weak var registerLoginButton: UIButton!
    @IBOutlet weak var EmailalreadyTakenMesageView: UIView!
    
    var isLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupinitialView()
    }
    
    func setupinitialView(){
        self.view.addGradientWithColor()
        
        EmailalreadyTakenMesageView.isHidden = true
        
        emailTextField.delegate = self
        emailTextField.setLeftPaddingPoints(16)
        emailTextField.text = ""
        emailTextField.textContentType = .emailAddress
        passwordTextField.delegate = self
        passwordTextField.setLeftPaddingPoints(16)
        passwordTextField.text = ""
        
        let stringAttributesWhite = [
            NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18.0) ?? UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.init(hex: "FFFFFF")] as [NSAttributedString.Key : Any]
        
        let stringAttributesYellow = [
            NSAttributedString.Key.font : UIFont(name: "Roboto-Regular", size: 18.0) ?? UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor : UIColor.init(hex: "FFD600")] as [NSAttributedString.Key : Any]
        
        if isLogin{
            labelTitle.text = "Login"
            labelLoginSignupScreen.text = "Don't have an Account? Register"
            
            registerLoginButton.setTitle("Login", for: .normal)
            
            let a = NSAttributedString(string: "Don't have an Account? ", attributes: stringAttributesWhite)
            let b = NSAttributedString(string: "Register", attributes: stringAttributesYellow)
            
            let combination = NSMutableAttributedString()
            combination.append(a)
            combination.append(b)
            labelLoginSignupScreen.attributedText = combination
            
        }else{
            labelTitle.text = "Sign Up"
            labelLoginSignupScreen.text = "returning user? Login"
            
            registerLoginButton.setTitle("Sign Up", for: .normal)
            
            let a = NSAttributedString(string: "returning user? ", attributes: stringAttributesWhite)
            let b = NSAttributedString(string: "Login", attributes: stringAttributesYellow)
            
            let combination = NSMutableAttributedString()
            combination.append(a)
            combination.append(b)
            labelLoginSignupScreen.attributedText = combination
        }
    }
    
    //MARK:- Check Validation
    func checkValidation() -> String?{
        if self.emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            return "Please enter email"
        }else if !self.emailTextField.text.isEmailValid(){
            return "Please enter a valid email address"
        }else if self.passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0{
            return "Please enter password"
        }else if self.passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 < 8{
            return "The password must be at least 8 characters"
        }
        return nil
    }
    
    //MARK: - button clicked event
    
    @IBAction func onRegisterLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if let error = self.checkValidation(){
            Utility.showAlert(vc: self, message: error)
        }else{
            if isLogin{
                LoginAPI()
            }
            else{
                CheckEmailAPI()
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        self.view.endEditing(true)
        
        isLogin = !isLogin
        setupinitialView()
    }
    
    @IBAction func onButton(_ sender: UIButton) {
        let vc =  STORYBOARD.Survey.instantiateViewController(withIdentifier: "SurveyScreen") as! SurveyScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LoginScreen: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}

//MARK: - API
extension LoginScreen{
    
    //MARK: - Check Email API
    func CheckEmailAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = CheckEmailRequest(email: emailTextField.text ?? "")
        LoginServices.shared.checkEmail(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            
            self?.goFurtherCheckEmailAPI()
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            
            if error == "This email is taken by another account"{
                self?.EmailalreadyTakenMesageView.isHidden = false
            }else{
                guard let stronSelf = self else { return }
                Utility.showAlert(vc: stronSelf, message: error)
            }
        }
    }
    
    func goFurtherCheckEmailAPI(){
        let vc =  STORYBOARD.login.instantiateViewController(withIdentifier: "MobileScreen") as! MobileScreen
        vc.emailString = emailTextField.text ?? ""
        vc.passwordString = passwordTextField.text ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Login API
    func LoginAPI(){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = LoginRequest(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        LoginServices.shared.Login(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            if let res = response.loginResponse{
                Utility.saveUserData(data: res.toJSON())
                self?.goFurther()
            }
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    func goFurther(){
        self.App_Delegate.setupViewController()
    }
}
