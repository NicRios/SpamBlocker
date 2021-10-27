//
//  InAppPurchaseScreen.swift
//  Coverage-call-blocker
//
//  Created by iroid on 08/10/21.
//

import UIKit

class InAppPurchaseScreen: UIViewController {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
//    var dealResourceArray:[DealResourceResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpIntialView()
    }
    
    func setUpIntialView(){
        self.view.backgroundColor = appBackgroundColor
        
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
        self.view.makeToast("This module is under development")
    }
}

//MARK: - Deal CollectionView DataSource and Delegate Methods
extension InAppPurchaseScreen:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        var numOfSections: Int = 0
//
//        if dealResourceArray.count > 0 {
//            numOfSections = 1
//            collectionView.backgroundView = nil
//        } else {
//            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
//            noDataLabel.text = "No Deals Found"
//            noDataLabel.textColor = UIColor.darkGray
//            noDataLabel.textAlignment = .center
//            noDataLabel.numberOfLines = 1
//            collectionView.backgroundView = noDataLabel
//        }
//
//        return numOfSections
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InAppPurchaseCollectionViewCell", for: indexPath) as? InAppPurchaseCollectionViewCell ?? Bundle.main.loadNibNamed("InAppPurchaseCollectionViewCell", owner: self, options: nil)![0] as! InAppPurchaseCollectionViewCell
//        cell.item = dealResourceArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width/2), height: (collectionView.frame.height))
    }
}
