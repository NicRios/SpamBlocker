//
//  AddNumberScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid-Miraj on 08/11/21.
//

import UIKit
import CallKit
import CoreData
import CallerData

class AddNumberScreen: UIViewController {
    
    var caller: Caller? {
        didSet {
            //            self.updateUI()
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var addNumberButton: UIButton!
    
    var isWhiteListNumber: Bool = false
    
    fileprivate var whiteListNumberArray: [ContactResponse] = []
    
    lazy private var callerData = CallerData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInitialView()
    }
    
    func setUpInitialView(){
        numberTextField.delegate = self
        nameTextField.setLeftPaddingPoints(16)
        
        numberTextField.delegate = self
        numberTextField.setLeftPaddingPoints(16)
        
        addNumberButton.setTitle(isWhiteListNumber ? "Add to whitelist" : "Add to blacklist", for: .normal)
        
        if isWhiteListNumber{
            whiteListNumberArray.removeAll()
            if let tempDic = UserDefaults.standard.value(forKey: KEYWhiteListArray) as? [[String:Any]]  {
                
                for i in tempDic {
                    if let obj = ContactResponse(JSON:i) {
                        self.whiteListNumberArray.append(obj)
                    }
                }
                
                print("Whitelist array from user defaults : ",self.whiteListNumberArray.toJSON())
            }
            
        }else{
            
        }
    }
    
    //MARK: - button clicked event
    @IBAction func onAddNumber(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if let error = self.checkValidation(){
            Utility.showAlert(vc: self, message: error)
        }else{
            if isWhiteListNumber{
                
                let intNumber = numberTextField.text ?? ""
                let string = intNumber.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
                
                let obj = ContactResponse(name: self.nameTextField.text, number: Int64(string) ?? 0, isWhiteList: false, isBlackList: false)
                self.whiteListNumberArray.append(obj)
                
                print("Whitelist array for user defaults : ",self.whiteListNumberArray.toJSON())
                
                UserDefaults.standard.set(self.whiteListNumberArray.toJSON(), forKey: KEYWhiteListArray)
                UserDefaults.standard.synchronize()
                
                self.navigationController?.popViewController(animated: true)
                
            }else{
                
                let intNumber = numberTextField.text ?? ""
                let string = intNumber.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
                
                self.blockNumber(nameString: nameTextField.text ?? "" , number: Int64(string) ?? 0)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: - Check Validation
    func checkValidation() -> String?{
        if nameTextField.text?.count == 0 {
            return "Please enter name"
        }else if numberTextField.text?.count == 0{
            return "Please enter phone number"
        }else if numberTextField.text?.count != 14{
            return "Please enter Valid phone number"
        }
        return nil
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
        
        if textField == nameTextField{
            return true
        }
        else{
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = format(with: "(XXX) XXX-XXXX", phone: newString)
            return false
        }
    }
    
    func blockNumber(nameString : String , number: Int64){
        
        print("nameString : ", nameString)
        print("number : ", number)
        
        let num = Int64("\(CountryCode)"+"\(number)")
        print("num : ", num ?? 0)
        
        let caller = self.caller ?? Caller(context: self.callerData.context)
        caller.name = nameString
        caller.number  = num ?? 0
        caller.isFromContacts = true
        caller.isBlocked = true
        caller.isRemoved = false
        caller.updatedDate = Date()
        self.callerData.saveContext()
        
        reload()
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.mobile.app.Coverage-call-blocker.Coverage-call-blockerExtension", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
    }
}

extension AddNumberScreen: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
            numberTextField.becomeFirstResponder()
        }else if textField == numberTextField{
            numberTextField.resignFirstResponder()
        }
        return true
    }
}
