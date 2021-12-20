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

class HomeScreen: UIViewController {
    
    var caller: Caller? {
        didSet {
            //            self.updateUI()
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
    
    var blockNumberArray: [MaxBlockingResponse] = []
    
    lazy private var callerData = CallerData()
    private var resultsController: NSFetchedResultsController<Caller>!
    
    var blockedArray = [Int64]()
    
    fileprivate var blackListNumberArray: [ContactResponse] = []
    
    var page: Int = 0
    var meta: Meta?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpInitialView()
        
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
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
        
        retiveblockNumber()
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
    
    func blockNumber(nameString : String , number: Int64){
        
        //        print("nameString : ", nameString)
        //        print("number : ", number)
        //        let num = Int64("\(CountryCode)"+"\(number)")
        //        print("num : ", num ?? 0)
        //        print("number : ", number)
        
        let caller = self.caller ?? Caller(context: self.callerData.context)
        caller.name = nameString
        //        caller.number  = num ?? 0
        caller.number  = number
        caller.isBlocked = true
        caller.isRemoved = false
        caller.updatedDate = Date()
        self.callerData.saveContext()
        
        //        reload()
    }
    
    func warningNumber(nameString : String , number: Int64){
        
        //        print("nameString : ", nameString)
        //        print("number : ", number)
        //        let num = Int64("\(CountryCode)"+"\(number)")
        //        print("num : ", num ?? 0)
        
        let caller = self.caller ?? Caller(context: self.callerData.context)
        caller.name = "This is spam call warning"
        //        caller.number  = num ?? 0
        caller.number  = number
        caller.isBlocked = false
        caller.isRemoved = false
        caller.updatedDate = Date()
        self.callerData.saveContext()
        
        //        reload()
    }
    
    func reload(){
        
        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "com.test.mobile.app.Coverage-call-blocker.Coverage-call-blockerExtension", completionHandler: { (error) in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            }
        })
    }
    
    func retrieveBlockedData(isWarning: Bool) {
        
        blockedArray.removeAll()
        
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: true)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.resultsController.performFetch()
            
            let results = self.resultsController.fetchedObjects
            
            for i in 0..<results!.count {
                autoreleasepool{
                    let indexPath = IndexPath(item: i, section: 0)
                    let caller = self.resultsController.object(at: indexPath)
                    //                let phonenumber = "\(caller.number)"
                    //                let phonenumberInt = Int64(phonenumber.suffix(10)) ?? 0
                    //                blockedArray.append(phonenumberInt)
                    blockedArray.append(caller.number)
                }
            }
            
//            blockedArray.sort()
            
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
        
        page = 1
        print("Page : ", page)
        print("Api calling at : ", Date())
        max_blockingAPI(isWarning: isWarning, pageINT: page)
        
    }
    
    func retiveblockNumber(){
        blockedArray.removeAll()
        
        let fetchRequest:NSFetchRequest<Caller> = self.callerData.fetchRequest(blocked: true)
        
        self.resultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.callerData.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try self.resultsController.performFetch()
            
            let results = self.resultsController.fetchedObjects
            
            for i in 0..<results!.count {
                autoreleasepool{
                    let indexPath = IndexPath(item: i, section: 0)
                    let caller = self.resultsController.object(at: indexPath)
                    //                let phonenumber = "\(caller.number)"
                    //                let phonenumberInt = Int64(phonenumber.suffix(10)) ?? 0
                    //                blockedArray.append(phonenumberInt)
                    blockedArray.append(caller.number)
                }
            }
            
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }
    
    //    func hasCellularCoverage() -> Bool {
    //
    //        if #available(iOS 12.0, *) {
    //            return CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value.mobileNetworkCode != nil
    //        } else {
    //            if let _ = CTTelephonyNetworkInfo().subscriberCellularProvider?.isoCountryCode {
    //                return true
    //            } else {
    //                return false
    //            }
    //        }
    //    }
    
    //MARK: - button clicked event
    
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
    }
    
    @IBAction func onSelectKnownCallers(_ sender: UIButton) {
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
        
        page = 1
        getSpamsAPI(pageINT: page)
        
        UserDefaults.standard.setValue(2, forKey: KEYSelectedOptionOnHomeScreen)
        UserDefaults.standard.synchronize()
        
        setSelectedButton()
    }
    
    @IBAction func onSelectNoBlocking(_ sender: UIButton) {
        if hasCellularCoverage() == false{
            self.view.makeToast(SimNotAvailableMessage)
            return
        }
        
        //=========
        
        if let tempDic = UserDefaults.standard.value(forKey: KEYBlackListArray) as? [[String:Any]]  {
            
            for i in tempDic {
                autoreleasepool{
                    if let obj = ContactResponse(JSON:i) {
                        self.blackListNumberArray.append(obj)
                    }
                }
            }
            
            print("BlackList array from user defaults : ",self.blackListNumberArray.toJSON())
        }
        
        //=========
        let results = self.resultsController.fetchedObjects
        
        for i in 0..<results!.count {
            autoreleasepool{
                let indexPath = IndexPath(item: i, section: 0)
                let caller = self.resultsController.object(at: indexPath)
                
                //            let phonenumber = "\(caller.number)"
                //            let phonenumberInt = Int64(phonenumber.suffix(10)) ?? 0
                
                //            if self.blackListNumberArray.contains(where: { $0.number != Int64(phonenumberInt)}){
                if self.blackListNumberArray.contains(where: { $0.number != caller.number}){
                    
                    caller.isRemoved = true
                    //            caller.isBlocked = false
                    caller.updatedDate = Date()
                    self.callerData.saveContext()
                }
                else{
                    //                print("phonenumberInt : ", phonenumberInt)
                    //                let num = Int64("\(CountryCode)"+"\(phonenumberInt)")
                    
                    caller.name = caller.name
                    //                caller.number  = num ?? 0
                    caller.number = caller.number
                    caller.isBlocked = true
                    caller.isRemoved = true
                    caller.updatedDate = Date()
                    self.callerData.saveContext()
                }
            }
        }
        self.reload()
        
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
        self.view.endEditing(true)
        Utility.showIndecator()
        let url = "\(getMaxBlockingURL)?page=\(page)"
        ServeyServices.shared.max_blocking(url:url,success: {  (statusCode, response) in
            
            if let metaRes = response?.metaResponse{
                self.meta = metaRes
            }
            
            if (response?.maxBlockingResponse) != nil{
                print("Api response at : ", Date())
                if self.meta?.lastPage ?? 0 >= self.meta?.currentPage ?? 0{
                    self.blockNumberArray = response?.maxBlockingResponse ?? []
//                    self.blockNumberArray = self.blockNumberArray.sorted(by: { $0.phone ?? "" > $1.phone ?? "" })
                    self.goFurthermax_blockingAPI(isWarning: isWarning)
                    
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
    
    func goFurthermax_blockingAPI(isWarning: Bool){
        
        //        print("==== Start blocking ====")
        print("Start blocking at : ", Date())
        
        //=== Before
        
        for i in 0..<self.blockNumberArray.count {
            autoreleasepool {
                let contact = self.blockNumberArray[i]
                if isWarning{
                    self.warningNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0)
                }
                else{
                    autoreleasepool {
                        //                let phonenumber = contact.phone ?? "0"
                        //                let phonenumberInt = Int(phonenumber.suffix(10))
                        //                print("phonenumberInt : ", phonenumberInt ?? "")
                        
                        if !self.blockedArray.contains(Int64(contact.phone ?? "0") ?? 0){
                            self.blockNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0 )
                        }
                    }
                }
            }
        }
        
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
        
        retiveblockNumber()
        
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
                
                if !self.blockedArray.contains(Int64(contact.phone ?? "0") ?? 0){
                    self.blockNumber(nameString: contact.context ?? "" , number: Int64(contact.phone ?? "0") ?? 0)
                }
            }
        }
        
        retiveblockNumber()
        
        let currentPage = self.meta?.currentPage ?? 0
        self.page = currentPage + 1
        self.getSpamsAPI(pageINT: self.page)
        
    }
}

