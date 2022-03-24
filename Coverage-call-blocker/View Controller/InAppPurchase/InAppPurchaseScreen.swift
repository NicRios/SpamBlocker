//
//  InAppPurchaseScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 08/10/21.
//

import UIKit

class InAppPurchaseScreen: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var isFlagRestore: Bool = false
    var expiryDate: String = ""
    
    var isFromHomeScreen: Bool = false
    
    var selectedPlan: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpIntialView()
        
        getInfo(Product.monthly.rawValue)
    }
    
    func setUpIntialView(){
        self.view.backgroundColor = appBackgroundColor
        
        backButton.isHidden = !isFromHomeScreen
        skipButton.isHidden = isFromHomeScreen
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        mainCollectionView.register(UINib(nibName: "InAppPurchaseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InAppPurchaseCollectionViewCell")
        
    }
    
    //MARK: - button clicked event
    
    @IBAction func onSkip(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let vc =  STORYBOARD.login.instantiateViewController(withIdentifier: "SignupCompleteScreen") as! SignupCompleteScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onContinue(_ sender: UIButton) {

        if selectedPlan == "month"{
            purchase(Product.monthly.rawValue, atomically: true)
            Utility.showIndecator()
        }
        else if selectedPlan == "year"{
            purchase(Product.yearly.rawValue, atomically: true)
            Utility.showIndecator()
        }
        else{
            self.view.makeToast("Plase select any plan.")
        }
    }
}

//MARK: - Deal CollectionView DataSource and Delegate Methods
extension InAppPurchaseScreen:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InAppPurchaseCollectionViewCell", for: indexPath) as? InAppPurchaseCollectionViewCell ?? Bundle.main.loadNibNamed("InAppPurchaseCollectionViewCell", owner: self, options: nil)![0] as! InAppPurchaseCollectionViewCell
        
        cell.selectedImageView.isHidden = true
        
        if indexPath.row == 0{
            cell.priceLabel.text = "$0.99/month"
            
            if selectedPlan == "month"{
                cell.selectedImageView.isHidden = false
            }
            else{
                cell.selectedImageView.isHidden = true
            }
        }
        else{
            cell.priceLabel.text = "$9.99/year"
            
            if selectedPlan == "year"{
                cell.selectedImageView.isHidden = false
            }
            else{
                cell.selectedImageView.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            selectedPlan = "month"
        }
        else{
            selectedPlan = "year"
        }
        
        mainCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width/2), height: (collectionView.frame.height))
    }
}

extension InAppPurchaseScreen{
    
    //MARK: - subscription API
    
    func subscriptionAPI(receiptString: String, transactIdString: String ){
        self.view.endEditing(true)
        Utility.showIndecator()
        let data = SubscribeRequest(receipt: receiptString, transactId: transactIdString)
        SubscriptionServices.shared.subscriptionAPI(parameters: data.toJSON()) { [weak self] (statusCode, response) in
            Utility.hideIndicator()
            print("response: ", response.toJSON())
            self?.goFurther(message: response.message ?? "")
        } failure: { [weak self] (error) in
            Utility.hideIndicator()
            guard let stronSelf = self else { return }
            Utility.showAlert(vc: stronSelf, message: error)
        }
    }
    
    func goFurther(message: String){
        let alert = UIAlertController(title: APPLICATION_NAME, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
