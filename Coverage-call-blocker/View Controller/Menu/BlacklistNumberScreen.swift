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
    private var resultsController: NSFetchedResultsController<Caller>!
    
    var contactArray: [ContactResponse] = []
    var contactArrayMain: [ContactResponse] = []
    
    fileprivate var blackListNumberArray: [ContactResponse] = []
    fileprivate var blackListNumberArrayMain: [ContactResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInititalData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blackListNumberArray.removeAll()
        blackListNumberArrayMain.removeAll()
        
        if let tempDic = UserDefaults.standard.value(forKey: KEYBlackListArray) as? [[String:Any]]  {
            
            for i in tempDic {
                if let obj = ContactResponse(JSON:i) {
                    self.blackListNumberArray.append(obj)
                    self.blackListNumberArrayMain.append(obj)
                }
            }
            
            print("Blacklist array from user defaults : ",self.blackListNumberArray.toJSON())
        }
        
        blockNumberTableView.reloadData()
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.mobile.app.Coverage-call-blocker.Coverage-call-blockerExtension", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
    }
    
    private func setUpInititalData(){
        blockNumberTableView.delegate = self
        blockNumberTableView.dataSource = self
        
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
    
    func unBlockNumber(nameString : String , number: Int64){
        
        print("nameString : ", nameString)
        
        let num = Int64("\(CountryCode)"+"\(number)")
        print("num : ", num ?? 0)
        
        let caller = self.caller ?? Caller(context: self.callerData.context)
        caller.isRemoved = true
        //            caller.isBlocked = false
        caller.updatedDate = Date()
        self.callerData.saveContext()
        
        self.reload()
        
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
            
            let phoneNumber = self.blackListNumberArray[indexPath.row].number
            
            for i in 0..<self.blackListNumberArray.count {
                let data = self.blackListNumberArray[i]
                if data.number == Int64(phoneNumber ?? 0){
                    
                    let a = "\(data.number ?? 0)"
                    let number = Int64(String(a.suffix(10)))
                    self.unBlockNumber(nameString: data.name ?? "" , number: number ?? 0)
                    
                    self.blackListNumberArray.remove(at: i)
                    
                    UserDefaults.standard.set(self.blackListNumberArray.toJSON(), forKey: KEYBlackListArray)
                    UserDefaults.standard.synchronize()
                    
                    self.searchTextField.text = ""
                    
                    self.view.makeToast("Number remove successfully.")
                    
                    self.blackListNumberArrayMain = self.blackListNumberArray
                    
                    break
                }
            }
            
            tableView.reloadData()
            
            self.view.makeToast("Number unblock successfully.")
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension BlacklistNumberScreen: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.blockNumberTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let newIndexPath: IndexPath? = newIndexPath != nil ? IndexPath(row: newIndexPath!.row, section: 0) : nil
        let currentIndexPath: IndexPath? = indexPath != nil ? IndexPath(row: indexPath!.row, section: 0) : nil
        
        switch type {
        case .insert:
            self.blockNumberTableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .delete:
            self.blockNumberTableView.deleteRows(at: [currentIndexPath!], with: .fade)
            
        case .move:
            self.blockNumberTableView.moveRow(at: currentIndexPath!, to: newIndexPath!)
            
        case .update:
            self.blockNumberTableView.reloadRows(at: [currentIndexPath!], with: .automatic)
            
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.blockNumberTableView.endUpdates()
    }
}
