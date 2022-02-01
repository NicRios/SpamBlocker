//
//  HomeScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 07/10/21.
//

import UIKit
import CallKit
import CoreData
import CallerData
import CoreTelephony
import FirebaseMessaging

class HomeScreen: UIViewController {
    
    var caller: Caller? {
        didSet {
            self.updateUI()
        }
    }
    
    @IBOutlet weak var maxBlockingView: UIView!
    @IBOutlet weak var maxBlockingButton: UIButton!
    @IBOutlet weak var maxBlockingDownArrowImageView: UIImageView!
    @IBOutlet weak var maxBlockingSelectedImageView: UIImageView!
    @IBOutlet weak var maxBlockingBottomView: UIView!
    
    @IBOutlet weak var knownCallersView: UIView!
    @IBOutlet weak var knownCallersButton: UIButton!
    @IBOutlet weak var knownCallersDownArrowImageView: UIImageView!
    @IBOutlet weak var knownCallersSelectedImageView: UIImageView!
    @IBOutlet weak var knownCallersBottomView: UIView!
    
    @IBOutlet weak var noBlockingView: UIView!
    @IBOutlet weak var noBlockingButton: UIButton!
    @IBOutlet weak var noBlockingDownArrowImageView: UIImageView!
    @IBOutlet weak var noBlockingSelectedImageView: UIImageView!
    @IBOutlet weak var noBlockingBottomView: UIView!
    
    fileprivate var blockNumberArray: [MaxBlockingResponse] = []
    
    lazy private var callerData = CallerData()
    private var resultsController: NSFetchedResultsController<Caller>!
    
    fileprivate var blockedArray = [Int64]()
    
//    fileprivate var blackListNumberArray: [ContactResponse] = []
    
    fileprivate var page: Int = 0
    fileprivate var meta: Meta?
    
    fileprivate var ReloadAt: Int = 20000
    fileprivate var NextReloadAt: Int = 20000
    fileprivate var isReadFromJson: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInitialView()
        
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
    }
    
    func setUpInitialView(){
        
        //        let token = Messaging.messaging().fcmToken
        //        print("FCM token ----> \(token ?? "")")
        
        maxBlockingButton.setTitleColor(UIColor.init(hex: "34A6E6"), for: .normal)
        maxBlockingButton.setTitleColor(UIColor.white, for: .selected)
        
        knownCallersButton.setTitleColor(UIColor.init(hex: "34A6E6"), for: .normal)
        knownCallersButton.setTitleColor(UIColor.white, for: .selected)
        
        noBlockingButton.setTitleColor(UIColor.init(hex: "34A6E6"), for: .normal)
        noBlockingButton.setTitleColor(UIColor.white, for: .selected)
        
        setDefalutButtonView()
        
        setSelectedButton()
        
        retrieveblockNumber()
        //        deleteAllRecords()
        
    }
    
    func setDefalutButtonView(){
        maxBlockingBottomView.isHidden = true
        knownCallersBottomView.isHidden = true
        noBlockingBottomView.isHidden = true
        
        maxBlockingView.backgroundColor = UIColor.clear
        knownCallersView.backgroundColor = UIColor.clear
        noBlockingView.backgroundColor = UIColor.clear
        
        maxBlockingButton.isSelected = false
        knownCallersButton.isSelected = false
        noBlockingButton.isSelected = false
        
        maxBlockingDownArrowImageView.image = UIImage.init(named: "Arrow - Down_Gray")
        knownCallersDownArrowImageView.image = UIImage.init(named: "Arrow - Down_Gray")
        noBlockingDownArrowImageView.image = UIImage.init(named: "Arrow - Down_Gray")
    }
    
    func setSelectedButton(){
        maxBlockingSelectedImageView.isHidden = true
        knownCallersSelectedImageView.isHidden = true
        noBlockingSelectedImageView.isHidden = true
        
        let a = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        
        if a == 1{
            maxBlockingSelectedImageView.isHidden = false
            
            let JSonFileCount: Int = UserDefaults.standard.value(forKey: KEYJSonFileCount) as? Int ?? 0
            let BlockNumberCount: Int = UserDefaults.standard.value(forKey: KEYBlockNumberCount) as? Int ?? 0
            
            if BlockNumberCount < JSonFileCount{
                isBlockingNumberInProgress = true
                blockNumberFormJsonFile()
            }else{
                isBlockingNumberInProgress = false
                self.view.makeToast("Blocked all numbers.")
            }
        }
        else if a == 2{
            knownCallersSelectedImageView.isHidden = false
        }
        else if a == 3{
            noBlockingSelectedImageView.isHidden = false
        }
        else{
            
        }
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.mobile.app.Coverage-call-blocker.Coverage-call-blockerExtension", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
    }
    
    private func updateUI() {
        
    }
    
    //MARK: - Retrieve blocked number
    
    func retrieveBlockedData(isWarning: Bool) {
        
        blockedArray.removeAll()
        
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: true)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.resultsController.performFetch()
            
            //            let results = self.resultsController.fetchedObjects
            let results = try self.callerData.context.fetch(fetchRequest)
            self.blockedArray.append(contentsOf: results.map({$0.number}))
            
            print("blocked number count : ", blockedArray.count)
            
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
        if isReadFromJson{
            if isWarning{
                setWarningFormJsonFile()
            }else{
                blockNumberFormJsonFile()
            }
        }else{
            page = 1
            print("Page : ", page)
            print("Api calling at : ", Date())
            max_blockingAPI(isWarning: isWarning, pageINT: page)
        }
    }
    
    func retrieveblockNumber(){
        blockedArray.removeAll()
        
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: true)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.resultsController.performFetch()
            
            //            let results = self.resultsController.fetchedObjects
            let results = try self.callerData.context.fetch(fetchRequest)
            
            self.blockedArray.append(contentsOf: results.map({$0.number}))
            
            print("blocked number count : ", blockedArray.count)
            UserDefaults.standard.set(self.blockedArray.count, forKey: KEYBlockNumberCount)
            UserDefaults.standard.synchronize()
            
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Read number from jsonfile
    
    func blockNumberFormJsonFile(){
        
        DispatchQueue.global(qos: .background).async {
            print("Run on background thread")
            
            DispatchQueue.main.async { [weak self] in
                self?.view.makeToast("Start reading number from Json file.")
            }
            
            print("Start reading data from json file : ", Date())
            
            if let path = Bundle.main.path(forResource: "spams", ofType: "json") {
                do {//spams.json   //BlockContacts
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["data"] as? NSArray {
                        
                        print("End reading data from json file : ", Date())
                        print("json file number count : ", person.count)
                        UserDefaults.standard.set(person.count, forKey: KEYJSonFileCount)
                        UserDefaults.standard.synchronize()
                        
                        let BlockNumberCount: Int = UserDefaults.standard.value(forKey: KEYBlockNumberCount) as? Int ?? 0
                        print("Block Number Count : ", BlockNumberCount)
                        
                        let result = Array(person.dropFirst(BlockNumberCount))
                        print("Remaining json file number count : ", result.count)
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.view.makeToast("Start blocking number from Json file.")
                            print("Start blocking at : ", Date())
                        }
                        
                        isBlockingNumberInProgress = true
                        
                        //                        let context = self.callerData.context
                        //                        let privateManagedObjectContext: NSManagedObjectContext = {
                        //                            let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        //                            moc.parent = context
                        //                            return moc
                        //                        }()
                        
                        for item in result {
                            
                            let loginData = Utility.getUserData()
                            if loginData == nil{
                                print("Stop blocking.")
                                break
                            }
                            
                            //                            DispatchQueue.main.async {
                            //                            autoreleasepool {
                            let data = item as? NSDictionary ?? [:]
                            self.blockNumberArray.append(MaxBlockingResponse(user_id: data["id"] as? Int ?? 0, phone: data["phone"] as? String ?? "", context: data["context"] as? String ?? ""))
                            self.blockedArray.append(Int64(data["phone"] as? String ?? "") ?? 0)
                            
                            //                            let caller = self.caller ?? Caller(context: self.callerData.context)
                            //                            let caller = self.caller
                            //                                        let caller = Caller(context: self.callerData.context)
                            //                            let caller = NSEntityDescription.insertNewObject(forEntityName: "Caller", into: privateManagedObjectContext) as! Caller
                            //
                            //            //                            if caller != nil{
                            //                                        caller.name = data["context"] as? String ?? ""
                            //                                        caller.number = Int64(data["phone"] as? String ?? "") ?? 0
                            //                                        caller.isBlocked = true
                            //                                        caller.isRemoved = false
                            //                                        caller.updatedDate = Date()
                            //            //                            }
                            
                            self.saveOrInsertData(name: data["context"] as? String ?? "", number: Int64(data["phone"] as? String ?? "") ?? 0)
                            
                            //                            }
                            if self.blockNumberArray.count == self.ReloadAt{
                                self.callerData.saveContext()
                                //                                sleep(UInt32(3.5))
                                self.reload()
                                
                                DispatchQueue.main.async { [weak self] in
                                    self?.view.makeToast("Successfully blocked \(self?.ReloadAt ?? 0) numbers")
                                    UserDefaults.standard.set(self?.blockedArray.count ?? 0, forKey: KEYBlockNumberCount)
                                    UserDefaults.standard.synchronize()
                                }
                                
                                self.ReloadAt = self.ReloadAt + self.NextReloadAt
                                sleep(UInt32(1.0))
                                print("End blocking at : ", Date())
                                print("Successfully blocked \(self.ReloadAt) numbers")
                                print("Start blocking at : ", Date())
                            }
                        }
                        self.callerData.saveContext()
                        //                        sleep(UInt32(4.0))
                        print("End reading data from json file : ", Date())
                        print("Block number count : ", self.blockNumberArray.count)
                        print("Start blocking at : ", Date())
                        self.reload()
                        print("End blocking at : ", Date())
                        DispatchQueue.main.async { [weak self] in
                            self?.view.makeToast("Blocked all numbers.")
                            isBlockingNumberInProgress = false
                            //                            self?.endBackgroundTask()
                        }
                        
                        UserDefaults.standard.set(self.blockedArray.count, forKey: KEYBlockNumberCount)
                        UserDefaults.standard.synchronize()
                    }
                } catch {
                    print("Something wrong")
                }
            }
        }
    }
    
    func saveOrInsertData(name : String, number: Int64){
        let context = self.callerData.context
        let privateManagedObjectContext: NSManagedObjectContext = {
            let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            moc.parent = context
            return moc
        }()
        
        let caller = NSEntityDescription.insertNewObject(forEntityName: "Caller", into: privateManagedObjectContext) as! Caller
        caller.name = name
        caller.number = number
        caller.isFromContacts = false
        caller.isBlocked = true
        caller.isRemoved = false
        caller.updatedDate = Date()
        privateManagedObjectContext.perform {
            do {
                try privateManagedObjectContext.save()
            }catch {
                print("Something wrong in coredata.")
            }
        }
    }
    
    func setWarningFormJsonFile(){
        print("Start reading data from json file : ", Date())
        
        if let path = Bundle.main.path(forResource: "BlockContacts", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["data"] as? NSArray {
                    
                    print("json file number count : ", person.count)
                    
                    for item in 0...person.count - 1 {
                        let data = person[item] as? NSDictionary ?? [:]
                        
                        autoreleasepool {
                            let caller = self.caller ?? Caller(context: self.callerData.context)
                            caller.name = "This is spam call warning"
                            caller.number = Int64(data["phone"] as? String ?? "") ?? 0
                            caller.isFromContacts = false
                            caller.isBlocked = false
                            caller.isRemoved = false
                            caller.updatedDate = Date()
                            //                            self.callerBlockNumberArray.append(caller)
                            //                            self.callerData.saveContext()
                            
                            if item == self.ReloadAt{
                                self.callerData.saveContext()
                                sleep(UInt32(5.0))
                                self.reload()
                                print("Success \(self.ReloadAt) numbers")
                                
                                DispatchQueue.main.async {
                                    self.view.makeToast("Success \(self.ReloadAt) numbers")
                                }
                                
                                print("End blocking at : ", Date())
                                self.ReloadAt = self.ReloadAt + NextReloadAt
                                sleep(UInt32(5.0))
                                print("Start blocking at : ", Date())
                            }
                        }
                        
                    }
                    self.callerData.saveContext()
                    
                    print("End reading data from json file : ", Date())
                    print("Number count : ", blockNumberArray.count)
                    //                    self.goFurthermax_blockingAPI(isWarning: false)
                    print("Start blocking at : ", Date())
                    reload()
                    print("End blocking at : ", Date())
                }
            } catch {
                print("Something wrong")
            }
        }
    }
    
    //MARK: - Delete all numbers
    
    func deleteAllRecords() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Caller")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try self.callerData.context.execute(deleteRequest)
            try self.callerData.context.save()
        } catch {
            print ("There was an error")
        }
        
        reload()
        retrieveblockNumber()
        
    }
    
    //MARK: - Button clicked event
    
    @IBAction func onMenu(_ sender: Any)
    {
        self.view.endEditing(true)
        
        if(self.sideMenuController?.isLeftViewVisible)!
        {
            self.sideMenuController?.hideLeftView()
        }
        else
        {
            self.sideMenuController?.showLeftView()
        }
    }
    
    @IBAction func onMaxBlocking(_ sender: Any) {
        
        if maxBlockingButton.isSelected{
            setDefalutButtonView()
        }else{
            setDefalutButtonView()
            
            maxBlockingBottomView.isHidden = false
            maxBlockingView.backgroundColor = UIColor.init(hex: "34A6E6")
            maxBlockingButton.isSelected = true
            maxBlockingDownArrowImageView.image = UIImage.init(named: "Arrow - Down_White")
        }
        
    }
    
    @IBAction func onKnownCallers(_ sender: Any) {
        
        if knownCallersButton.isSelected{
            setDefalutButtonView()
        }else{
            setDefalutButtonView()
            
            knownCallersBottomView.isHidden = false
            knownCallersView.backgroundColor = UIColor.init(hex: "34A6E6")
            knownCallersButton.isSelected = true
            knownCallersDownArrowImageView.image = UIImage.init(named: "Arrow - Down_White")
        }
        
    }
    
    @IBAction func onNoBlocking(_ sender: Any) {
        
        if noBlockingButton.isSelected{
            setDefalutButtonView()
        }else{
            setDefalutButtonView()
            
            noBlockingBottomView.isHidden = false
            noBlockingView.backgroundColor = UIColor.init(hex: "34A6E6")
            noBlockingButton.isSelected = true
            noBlockingDownArrowImageView.image = UIImage.init(named: "Arrow - Down_White")
        }
        
    }
    
    @IBAction func onSelectMaxBlocking(_ sender: UIButton) {
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
        
        let selectebutton: Int = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        if selectebutton == 1{
            self.view.makeToast("You already blocked numbers.")
            return
        }
        
        retrieveBlockedData(isWarning: false)
        
        UserDefaults.standard.setValue(1, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        setSelectedButton()
        
        //        DispatchQueue.background(background: {
        //            self.retrieveBlockedData(isWarning: false)
        //        }, completion:{
        //            UserDefaults.standard.setValue(1, forKey: KEYSelectedOptionOnHomeScreen)
        //            UserDefaults.standard.synchronize()
        //
        //            self.setSelectedButton()
        //        })
        
    }
    
    @IBAction func onSelectKnownCallers(_ sender: UIButton) {
        
        self.view.makeToast("This module is under development")
        return
        
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
        
        let selectebutton: Int = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        if selectebutton == 2{
            self.view.makeToast("You are already in Spam Blocking system.")
            return
        }
        
        //=========
        
//        if let tempDic = UserDefaults.standard.value(forKey: KEYBlackListArray) as? [[String:Any]]  {
//
//            for i in tempDic {
//                autoreleasepool{
//                    if let obj = ContactResponse(JSON:i) {
//                        self.blackListNumberArray.append(obj)
//                    }
//                }
//            }
//
//            print("BlackList array from user defaults : ",self.blackListNumberArray.toJSON())
//        }
        
        //=========
        let results = self.resultsController.fetchedObjects
        
        for i in 0..<results!.count {
            autoreleasepool{
                let indexPath = IndexPath(item: i, section: 0)
                let caller = self.resultsController.object(at: indexPath)
                
//                if self.blackListNumberArray.contains(where: { $0.number != caller.number}){
//
//                    caller.isRemoved = true
//                    //            caller.isBlocked = false
//                    caller.updatedDate = Date()                    //                    self.callerData.saveContext()
//                }
//                else{
                    caller.name = caller.name
                    //                caller.number  = num ?? 0
                    caller.number = caller.number
                    caller.isFromContacts = false
                    caller.isBlocked = true
                    caller.isRemoved = true
                    caller.updatedDate = Date()
                    //                    self.callerData.saveContext()
//                }
            }
        }
        self.callerData.saveContext()
        self.reload()
        
        Utility.hideIndicator()
        
        if isReadFromJson{
            
            print("Start reading data from json file : ", Date())
            
            if let path = Bundle.main.path(forResource: "spams", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["data"] as? NSArray {
                        
                        print("json file number count : ", person.count)
                        
                        for item in 0...person.count - 1 {
                            autoreleasepool {
                                let data = person[item] as? NSDictionary ?? [:]
                                
                                let caller = self.caller ?? Caller(context: self.callerData.context)
                                caller.name = data["context"] as? String ?? ""
                                caller.number = Int64(data["phone"] as? String ?? "") ?? 0
                                caller.isFromContacts = false
                                caller.isBlocked = true
                                caller.isRemoved = false
                                caller.updatedDate = Date()
                                //                            self.callerBlockNumberArray.append(caller)
                                //                            self.callerData.saveContext()
                            }
                            
                            if item == self.ReloadAt{
                                self.callerData.saveContext()
                                sleep(UInt32(5.0))
                                self.reload()
                                print("Success \(self.ReloadAt) numbers")
                                
                                DispatchQueue.main.async {
                                    self.view.makeToast("Success \(self.ReloadAt) numbers")
                                }
                                
                                print("End blocking at : ", Date())
                                self.ReloadAt = self.ReloadAt + NextReloadAt
                                sleep(UInt32(5.0))
                                print("Start blocking at : ", Date())
                            }
                        }
                        self.callerData.saveContext()
                        
                        print("End reading data from json file : ", Date())
                        print("Number count : ", self.blockNumberArray.count)
                        //                    self.goFurthermax_blockingAPI(isWarning: false)
                        print("Start blocking at : ", Date())
                        self.reload()
                        print("End blocking at : ", Date())
                    }
                } catch {
                    print("Something wrong")
                }
            }
            
        }else{
            page = 1
            getSpamsAPI(pageINT: page)
        }
        
        UserDefaults.standard.setValue(2, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        setSelectedButton()
    }
    
    @IBAction func onSelectNoBlocking(_ sender: UIButton) {
        
        self.view.makeToast("This module is under development")
        return
        
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
        
        let selectebutton: Int = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        if selectebutton == 3{
            self.view.makeToast("You already set spam call warning.")
            return
        }
        
        DispatchQueue.main.async {
            Utility.showIndecator()
        }
        
        //=========
        
//        if let tempDic = UserDefaults.standard.value(forKey: KEYBlackListArray) as? [[String:Any]]  {
//
//            for i in tempDic {
//                autoreleasepool{
//                    if let obj = ContactResponse(JSON:i) {
//                        self.blackListNumberArray.append(obj)
//                    }
//                }
//            }
//
//            print("BlackList array from user defaults : ",self.blackListNumberArray.toJSON())
//        }
        
        //=========
        let results = self.resultsController.fetchedObjects
        
        for i in 0..<results!.count {
            autoreleasepool{
                let indexPath = IndexPath(item: i, section: 0)
                let caller = self.resultsController.object(at: indexPath)
                
//                if self.blackListNumberArray.contains(where: { $0.number != caller.number}){
//
//                    caller.isRemoved = true
//                    //            caller.isBlocked = false
//                    caller.updatedDate = Date()                    //                    self.callerData.saveContext()
//                }
//                else{
                    //                print("phonenumberInt : ", phonenumberInt)
                    //                let num = Int64("\(CountryCode)"+"\(phonenumberInt)")
                    
                    caller.name = caller.name
                    //                caller.number  = num ?? 0
                    caller.number = caller.number
                    caller.isFromContacts = false
                    caller.isBlocked = true
                    caller.isRemoved = true
                    caller.updatedDate = Date()
                    //                    self.callerData.saveContext()
//                }
            }
        }
        self.callerData.saveContext()
        self.reload()
        
        Utility.hideIndicator()
        
        //========
        
        retrieveBlockedData(isWarning: true)
        
        UserDefaults.standard.setValue(3, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        setSelectedButton()
    }
}

//MARK: - API
extension HomeScreen{
    
    //MARK: - max_blocking API
    func max_blockingAPI(isWarning: Bool,pageINT: Int){
        //        self.view.endEditing(true)
        //        Utility.showIndecator()
        let url = "\(getMaxBlockingURL)?page=\(page)"
        ServeyServices.shared.max_blocking(url:url,success: {  (statusCode, response) in
            
            if let metaRes = response?.metaResponse{
                self.meta = metaRes
            }
            
            if (response?.maxBlockingResponse) != nil{
                print("Api response at : ", Date())
                if self.meta?.lastPage ?? 0 >= self.meta?.currentPage ?? 0
                {
                    self.blockNumberArray = response?.maxBlockingResponse ?? []
                    self.goFurthermax_blockingAPI(isWarning: isWarning)
                }
                else
                {
                    Utility.hideIndicator()
                    self.view.makeToast("Success")
                }
            }
            
        }, failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        })
    }
    
    func goFurthermax_blockingAPI(isWarning: Bool){
        
        //        print("==== Start blocking ====")
        print("Start Store number in db at : ", Date())
        
        //=== Before
        
        for i in 0..<self.blockNumberArray.count {
            autoreleasepool {
                let contact = self.blockNumberArray[i]
                if isWarning{
                    //                    self.warningNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0)
                    
                    let caller = self.caller ?? Caller(context: self.callerData.context)
                    caller.name = "This is spam call warning"
                    //        caller.number  = num ?? 0
                    caller.number  = Int64(contact.phone ?? "0") ?? 0
                    caller.isFromContacts = false
                    caller.isBlocked = false
                    caller.isRemoved = false
                    caller.updatedDate = Date()
                    self.callerData.saveContext()
                    
                }
                else{
                    autoreleasepool {
                        
                        if !self.blockedArray.contains(Int64(contact.phone ?? "0") ?? 0){
                            //                            self.blockNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0 )
                            
                            let caller = self.caller ?? Caller(context: self.callerData.context)
                            caller.name = contact.context ?? ""
                            //        caller.number  = num ?? 0
                            caller.number  = Int64(contact.phone ?? "0") ?? 0
                            caller.isFromContacts = false
                            caller.isBlocked = true
                            caller.isRemoved = false
                            caller.updatedDate = Date()
                            //                            self.callerData.saveContext()
                            
                        }
                    }
                }
            }
        }
        
        print("End Store number in db at : ", Date())
        
        print("Start blocking at : ", Date())
        //        //=== After
        //
        //        let array = self.blockNumberArray.filter{ !self.blockedArray.contains(Int64($0.phone?.suffix(10) ?? "") ?? 0)}
        //        print("array : ", array)
        //        print("array count : ", array.count)
        //        for i in 0..<array.count {
        //            autoreleasepool {
        //            let contact = array[i]
        //            self.blockNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0)
        //            }
        //        }
        //        //===
        
        //        if isWarning{
        reload()
        //        }
        
        //        self.view.makeToast("Success")
        //        print("==== End blocking ====")
        print("End blocking at : ", Date())
        
        retrieveblockNumber()
        
        let currentPage = self.meta?.currentPage ?? 0
        self.page = currentPage + 1
        print("Page : ", self.page)
        print("Api calling at : ", Date())
        self.max_blockingAPI(isWarning: isWarning, pageINT: self.page)
        
    }
    
    //MARK: - getSpams API
    func getSpamsAPI(pageINT: Int){
        self.view.endEditing(true)
        Utility.showIndecator()
        
        let url = "\(getSpamsURL)?page=\(pageINT)"
        
        ServeyServices.shared.max_blocking(url: url, success: {  (statusCode, response) in
            
            if let metaRes = response?.metaResponse{
                self.meta = metaRes
            }
            
            if (response?.maxBlockingResponse) != nil{
                if self.meta?.lastPage ?? 0 >= self.meta?.currentPage ?? 0{
                    self.blockNumberArray = response?.maxBlockingResponse ?? []
                    self.goFurthergetSpamsAPI()
                    
                }else{
                    Utility.hideIndicator()
                    self.view.makeToast("Success")
                }
            }
            
        }, failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        })
    }
    
    func goFurthergetSpamsAPI(){
        for i in 0..<self.blockNumberArray.count {
            autoreleasepool{
                let contact = self.blockNumberArray[i]
                
                //            let phonenumber = contact.phone ?? "0"
                //            let phonenumberInt = Int(phonenumber.suffix(10))
                
                //                if !self.blockedArray.contains(Int64(contact.phone ?? "0") ?? 0){
                //                    self.blockNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0)
                //                }
                
                autoreleasepool {
                    
                    if !self.blockedArray.contains(Int64(contact.phone ?? "0") ?? 0){
                        //                            self.blockNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0 )
                        
                        let caller = self.caller ?? Caller(context: self.callerData.context)
                        caller.name = contact.context ?? ""
                        //        caller.number  = num ?? 0
                        caller.number  = Int64(contact.phone ?? "0") ?? 0
                        caller.isFromContacts = false
                        caller.isBlocked = true
                        caller.isRemoved = false
                        caller.updatedDate = Date()
                        //                            self.callerData.saveContext()
                        
                    }
                }
                
            }
        }
        
        retrieveblockNumber()
        
        let currentPage = self.meta?.currentPage ?? 0
        self.page = currentPage + 1
        self.getSpamsAPI(pageINT: self.page)
        
    }
}

//DispatchQueue.background(delay: 3.0, background: {
//    // do something in background
//}, completion: {
//    // when background job finishes, wait 3 seconds and do something in main thread
//})
//
//DispatchQueue.background(background: {
//    // do something in background
//}, completion:{
//    // when background job finished, do something in main thread
//})
//
//DispatchQueue.background(delay: 3.0, completion:{
//    // do something in main thread after 3 seconds
//})

////==========
//Dispatch.background {
//    // do stuff
//
//    Dispatch.main {
//        // update UI
//    }
//}
////==========

