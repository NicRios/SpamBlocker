//
//  WhitelistNumberScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 20/10/21.
//

import UIKit
import Contacts
import FTPopOverMenu_Swift

enum MenuStyle {
    case normal
    case qq
    case wechat
    case more
}

class WhitelistNumberScreen: UIViewController {
    
    var menuStyle: MenuStyle = .normal
    var menuOptionNameArray = ["Add from contacts", "Add manually"]
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var contactTableView: UITableView!
    
    fileprivate var whiteListNumberArray: [ContactResponse] = []
    fileprivate var whiteListNumberArrayMain: [ContactResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInititalData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        whiteListNumberArray.removeAll()
        whiteListNumberArrayMain.removeAll()
        
        if let tempDic = UserDefaults.standard.value(forKey: KEYWhiteListArray) as? [[String:Any]]  {
            
            for i in tempDic {
                if let obj = ContactResponse(JSON:i) {
                    self.whiteListNumberArray.append(obj)
                    self.whiteListNumberArrayMain.append(obj)
                }
            }
            
            print("Whitelist array from user defaults : ",self.whiteListNumberArray.toJSON())
        }
        
        contactTableView.reloadData()
    }
    
    private func setUpInititalData(){
        contactTableView.delegate = self
        contactTableView.dataSource = self
        contactTableView.backgroundColor = UIColor.clear
        contactTableView.tableFooterView = UIView()
        
        searchTextField.setLeftPaddingPoints(16)
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(txtSearchTextChange(_:)), for: .editingChanged)
        
    }
    
    //MARK: - Button clicked event
    @IBAction func onAdd(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        let config = FTConfiguration.shared
        config.menuWidth = 150
        
        FTPopOverMenu.showForSender(sender: sender,
                                    with: menuOptionNameArray,
                                    done: { (selectedIndex) -> () in
            
            print("selectedIndex : ", selectedIndex)
            
            if selectedIndex == 0{
                let vc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "ContactsScreen") as! ContactsScreen
                vc.isWhiteListNumber = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else if selectedIndex == 1{
                let vc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "AddNumberScreen") as! AddNumberScreen
                vc.isWhiteListNumber = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                
            }
            
        }) {
            
        }
        
    }
    
    //MARK: - search
    @IBAction func txtSearchTextChange(_ sender: Any) {
        
        if (searchTextField.text?.count == 0) {
            whiteListNumberArray = whiteListNumberArrayMain
        }
        else
        {
            let searchResult: String = searchTextField.text ?? ""
            whiteListNumberArray = whiteListNumberArrayMain.filter({ (obj) in
                return (obj.name?.lowercased().contains(searchResult.lowercased()))!
            })
        }
        contactTableView.reloadData()
        
    }
}

extension WhitelistNumberScreen: UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension WhitelistNumberScreen: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numOfSections: Int = 0
        
        if whiteListNumberArray.count > 0 {
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No whitelist number found"
            noDataLabel.textColor = UIColor.darkGray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 1
            tableView.backgroundView = noDataLabel
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return whiteListNumberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as? ContactTableViewCell ?? Bundle.main.loadNibNamed("ContactTableViewCell", owner: self, options: nil)![0] as! ContactTableViewCell
        cell.selectionStyle = .none
        
        cell.nameLabel.text = whiteListNumberArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: APPLICATION_NAME, message: "Would you like to remove this number?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            
            let phoneNumber = self.whiteListNumberArray[indexPath.row].number
            
            for i in 0..<self.whiteListNumberArray.count {
                let data = self.whiteListNumberArray[i]
                if data.number == Int64(phoneNumber ?? 0){
                    self.whiteListNumberArray.remove(at: i)
                    
                    UserDefaults.standard.set(self.whiteListNumberArray.toJSON(), forKey: KEYWhiteListArray)
                    UserDefaults.standard.synchronize()
                    
                    self.searchTextField.text = ""
                    
                    self.view.makeToast("Number remove successfully.")
                    
                    self.whiteListNumberArrayMain = self.whiteListNumberArray
                    
                    break
                }
            }
            tableView.reloadData()
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
