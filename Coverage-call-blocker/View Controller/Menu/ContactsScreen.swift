//
//  ContactsScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid-Miraj on 27/10/21.
//

import UIKit
import Contacts
import CallKit
import CoreData
import CallerData

class ContactsScreen: UIViewController {
    
    var caller: Caller? {
        didSet {
            //            self.updateUI()
        }
    }
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var contactTableView: UITableView!
    
    lazy private var callerData = CallerData()
    private var resultsController: NSFetchedResultsController<Caller>!
    
    fileprivate var whiteListNumberArray: [ContactResponse] = []
    fileprivate var blackListNumberArray: [ContactResponse] = []
    var contactArray: [ContactResponse] = []
    var contactArrayMain: [ContactResponse] = []
    
    var isWhiteListNumber: Bool = false
    
    var blockNumberArray = [Int64]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInititalData()
        
        retrieveDataFirstTime()
    }
    
    private func setUpInititalData(){
        contactTableView.delegate = self
        contactTableView.dataSource = self
        contactTableView.backgroundColor = UIColor.clear
        contactTableView.tableFooterView = UIView()
        
        searchTextField.setLeftPaddingPoints(16)
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(txtSearchTextChange(_:)), for: .editingChanged)
        
        if let tempWhiteDic = UserDefaults.standard.value(forKey: KEYWhiteListArray) as? [[String:Any]]  {
            
            for i in tempWhiteDic {
                if let obj = ContactResponse(JSON:i) {
                    self.whiteListNumberArray.append(obj)
                }
            }
        }
        
        if let tempBlackDic = UserDefaults.standard.value(forKey: KEYBlackListArray) as? [[String:Any]]  {
            
            for i in tempBlackDic {
                if let obj = ContactResponse(JSON:i) {
                    self.blackListNumberArray.append(obj)
                }
            }
        }
    }
    
    func retrieveDataFirstTime() {
        
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: true)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.resultsController.performFetch()
            
            let results = self.resultsController.fetchedObjects
            
            for i in 0..<results!.count {
                let indexPath = IndexPath(item: i, section: 0)
                let caller = self.resultsController.object(at: indexPath)
                let phonenumber = "\(caller.number)"
                let phonenumberInt = Int64(phonenumber.suffix(10)) ?? 0
                blockNumberArray.append(phonenumberInt)
            }
            
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
        getContact()
    }
    
    private func getContact()
    {
        self.contactArray.removeAll()
        self.contactArrayMain.removeAll()
        
        var contacts = [CNContact]()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                return
            }
            if granted {
                
                let contactStore = CNContactStore()
                
                //        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [CNKeyDescriptor]
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey] as [Any]
                let request = CNContactFetchRequest( keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                request.mutableObjects = false
                request.unifyResults = true
                request.sortOrder = .givenName
                
                do {
                    try contactStore.enumerateContacts(with: request) {
                        (contact, stop) in
                        
                        if contact.phoneNumbers.count > 0{
                            let phonenumber = (contact.phoneNumbers[0].value).value(forKey: "digits") as? String ?? ""
                            let phonenumberInt = Int(phonenumber.suffix(10))
                            let phonenumberWhitelistInt = Int64(phonenumber)
                            
                            if self.blockNumberArray.contains(Int64(phonenumberInt ?? 0)){
                                
                            }
                            //                            else if self.whiteListNumberArray.contains(Int64(phonenumberWhitelistInt ?? 0)){
                            else if self.whiteListNumberArray.contains(where: { $0.number == Int64(phonenumberWhitelistInt ?? 0)})
                            {
                                
                            }
                            else{
                                contacts.append(contact)
                                //                                self.contactsAll.append(contact)
                            }
                        }
                    }
                }
                catch {
                    print("unable to fetch contacts")
                }
                
                if contacts.count > 0{
                    for contact in contacts {
                        
                        if contact.phoneNumbers.count > 0
                        {
                            let a = "\((contact.phoneNumbers[0].value ).value(forKey: "digits") as? String ?? "")"
                            //                            let number = Int64(String(a.suffix(10)))
                            let number = Int64(a)
                            //self.contactArray.append(ContactResponse(name: "\(contact.givenName) \(contact.familyName)", number: number, isWhiteList: false, isBlackList: false))
                            self.contactArrayMain.append(ContactResponse(name: "\(contact.givenName) \(contact.familyName)", number: number, isWhiteList: false, isBlackList: false))
                            
                            self.contactArray = self.contactArrayMain
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.contactTableView.reloadData()
                    }
                }
            } else {
                print("access denied")
            }
        }
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.mobile.app.Coverage-call-blocker.Coverage-call-blockerExtension", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
    }
    
    func blockNumber(nameString : String , number: Int64){
        
        print("nameString : ", nameString)
        //        print("number : ", number)
        
        let num = Int64("\(CountryCode)"+"\(number)")
        print("num : ", num ?? 0)
        
        let caller = self.caller ?? Caller(context: self.callerData.context)
        caller.name = nameString
        caller.number  = num ?? 0
        caller.isBlocked = true
        caller.isRemoved = false
        caller.updatedDate = Date()
        self.callerData.saveContext()
        
    }
    
    //MARK: - Button clicked event
    @IBAction func onDone(_ sender: UIButton) {
        
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
        
        if isWhiteListNumber{
            
            let alert = UIAlertController(title: APPLICATION_NAME, message: "Would you like to whitelist this number?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
                
                let array = self.contactArrayMain.filter({$0.isBlackList == true})
                
                for i in 0..<array.count {
                    let contact = array[i]
                    let a = "\(contact.number ?? 0)"
                    let number = Int64(String(a.suffix(10)))
                    //                    self.createWhiteListData(nameString: contact.name ?? "" , number: contact.number ?? 0)
                    //                    self.whiteListNumberArray.append(contact.number ?? 0)
                    
                    self.whiteListNumberArray.append(ContactResponse(name: contact.name, number: number, isWhiteList: false, isBlackList: false))
                }
                
                UserDefaults.standard.set(self.whiteListNumberArray.toJSON(), forKey: KEYWhiteListArray)
                UserDefaults.standard.synchronize()
                
                self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: APPLICATION_NAME, message: "Would you like to block this number?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
                
                let array = self.contactArrayMain.filter({$0.isBlackList == true})
                print("array : ", array.count)
                
                for i in 0..<array.count {
                    let contact = array[i]
                    let a = "\(contact.number ?? 0)"
                    let number = Int64(String(a.suffix(10)))
                    self.blockNumber(nameString: contact.name ?? "" , number: number ?? 0)
                    
                    self.blackListNumberArray.append(ContactResponse(name: contact.name, number: number, isWhiteList: false, isBlackList: false))
                }
                
                self.reload()
                
                UserDefaults.standard.set(self.blackListNumberArray.toJSON(), forKey: KEYBlackListArray)
                UserDefaults.standard.synchronize()
                
                self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - search
    @IBAction func txtSearchTextChange(_ sender: Any) {
        
        let searchResult: String = searchTextField.text ?? ""
        self.contactArray = searchResult.isEmpty ? contactArrayMain : contactArrayMain.filter { (item: ContactResponse) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return (item.name?.lowercased().contains(searchResult.lowercased()))!
        }
        
        self.contactTableView.reloadData()
    }
    
}

extension ContactsScreen: UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension ContactsScreen: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numOfSections: Int = 0
        
        if contactArray.count > 0 {
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No number found"
            noDataLabel.textColor = UIColor.darkGray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 1
            tableView.backgroundView = noDataLabel
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as? ContactTableViewCell ?? Bundle.main.loadNibNamed("ContactTableViewCell", owner: self, options: nil)![0] as! ContactTableViewCell
        cell.selectionStyle = .none
        
        cell.nameLabel?.text = "\(contactArray[indexPath.row].name ?? "")"
        
        
        cell.selectedButton.isSelected = self.contactArray[indexPath.row].isBlackList ?? false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let index = contactArrayMain.firstIndex(where: { $0.number == self.contactArray[indexPath.row].number }) {
            self.contactArrayMain[index].isBlackList = !(self.contactArrayMain[index].isBlackList ?? false)
            //self.contactArray[indexPath.row].isBlackList = !(self.contactArray[indexPath.row].isBlackList ?? false)
            
            contactTableView.reloadRows(at: [indexPath], with: .none)
            
            let array = contactArrayMain.filter({$0.isBlackList == true})
            doneButton.isHidden = array.count > 0 ? false : true
        }
        
    }
}

