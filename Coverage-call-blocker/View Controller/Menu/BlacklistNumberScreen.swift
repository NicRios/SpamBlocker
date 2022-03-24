//
//  BlacklistNumberScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 20/10/21.
//

import UIKit
import CallKit
import CoreData
import CallerData
import FTPopOverMenu_Swift

class BlacklistNumberScreen: UIViewController {
    
    var caller: Caller? {
        didSet {
            //            self.updateUI()
        }
    }
    
    var menuStyle: MenuStyle = .normal
    var menuOptionNameArray = ["Add from contacts", "Add manually"]
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var blockNumberTableView: UITableView!
    
    lazy private var callerData = CallerData()
    
    fileprivate var blackListNumberArray: [Caller] = []
    fileprivate var blackListNumberArrayMain: [Caller] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInititalData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        retrieveDataFirstTime()
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: reloadExtetionString, completionHandler: { (error) in
            
            if (error == nil) {
                print("======== UnBlock successfully.=========")
            }else{
                print("Error reloading extension: \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    private func setUpInititalData(){
        blockNumberTableView.delegate = self
        blockNumberTableView.dataSource = self
        blockNumberTableView.tableFooterView = UIView()
        //        blockNumberTableView.separatorStyle = .none
        
        searchTextField.setLeftPaddingPoints(16)
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(txtSearchTextChange(_:)), for: .editingChanged)
        
    }
    
    func retrieveDataFirstTime() {
        
        let manageContext = self.callerData.context
        
        let fetchRequest = NSFetchRequest<Caller>(entityName: "Caller")
        
        let fetchRequestIsBlocked = NSPredicate(format:"isBlocked == %@",NSNumber(value:true))
        let fetchRequestIsFromContact = NSPredicate(format:"isFromContacts == %@",NSNumber(value:true))
        let fetchRequestIsRemoved = NSPredicate(format:"isRemoved == %@",NSNumber(value:false))
        let predicate: NSPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fetchRequestIsBlocked,fetchRequestIsFromContact,fetchRequestIsRemoved])
        fetchRequest.predicate = predicate
        
        do {
            blackListNumberArray.removeAll()
            blackListNumberArrayMain.removeAll()
            blackListNumberArray = try manageContext.fetch(fetchRequest)
            blackListNumberArrayMain = blackListNumberArray
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
        blockNumberTableView.reloadData()
    }
    
    func unblocknumber(data: Caller){
        
        let manageContext = self.callerData.context
        do {
            data.isRemoved = true
            //            caller.isBlocked = false
            data.updatedDate = Date()
            try manageContext.save()
        }catch let error{
            print("Could not update local video id \(error)")
        }
        
        self.reload()
        
        retrieveDataFirstTime()
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
                vc.isWhiteListNumber = false
                self.navigationController?.pushViewController(vc, animated: true)
            }else if selectedIndex == 1{
                let vc =  STORYBOARD.menu.instantiateViewController(withIdentifier: "AddNumberScreen") as! AddNumberScreen
                vc.isWhiteListNumber = false
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                
            }
            
        }) {
            
        }
    }
    
    //MARK: - search
    @IBAction func txtSearchTextChange(_ sender: Any) {
        
        if (searchTextField.text?.count == 0) {
            blackListNumberArray = blackListNumberArrayMain
        }
        else
        {
            let searchResult: String = searchTextField.text ?? ""
            blackListNumberArray = blackListNumberArrayMain.filter({ (obj) in
                return (obj.name?.lowercased().contains(searchResult.lowercased()))!
            })
        }
        blockNumberTableView.reloadData()
    }
}

extension BlacklistNumberScreen: UITextFieldDelegate{
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension BlacklistNumberScreen: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numOfSections: Int = 0
        
        if blackListNumberArray.count > 0 {
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No blacklist number found"
            noDataLabel.textColor = UIColor.darkGray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 1
            tableView.backgroundView = noDataLabel
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blackListNumberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as? ContactTableViewCell ?? Bundle.main.loadNibNamed("ContactTableViewCell", owner: self, options: nil)![0] as! ContactTableViewCell
        cell.selectionStyle = .none
        
        cell.nameLabel.text = blackListNumberArray[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "", message: "Would you like to unblock this number?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            self.unblocknumber(data: self.blackListNumberArray[indexPath.row])
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}


