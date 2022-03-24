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

class HomeScreen: UIViewController {
    
    @IBOutlet weak var maxBlockingView: UIView!
    @IBOutlet weak var maxBlockingButton: UIButton!
    @IBOutlet weak var maxBlockingDownArrowImageView: UIImageView!
    @IBOutlet weak var maxBlockingSelectedImageView: UIImageView!
    @IBOutlet weak var maxBlockingBottomView: UIView!
    @IBOutlet weak var maxBlockingSelectButton: UIButton!
    @IBOutlet weak var maxBlockingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var knownCallersView: UIView!
    @IBOutlet weak var knownCallersButton: UIButton!
    @IBOutlet weak var knownCallersDownArrowImageView: UIImageView!
    @IBOutlet weak var knownCallersSelectedImageView: UIImageView!
    @IBOutlet weak var knownCallersBottomView: UIView!
    @IBOutlet weak var knownCallersSelectButton: UIButton!
    @IBOutlet weak var knownCallersIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noBlockingView: UIView!
    @IBOutlet weak var noBlockingButton: UIButton!
    @IBOutlet weak var noBlockingDownArrowImageView: UIImageView!
    @IBOutlet weak var noBlockingSelectedImageView: UIImageView!
    @IBOutlet weak var noBlockingBottomView: UIView!
    @IBOutlet weak var noBlockingSelectButton: UIButton!
    @IBOutlet weak var noBlockingIndicator: UIActivityIndicatorView!
    
    fileprivate var blockListContackNumberArray: [Caller] = []
    
    lazy private var callerData = CallerData()
    private var resultsController: NSFetchedResultsController<Caller>!
    
    fileprivate var page: Int = 0
    fileprivate var meta: Meta?
    
    fileprivate var ReloadAt: Int = 20000
    fileprivate var NextReloadAt: Int = 20000
    fileprivate var isReadFromJson: Bool = true
    
    //AllContacts
    //AllContactsLaks
    fileprivate var jsonFileName: String = "AllContactsLaks"
    
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    //    let context = callerData.context
    let privateManagedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.parent = CallerData().context
        return moc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInitialView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkSubscriptionAPI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Memory warning")
    }
    
    func setUpInitialView(){
        maxBlockingButton.setTitleColor(UIColor.init(hex: "34A6E6"), for: .normal)
        maxBlockingButton.setTitleColor(UIColor.white, for: .selected)
        
        knownCallersButton.setTitleColor(UIColor.init(hex: "34A6E6"), for: .normal)
        knownCallersButton.setTitleColor(UIColor.white, for: .selected)
        
        noBlockingButton.setTitleColor(UIColor.init(hex: "34A6E6"), for: .normal)
        noBlockingButton.setTitleColor(UIColor.white, for: .selected)
        
        setDefalutButtonView()
        
        setSelectedButton()
        
        checkRemainingNumber()
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
    
    func checkRemainingNumber(){
        let a = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        
        if a == 1{
            let JSonFileCount: Int = UserDefaults.standard.value(forKey: KEYJSonFileCount) as? Int ?? 0
            let BlockNumberCount: Int = UserDefaults.standard.value(forKey: KEYBlockNumberCount) as? Int ?? 0
            
            if BlockNumberCount < JSonFileCount{
                isBlockingNumberInProgress = true
                
                maxBlockingIndicator.startAnimating()
                
                maxBlockingSelectButton.isUserInteractionEnabled = false
                knownCallersSelectButton.isUserInteractionEnabled = false
                noBlockingSelectButton.isUserInteractionEnabled = false
                
                blockNumberFormJsonFile(isSpam: false, isWarning: false)
            }else{
                isBlockingNumberInProgress = false
                self.view.makeToast("Successfully blocked all numbers.")
            }
        }
        else if a == 2{
            let JSonFileCount: Int = UserDefaults.standard.value(forKey: KEYJSonFileCount) as? Int ?? 0
            let BlockNumberCount: Int = UserDefaults.standard.value(forKey: KEYBlockNumberCount) as? Int ?? 0
            
            if BlockNumberCount < JSonFileCount{
                isBlockingNumberInProgress = true
                
                knownCallersIndicator.startAnimating()
                
                maxBlockingSelectButton.isUserInteractionEnabled = false
                knownCallersSelectButton.isUserInteractionEnabled = false
                noBlockingSelectButton.isUserInteractionEnabled = false
                
                blockNumberFormJsonFile(isSpam: true, isWarning: false)
            }else{
                isBlockingNumberInProgress = false
                self.view.makeToast("Successfully blocked all numbers.")
            }
        }
        else if a == 3{
            let JSonFileCount: Int = UserDefaults.standard.value(forKey: KEYJSonFileCount) as? Int ?? 0
            let BlockNumberCount: Int = UserDefaults.standard.value(forKey: KEYBlockNumberCount) as? Int ?? 0
            
            if BlockNumberCount < JSonFileCount{
                isBlockingNumberInProgress = true
                
                noBlockingIndicator.startAnimating()
                
                maxBlockingSelectButton.isUserInteractionEnabled = false
                knownCallersSelectButton.isUserInteractionEnabled = false
                noBlockingSelectButton.isUserInteractionEnabled = false
                
                blockNumberFormJsonFile(isSpam: false, isWarning: true)
            }else{
                isBlockingNumberInProgress = false
                self.view.makeToast("Successfully set warining for all numbers.")
            }
        }
        else{
            
        }
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: reloadExtetionString, completionHandler: { (enabledStatus,error) ->
            
            Void in if let error = error {
                print("ReloadExtension Error: \(error.localizedDescription)")
            }
            CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: reloadExtetionString, completionHandler: {
                (error) ->
                
                Void in if let error = error {
                    print("ReloadExtension Error: \(error.localizedDescription)")
                    
                    DispatchQueue.main.async {
                        self.view.makeToast(error.localizedDescription)
                    }
                }
            })
            print("ReloadExtension No error")
        })
    }
    
    func pushToInAppPurchase(){
        let vc =  STORYBOARD.inAppPurchase.instantiateViewController(withIdentifier: "InAppPurchaseScreen") as! InAppPurchaseScreen
        vc.isFromHomeScreen = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Read number from jsonfile
    
    func blockNumberFormJsonFile(isSpam: Bool, isWarning: Bool){
        DispatchQueue.global(qos: .background).async {
            print("Run on background thread")
            
            DispatchQueue.main.async { [weak self] in
                self?.view.makeToast("Start reading number from Json file.")
            }
            
            print("Start reading data from json file : ", Date())
            
            if let path = Bundle.main.path(forResource: self.jsonFileName, ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["data"] as? NSArray {
                        
                        print("End reading data from json file : ", Date())
                        print("json file number count : ", person.count)
                        UserDefaults.standard.set(person.count, forKey: KEYJSonFileCount)
                        UserDefaults.standard.synchronize()
                        
                        var BlockNumberCount = 0
                        
                        BlockNumberCount = UserDefaults.standard.value(forKey: KEYBlockNumberCount) as? Int ?? 0
                        print("Block Number Count : ", BlockNumberCount)
                        
                        let remainingNumberArray = Array(person.dropFirst(BlockNumberCount))
                        print("Remaining json file number count : ", remainingNumberArray.count)
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.view.makeToast("Start blocking number from Json file.")
                            print("Start blocking at : ", Date())
                        }
                        
                        isBlockingNumberInProgress = true
                        
                        self.ReloadAt = BlockNumberCount + self.NextReloadAt
                        
                        //                        autoreleasepool() {
                        for item in remainingNumberArray {
                            
                            let loginData = Utility.getUserData()
                            if loginData == nil{
                                print("Stop blocking.")
                                break
                            }
                            
                            BlockNumberCount = BlockNumberCount + 1
                            
                            let data = item as? NSDictionary ?? [:]
                            
                            if isWarning == false{
                                
                                if isSpam == true {
                                    if data["category"] as? String ?? "" == "Spam"{
                                        self.saveBlockNumber(name: "number\(BlockNumberCount)", number: Int64(data["phone"] as? String ?? "") ?? 0, category: data["category"] as? String ?? "", isFromContacts: false)
                                    }
                                    else{
                                        self.saveWarningNumber(name: "number\(BlockNumberCount)", number: Int64(data["phone"] as? String ?? "") ?? 0, category: data["category"] as? String ?? "")
                                    }
                                }
                                else{
                                    self.saveBlockNumber(name: "number\(BlockNumberCount)", number: Int64(data["phone"] as? String ?? "") ?? 0, category: data["category"] as? String ?? "", isFromContacts: false)
                                }
                            }
                            else{
                                self.saveWarningNumber(name: "number\(BlockNumberCount)", number: Int64(data["phone"] as? String ?? "") ?? 0, category: data["category"] as? String ?? "")
                            }
                            
                            if BlockNumberCount == self.ReloadAt{
                                self.callerData.saveContext()
                                sleep(UInt32(1.0))
                                self.reload()
                                sleep(UInt32(3.0))
                                DispatchQueue.main.async { [weak self] in
                                    self?.view.makeToast("Successfully completed \(BlockNumberCount) numbers")
                                    
                                    UserDefaults.standard.set(BlockNumberCount, forKey: KEYBlockNumberCount)
                                    UserDefaults.standard.synchronize()
                                }
                                
                                print("End blocking at : ", Date())
                                print("Successfully completed \(self.ReloadAt) numbers")
                                self.ReloadAt = self.ReloadAt + self.NextReloadAt
                                print("Start blocking at : ", Date())
                                sleep(UInt32(1.0))
                            }
                        }
                        //                        }
                        self.callerData.saveContext()
                        sleep(UInt32(1.0))
                        print("Block number count : ", BlockNumberCount)
                        self.reload()
                        sleep(UInt32(3.0))
                        print("End blocking at : ", Date())
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.maxBlockingIndicator.stopAnimating()
                            self?.knownCallersIndicator.stopAnimating()
                            self?.noBlockingIndicator.stopAnimating()
                            self?.maxBlockingSelectButton.isUserInteractionEnabled = true
                            self?.knownCallersSelectButton.isUserInteractionEnabled = true
                            self?.noBlockingSelectButton.isUserInteractionEnabled = true
                            self?.view.makeToast("Successfully completed all numbers.")
                            isBlockingNumberInProgress = false
                        }
                        
                        let JSonFileCount: Int = UserDefaults.standard.value(forKey: KEYJSonFileCount) as? Int ?? 0
                        UserDefaults.standard.set(JSonFileCount, forKey: KEYBlockNumberCount)
                        UserDefaults.standard.synchronize()
                    }
                } catch {
                    print("Something wrong in JSON file")
                }
            }
        }
    }
    
    func saveBlockNumber(name : String, number: Int64, category: String, isFromContacts: Bool){
        let context = self.callerData.context
        let privateManagedObjectContext: NSManagedObjectContext = {
            let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            moc.parent = context
            return moc
        }()
        
        let caller = NSEntityDescription.insertNewObject(forEntityName: "Caller", into: privateManagedObjectContext) as? Caller
        caller?.name = name
        caller?.number = number
        caller?.isFromContacts = isFromContacts
        caller?.isBlocked = true
        caller?.isRemoved = false
        caller?.category = category
        caller?.updatedDate = Date()
        privateManagedObjectContext.perform {
            do {
                try privateManagedObjectContext.save()
            }catch {
                print("Something wrong in coredata.")
            }
        }
        
        /*
         let caller = self.caller ?? Caller(context: self.callerData.context)
         caller.name = name
         caller.number = number
         caller.isFromContacts = isFromContacts
         caller.isBlocked = true
         caller.isRemoved = false
         caller.category = category
         caller.updatedDate = Date()
         //        self.callerData.saveContext()
         */
    }
    
    func saveWarningNumber(name : String, number: Int64, category: String){
        let context = self.callerData.context
        let privateManagedObjectContext: NSManagedObjectContext = {
            let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            moc.parent = context
            return moc
        }()
        
        let caller = NSEntityDescription.insertNewObject(forEntityName: "Caller", into: privateManagedObjectContext) as? Caller
        caller?.name = "This is spam call warning"
        caller?.number = number
        caller?.isFromContacts = false
        caller?.isBlocked = false
        caller?.isRemoved = false
        caller?.category = category
        caller?.updatedDate = Date()
        privateManagedObjectContext.perform {
            do {
                try privateManagedObjectContext.save()
            }catch {
                print("Something wrong in coredata.")
            }
        }
        
        /*
         let caller = self.caller ?? Caller(context: self.callerData.context)
         caller.name = "This is spam call warning"
         caller.number = number
         caller.isFromContacts = false
         caller.isBlocked = false
         caller.isRemoved = false
         caller.category = category
         caller.updatedDate = Date()
         //        self.callerData.saveContext()
         */
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
        
        sleep(UInt32(2.0))
        self.reload()
        sleep(UInt32(2.0))
        
        print("blockListContackNumberArrayCount : ", self.blockListContackNumberArray.count)
        if self.blockListContackNumberArray.count != 0{
            //            autoreleasepool(){
            for objData in self.blockListContackNumberArray{
                self.saveBlockNumber(name: objData.name ?? "", number: objData.number, category: objData.category ?? "", isFromContacts: true)
            }
            self.callerData.saveContext()
            self.reload()
            sleep(UInt32(2.0))
            //            }
            print("Successfully blocked contact number.")
        }
        else{
            print("No contact number.")
        }
    }
    
    func getContactBlockedNumbers() {
        let manageContext = self.callerData.context
        let fetchRequest = NSFetchRequest<Caller>(entityName: "Caller")
        
        //        let fetchRequestIsBlocked = NSPredicate(format:"isRemoved == %@",NSNumber(value:true))
        let fetchRequestIsFromContact = NSPredicate(format:"isFromContacts == %@",NSNumber(value:true))
        let predicate: NSPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fetchRequestIsFromContact])
        fetchRequest.predicate = predicate
        
        do {
            self.blockListContackNumberArray.removeAll()
            self.blockListContackNumberArray = try manageContext.fetch(fetchRequest)
            print("blockListContackNumberArrayCount : ", self.blockListContackNumberArray.count)
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
        deleteAllRecords()
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
        
        // For In-app purchase check
        /*
         if Utility.getUserData()?.isPremium != 1{
         
         let actionYes : [String: () -> Void] = [ "YES" : { (
         self.pushToInAppPurchase()
         ) }]
         let actionNo : [String: () -> Void] = [ "No" : { (
         print("tapped NO")
         ) }]
         let arrayActions = [actionYes, actionNo]
         
         //#imageLiteral(resourceName: "app logos_Blue")
         self.showCustomAlertWith(
         message: "For use this functionality, Please subscribe.",
         descMsg: "",
         itemimage: nil,
         actions: arrayActions)
         
         return
         }
         */
        
        let selectebutton: Int = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        if selectebutton == 1{
            self.view.makeToast("You already blocked numbers.")
            return
        }
        
        self.getContactBlockedNumbers()
        
        print("Start")
        
        self.maxBlockingIndicator.startAnimating()
        
        self.maxBlockingSelectButton.isUserInteractionEnabled = false
        self.knownCallersSelectButton.isUserInteractionEnabled = false
        self.noBlockingSelectButton.isUserInteractionEnabled = false
        
        ReloadAt = NextReloadAt
        
        UserDefaults.standard.set(0, forKey: KEYBlockNumberCount)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.blockNumberFormJsonFile(isSpam: false, isWarning: false)
        })
        
        
        UserDefaults.standard.setValue(1, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        self.setSelectedButton()
        
    }
    
    @IBAction func onSelectKnownCallers(_ sender: UIButton) {
        
        // For In-app purchase check
        /*
         if Utility.getUserData()?.isPremium != 1{
         
         let actionYes : [String: () -> Void] = [ "YES" : { (
         self.pushToInAppPurchase()
         ) }]
         let actionNo : [String: () -> Void] = [ "No" : { (
         print("tapped NO")
         ) }]
         let arrayActions = [actionYes, actionNo]
         
         //#imageLiteral(resourceName: "app logos_Blue")
         self.showCustomAlertWith(
         message: "For use this functionality, Please subscribe.",
         descMsg: "",
         itemimage: nil,
         actions: arrayActions)
         
         return
         }
         */
        
        let selectebutton: Int = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        if selectebutton == 2{
            self.view.makeToast("You are already in Spam Blocking system.")
            return
        }
        
        self.getContactBlockedNumbers()
        
        print("Start")
        
        knownCallersIndicator.startAnimating()
        
        maxBlockingSelectButton.isUserInteractionEnabled = false
        knownCallersSelectButton.isUserInteractionEnabled = false
        noBlockingSelectButton.isUserInteractionEnabled = false
        
        ReloadAt = NextReloadAt
        
        UserDefaults.standard.set(0, forKey: KEYBlockNumberCount)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.blockNumberFormJsonFile(isSpam: true, isWarning: false)
        })
        
        UserDefaults.standard.setValue(2, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        setSelectedButton()
    }
    
    @IBAction func onSelectNoBlocking(_ sender: UIButton) {
        
        // For In-app purchase check
        /*
         if Utility.getUserData()?.isPremium != 1{
         
         let actionYes : [String: () -> Void] = [ "YES" : { (
         self.pushToInAppPurchase()
         ) }]
         let actionNo : [String: () -> Void] = [ "No" : { (
         print("tapped NO")
         ) }]
         let arrayActions = [actionYes, actionNo]
         
         //#imageLiteral(resourceName: "app logos_Blue")
         self.showCustomAlertWith(
         message: "For use this functionality, Please subscribe.",
         descMsg: "",
         itemimage: nil,
         actions: arrayActions)
         
         return
         }
         */
        
        let selectebutton: Int = UserDefaults.standard.value(forKey: KEYSelectedOptionOnHomeScreen) as? Int ?? 0
        if selectebutton == 3{
            self.view.makeToast("You already set spam call warning.")
            return
        }
        
        self.getContactBlockedNumbers()
        
        print("Start")
        
        noBlockingIndicator.startAnimating()
        
        maxBlockingSelectButton.isUserInteractionEnabled = false
        knownCallersSelectButton.isUserInteractionEnabled = false
        noBlockingSelectButton.isUserInteractionEnabled = false
        
        ReloadAt = NextReloadAt
        
        UserDefaults.standard.set(0, forKey: KEYBlockNumberCount)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.blockNumberFormJsonFile(isSpam: false, isWarning: true)
        })
        
        UserDefaults.standard.setValue(3, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        setSelectedButton()
    }
}

extension HomeScreen{
    
    //MARK: - check Subscription API
    func checkSubscriptionAPI(){
        SubscriptionServices.shared.checkSubscriptionAPI(success: {  (statusCode, response) in
            let data = Utility.getUserData()
            data?.isPremium = response.checkSubscription?.is_premium
            if let data1 = data{
                Utility.saveUserData(data: data1.toJSON())
            }
        }, failure: { [weak self] (error) in
            guard self != nil else { return }
        })
    }
}
