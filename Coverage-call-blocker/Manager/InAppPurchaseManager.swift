//
//  InAppPurchaseManager.swift
//  Coverage-call-blocker
//
//  Created by iroid on 08/10/21.
//

import Foundation
import UIKit
import SwiftyStoreKit
import StoreKit

var storeKitSharedSecret = "1cb64f2e656c459c881d3cf74968a658"
var transactionId: String = ""

enum Product: String, CaseIterable{
    case monthly = "com.coveragecallblocker.month"
    case yearly = "com.coveragecallblocker.yearly"
//    case onetime = "com.ivideo.onetime"
}
func returnProductIDs() -> [String]? {
    return [Product.monthly.rawValue,Product.yearly.rawValue]//,Product.onetime.rawValue
}
class NetworkActivityIndicatorManager: NSObject {

    private static var loadingCount = 0

    class func networkOperationStarted() {

        #if os(iOS)
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
        #endif
    }

    class func networkOperationFinished() {
        #if os(iOS)
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        #endif
    }
}
//
//MARK:- In App Purchases
//

 extension InAppPurchaseScreen {

    func getInfo(_ productId:String) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            print(result)
            guard let product = result.retrievedProducts.first else {return}
            if productId == Product.monthly.rawValue {
//                monthlyPrice = product.localizedPrice ?? ""
//                print(monthlyPrice)
                print(product.localizedPrice ?? "")
            }
            else if productId == Product.yearly.rawValue{
//                yearlyPrice = product.localizedPrice ?? ""
//                print(yearlyPrice)
                print(product.localizedPrice ?? "")
            }
//            else if productId == Product.onetime.rawValue {
//                oneTimePrice = product.localizedPrice ?? ""
//                print(oneTimePrice)
//            }
//            self.buttonPriceDisplay()
        }
    }
    
    func purchase(_ productId:String, atomically: Bool) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(productId, atomically: atomically) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }
    
//    func restorePurchases() {
//
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        SwiftyStoreKit.restorePurchases(atomically: true) { results in
//            NetworkActivityIndicatorManager.networkOperationFinished()
//            for purchase in results.restoredPurchases {
//                let downloads = purchase.transaction.downloads
//                if !downloads.isEmpty {
//                    SwiftyStoreKit.start(downloads)
//                } else if purchase.needsFinishTransaction {
//                    // Deliver content from server, then:
//                    SwiftyStoreKit.finishTransaction(purchase.transaction)
//                }
//            }
//            self.showAlert(self.alertForRestorePurchases(results))
//        }
//    }
    
    func verifyReceipt() {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.showAlert(self.alertForVerifyReceipt(result))
        }
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
            var serverType = AppleReceiptValidator.VerifyReceiptURLType.production//= : VerifyReceiptURLType = //.production
            #if DEBUG
            serverType = AppleReceiptValidator.VerifyReceiptURLType.sandbox
            #else
            serverType = AppleReceiptValidator.VerifyReceiptURLType.production
            #endif
            let appleValidator = AppleReceiptValidator(service: serverType, sharedSecret: storeKitSharedSecret)
            SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
                switch result {
                case .success(let receipt):
                    if let pendingRenewalArray = receipt["pending_renewal_info"] as? NSArray{
                        let dictionary = pendingRenewalArray.object(at: 0) as? NSDictionary ?? [:]
                        let productId = dictionary["product_id"] as? String ?? ""
                        print("productId : ", productId)
                        let string = dictionary.object(forKey: "auto_renew_status") as? String ?? ""
                        if (string == "1") {
                            let purchaseDateArray = receipt["latest_receipt_info"] as? NSArray ?? []
                            let purchaseDateDictionary = purchaseDateArray.object(at: 0) as? NSDictionary ?? [:]
                            let purchaseDateLastDictionary = purchaseDateArray.object(at: purchaseDateArray.count - 1) as? NSDictionary ?? [:]
                            print(purchaseDateLastDictionary)
                            let transactionId = purchaseDateDictionary.object(forKey: "transaction_id")! as? String ?? ""
                            let latestReceipt = receipt["latest_receipt"] as? String ?? ""
                            
                            print("latestReceipt : ", latestReceipt)
                            
                            self.subscriptionAPI(receiptString: latestReceipt, transactIdString: transactionId)
                            
                        }else{
                            Utility.hideIndicator()
                            Utility.showAlert(vc: self, message: "It seems your subscription is expired or is not active.")
                        }
                    }
                    print("Verify receipt success: \(receipt)")
                case .error(let error):
                    print("Verify receipt failed: \(error)")
                }
            }
        }
    
//    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: storeKitSharedSecret)
//        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
//
////        #if DEBUG
////            let appleValidator = AppleReceiptValidator(service: .sandbox, sharedSecret: storeKitSharedSecret)
////            SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
////        #else
////            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: storeKitSharedSecret)
////            SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
////        #endif
//    }
    
    func verifyPurchase(_ productId:String) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                
//                let purchaseResult = SwiftyStoreKit.verifyPurchase(
//                    productId: productId,
//                    inReceipt: receipt)
//                self.showAlert(self.alertForVerifyPurchase(purchaseResult, productId: productId))
                
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                self.showAlert(self.alertForVerifySubscriptions(purchaseResult, productIds: [productId]))
            
            //                switch purchase {
            //                            case .autoRenewableWeekly, .autoRenewableYearly:
            //                                let purchaseResult = SwiftyStoreKit.verifySubscription(
            //                                    ofType: .autoRenewable,
            //                                    productId: productId,
            //                                    inReceipt: receipt)
            //                                self.showAlert(self.alertForVerifySubscriptions(purchaseResult, productIds: [productId]))
            //                            case .nonRenewingPurchase:
            //                                let purchaseResult = SwiftyStoreKit.verifySubscription(
            //                                    ofType: .nonRenewing(validDuration: 60),
            //                                    productId: productId,
            //                                    inReceipt: receipt)
            //                                self.showAlert(self.alertForVerifySubscriptions(purchaseResult, productIds: [productId]))
            //                            default:
            //                                let purchaseResult = SwiftyStoreKit.verifyPurchase(
            //                                    productId: productId,
            //                                    inReceipt: receipt)
            //                                self.showAlert(self.alertForVerifyPurchase(purchaseResult, productId: productId))
            //                            }
            //
            case .error:
                self.showAlert(self.alertForVerifyReceipt(result))
            }
        }
    }
    
//    func verifySubscriptions(_ products:[String]) {
//        NetworkActivityIndicatorManager.networkOperationStarted()
//        verifyReceipt { result in
//            NetworkActivityIndicatorManager.networkOperationFinished()
//
//            switch result {
//            case .success(let receipt):
//                let productIds = Set(products)
//                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
//                self.showAlert(self.alertForVerifySubscriptions(purchaseResult, productIds: productIds))
//            case .error:
//                self.showAlert(self.alertForVerifyReceipt(result))
//            }
//        }
//    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.popoverPresentationController?.sourceView = self.view
                self.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)//self.view.bounds
                self.popoverPresentationController?.permittedArrowDirections = [.down, .up]
            }
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            if self.isFlagRestore{
//                UserDefaults.standard.set(true, forKey: "inAppPurchase")
                let data = Utility.getUserData()
                data?.isPremium = 1
                if let data1 = data{
                    Utility.saveUserData(data: data1.toJSON())
                }
                
            }
        }))
        return alert
    }
    
//    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
//
//        if let product = result.retrievedProducts.first {
//            let priceString = product.localizedPrice!
//            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
//        } else if let invalidProductId = result.invalidProductIDs.first {
//            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
//        } else {
//            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
//            return alertWithTitle("Could not retrieve product info", message: errorString)
//        }
//    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        Utility.hideIndicator()
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            transactionId = purchase.transaction.transactionIdentifier ?? ""
            print("transactionId : ", transactionId)
//            UserDefaults.standard.set(true, forKey: "inAppPurchase")
            Utility.showIndecator()
            self.verifyReceipt()
            self.verifyPurchase(Product.monthly.rawValue)
//            InAppPurchase.sharedInstance.receiptValidation()
                        
            let data = Utility.getUserData()
            data?.isPremium = 1
            if let data1 = data{
                Utility.saveUserData(data: data1.toJSON())
            }
           
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
//            UserDefaults.standard.set(false, forKey: "inAppPurchase")
            let data = Utility.getUserData()
            data?.isPremium = 0
            if let data1 = data{
                Utility.saveUserData(data: data1.toJSON())
            }
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            default:
                return alertWithTitle("Purchase failed", message: (error as NSError).localizedDescription)
            }
        }
    }
    
//    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
//
//        if results.restoreFailedPurchases.count > 0 {
//            print("Restore Failed: \(results.restoreFailedPurchases)")
//            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
//        } else if results.restoredPurchases.count > 0 {
//            print("Restore Success: \(results.restoredPurchases)")
//            isFlagRestore = true
//            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
//        } else {
//            print("Nothing to Restore")
//            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
//        }
//    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate, let items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            print("expiryDate : ", expiryDate)
            self.expiryDate = "\(expiryDate)"
//            self.receiptValidationWithAPI()
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
//    func alertForVerifyPurchase(_ result: VerifyPurchaseResult, productId: String) -> UIAlertController {
//
//        switch result {
//        case .purchased:
//            print("\(productId) is purchased")
//            return alertWithTitle("Product is purchased", message: "Product will not expire")
//        case .notPurchased:
//            print("\(productId) has never been purchased")
//            return alertWithTitle("Not purchased", message: "This product has never been purchased")
//        }
//    }
    
//    func receiptValidationWithAPI() {
//
//        let receiptURL: URL? = Bundle.main.appStoreReceiptURL
//        var receipt: Data? = nil
//        if let receiptURLS = receiptURL {
//            do {
//                receipt = try Data(contentsOf: receiptURLS)
//            }catch let err as Error{
//                print(err)
//                return
//            }
//        }
//
//        let payload = "{\"receipt-data\" : \"\(receipt?.base64EncodedString(options: []) ?? "")\", \"password\" : \"\(storeKitSharedSecret)\"}"
//
//        print("payload : ", payload)
//
//        userForMembershipAPI(transactionId: transactionId, receipt: "\(receipt?.base64EncodedString(options: []) ?? "")", expiryDate: self.expiryDate)
//    }
    
}
extension AppDelegate {
    func setupInAppPurchase() {

        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in

            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
//                        UserDefaults.standard.set(true, forKey: "inAppPurchase")
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in

            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
}

