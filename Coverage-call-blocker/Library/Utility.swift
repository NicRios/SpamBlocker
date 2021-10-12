//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import UIKit
//import Toaster
import AVFoundation
import CoreLocation
import SDWebImage
import AVKit
import SVProgressHUD
//import JGProgressHUD

class Utility: NSObject {
    
    class func convertIntoDate(dateInRowForamt:Int, dateFormat:String) -> String {
        guard dateInRowForamt != 0 else { return "No Date" }
        //        let valueWithZero = Int(String(dateInRowForamt)+"000")!
        //        let epocTime = TimeInterval(valueWithZero) / 1000
        //        let myDate = Date(timeIntervalSince1970: epocTime)
        //        print(myDate)
        
        let expiredTime = dateInRowForamt
        let myDate = Date(timeIntervalSince1970: TimeInterval(expiredTime))
        print("myDate : ", myDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from:myDate)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = dateFormat
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        let dateInString = formatter.string(from: yourDate!)
        
        return dateInString
    }
    
    class func showAlert(vc: UIViewController, message: String) {
        let alertController = UIAlertController(title: APPLICATION_NAME, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title:  "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func showActionAlert(vc: UIViewController,message: String)
    {
        
        let alertController = UIAlertController(title: APPLICATION_NAME, message: message, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
    
    class func showNoInternetConnectionAlertDialog(vc: UIViewController) {
        
        let alertController = UIAlertController(title: APPLICATION_NAME, message: "It seems you are not connected to the internet. Kindly connect and try again", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: /*Utility.getLocalizdString(value: */"OK"/*)*/, style: .default, handler: nil)
        alertController.addAction(OKAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    class func showAlertSomethingWentWrong(vc: UIViewController) {
        let alertController = UIAlertController(title: APPLICATION_NAME, message: "Oops! Something went wrong. Kindly try again later", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    
    class func encode(_ s: String) -> String {
        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
        return String(data: data, encoding: .utf8)!
    }
    
    class func decode(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
    
    
    class func getTime(date:String) -> String{
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let postDate = formatter.date(from: date)!
        let timeFromNow = currentDate.offset(from: postDate)
        return timeFromNow
    }
    
    class func getLabelHeight(label:UILabel) -> (Int,Int){
        var lineCount = 0
        let textSize = CGSize(width: label.frame.size.width, height: CGFloat(MAXFLOAT))
        let rHeight = lroundf(Float(label.sizeThatFits(textSize).height))
        let charSize = lroundf(Float(label.font.lineHeight))
        lineCount = rHeight / charSize
        return (lineCount,rHeight)
    }
    
    class func checkForEmptyString(valueString: String) -> Bool {
        if valueString.isEmpty {
            return true
        }else{
            return false
        }
    }
    
    //    class func getCurrentUserId() -> String {
    //        let userDictionary = (UserDefaults.standard.object(forKey: USER_DETAILS) as? NSDictionary)!
    //        return userDictionary.object(forKey: USER_ID) as! String
    //        //        return "1"
    //    }
    
    //    class func getCurrentUserProfilePicture() -> String {
    //        let userDictionary = (UserDefaults.standard.object(forKey: USER_DETAILS) as? NSMutableDictionary)!
    //        return userDictionary.object(forKey: PROFILE_PIC) as! String
    //    }
    
    class func showIndecator() {
        //        //         AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = false
        //        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //        //        if  UserDefaults.standard.string(forKey: LANGUAGE) == ARABIC_LANG_CODE{
        //        //            SwiftLoader.show(title: "جار التحميل...", animated: true)
        //        //        }else{
        //        SwiftLoader.show(title: "Loading...", animated: true)
        //        //        }
        
        DispatchQueue.main.async {
            //                SVProgressHUD.show(withStatus: "Loading...")
            //                SVProgressHUD.showInfo(withStatus: "miraj")
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.setForegroundColor(UIColor.white)
            SVProgressHUD.setBackgroundColor(UIColor.darkGray)
            SVProgressHUD.show()
        }
        
    }
    
    class func hideIndicator() {
        //        //        AppDelegate().sharedDelegate().window?.isUserInteractionEnabled = true
        //        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        //        SwiftLoader.hide()
        
        SVProgressHUD.dismiss()
    }
    
    //MARK: reachability
    //    class func isInternetAvailable() -> Bool
    //    {
    //        var  isAvailable : Bool
    //        isAvailable = true
    //        let reachability = Reachability()!
    //        if(reachability.connection == .none)
    //        {
    //            isAvailable = false
    //        }
    //        else
    //        {
    //            isAvailable = true
    //        }
    //
    //        return isAvailable
    //
    //    }
    
    class func getCurrentLanguage() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: "AppleLanguages") as! NSArray
        let current = langArray.firstObject as! String
        return current
    }
    class func setLanguage(langStr:String){
        let defaults = UserDefaults.standard
        defaults.set([langStr], forKey: "AppleLanguages")
        defaults.synchronize()
        Bundle.setLanguage(langStr)
    }
    
    class func setLocalizedValuesforView(parentview: UIView ,isSubViews : Bool)
    {
        if parentview is UILabel {
            let label = parentview as! UILabel
            let titleLabel = label.text
            if titleLabel != nil {
                label.text = self.getLocalizdString(value: titleLabel!)
            }
        }
        else if parentview is UIButton {
            let button = parentview as! UIButton
            let titleLabel = button.title(for:.normal)
            if titleLabel != nil {
                button.setTitle(self.getLocalizdString(value: titleLabel!), for: .normal)
            }
        }
        else if parentview is UITextField {
            let textfield = parentview as! UITextField
            let titleLabel = textfield.text!
            if(titleLabel == "")
            {
                let placeholdetText = textfield.placeholder
                if(placeholdetText != nil)
                {
                    textfield.placeholder = self.getLocalizdString(value:placeholdetText!)
                }
                
                return
            }
            textfield.text = self.getLocalizdString(value:titleLabel)
        }
        else if parentview is UITextView {
            let textview = parentview as! UITextView
            let titleLabel = textview.text!
            textview.text = self.getLocalizdString(value:titleLabel)
        }
        if(isSubViews)
        {
            for view in parentview.subviews {
                self.setLocalizedValuesforView(parentview:view, isSubViews: true)
            }
        }
    }
    
    class func getLocalizdString(value: String) -> String
    {
        var str = ""
        let language = self.getCurrentLanguage()
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        if(path != nil)
        {
            let languageBundle = Bundle(path:path!)
            str = NSLocalizedString(value, tableName: nil, bundle: languageBundle!, value: value, comment: "")
        }
        return str
    }
    
    //    class func isUserAlreadyLogin() -> Bool
    //    {
    //        var  isLogin : Bool
    //        isLogin = false
    //        if (UserDefaults.standard.object(forKey: IS_LOGIN) != nil) {
    //            let isUserLogin = (UserDefaults.standard.object(forKey: IS_LOGIN) as? String)!
    //            if (isUserLogin=="1") {
    //                isLogin = true
    //            }
    //        }
    //        return isLogin
    //
    //    }
    //
    //    class func getUserTokenKey() -> String {
    //        let userDictionary = (UserDefaults.standard.object(forKey: USER_DETAILS) as? NSDictionary)!
    //
    //        return userDictionary.object(forKey: ACCESS_TOKEN) as! String
    //    }
    
    
    //    func AddSubViewtoParentView(parentview: UIView! , subview: UIView!)
    //    {
    //        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
    //        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
    //        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
    //        parentview.addConstraint(NSLayoutConstraint(item: subview, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parentview, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
    //        parentview.layoutIfNeeded()
    //
    //    }
    
    //    class func decorateTags(_ stringWithTags: String?) -> NSMutableAttributedString? {
    //        var error: Error? = nil
    //        //For "Vijay #Apple Dev"
    //        var regex: NSRegularExpression? = nil
    //        do {
    //            regex = try NSRegularExpression(pattern: "#(\\w+)", options: [])
    //        } catch {
    //        }
    //        //For "Vijay @Apple Dev"
    //        //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&error];
    //        let matches = regex?.matches(in: stringWithTags ?? "", options: [], range: NSRange(location: 0, length: stringWithTags?.count ?? 0))
    //        var attString = NSMutableAttributedString(string: stringWithTags ?? "")
    //
    //        let stringLength = stringWithTags?.count ?? 0
    //        for match in matches! {
    //            let wordRange = match.range(at: 0)
    //            let word = (stringWithTags as NSString?)?.substring(with: wordRange)
    //
    //            let foregroundColor = Utility.getUIcolorfromHex(hex: "5527BD")
    //            attString.addAttribute(.foregroundColor, value: foregroundColor, range: wordRange)
    //
    //            print("Found tag \(word ?? "")")
    //        }
    //        return attString
    //    }
    
    class func getUIcolorfromHex(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //    class func MD5(_ string: String) -> String? {
    //        let length = Int(CC_MD5_DIGEST_LENGTH)
    //        var digest = [UInt8](repeating: 0, count: length)
    //        if let d = string.data(using: String.Encoding.utf8) {
    //            d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
    //                CC_MD5(body, CC_LONG(d.count), &digest)
    //            }
    //        }
    //        return (0..<length).reduce("") {
    //            $0 + String(format: "%02x", digest[$1])
    //        }
    //    }
    class  func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "HH:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    class func utcToLocalForTimer(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"    //"H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"    //"h:mm a"
            
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    class func utcToLocalForTimerBidding(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"    //"H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "HH:mm:ss"    //"h:mm a"
            
            return dateFormatter.string(from: date)
        }
        return nil
    }
    //    class func getSecretValueFromTwoString(emailid: String, password: String) -> String{
    //        let remail = String(emailid.reversed())
    //        let rpassword = String(password.reversed())
    //        let finalString = remail + rpassword
    //
    //        return self.MD5(finalString)!
    //    }
    
    //    class func getCompressImageData(_ originalImage: UIImage?) -> Data?
    //    {
    //        let imageData = originalImage?.lowestQualityJPEGNSData
    //        print(imageData)
    //        return imageData as! Data
    //    }
    //    class func getCompressImageData(_ originalImage: UIImage?) -> Data? {
    //        // UIImage *largeImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //        let largeImage: UIImage? = originalImage
    //
    //        var compressionRatio: Double = 1
    //        var resizeAttempts: Int = 3
    ////        var imgData = UIImageJPEGRepresentation(largeImage!, CGFloat(compressionRatio))
    //        var imgData = largeImage!.jpegData(compressionQuality: CGFloat(compressionRatio))
    //        print(String(format: "Starting Size: %lu", UInt(imgData?.count ?? 0)))
    //
    //        if (imgData?.count)! > 1000000 {
    //            resizeAttempts = 4
    //        } else if (imgData?.count)! > 400000 && (imgData?.count)! <= 1000000 {
    //            resizeAttempts = 2
    //        } else if (imgData?.count)! > 100000 && (imgData?.count)! <= 400000 {
    //            resizeAttempts = 2
    //        } else if (imgData?.count)! > 40000 && (imgData?.count)! <= 100000 {
    //            resizeAttempts = 1
    //        } else if (imgData?.count)! > 10000 && (imgData?.count)! <= 40000 {
    //            resizeAttempts = 1
    //        }
    //
    //        print("resizeAttempts \(resizeAttempts)")
    //
    //        while resizeAttempts > 0 {
    //            resizeAttempts -= 1
    //            print("Image was bigger than 400000 Bytes. Resizing.")
    //            print(String(format: "%i Attempts Remaining", resizeAttempts))
    //            compressionRatio = compressionRatio * 0.6
    //            print("compressionRatio \(compressionRatio)")
    //            print(String(format: "Current Size: %lu", UInt(imgData?.count ?? 0)))
    ////            imgData = UIImageJPEGRepresentation(largeImage!, CGFloat(compressionRatio))
    //            imgData = largeImage!.jpegData(compressionQuality: CGFloat(compressionRatio))
    //            print(String(format: "New Size: %lu", UInt(imgData?.count ?? 0)))
    //        }
    //
    //        //Set image by comprssed version
    //        let savedImage = UIImage(data: imgData!)
    //
    //        //Check how big the image is now its been compressed and put into the UIImageView
    //        // *** I made Change here, you were again storing it with Highest Resolution ***
    //
    ////        var endData = UIImageJPEGRepresentation(savedImage!, CGFloat(compressionRatio))
    //        var endData = savedImage!.jpegData(compressionQuality: CGFloat(compressionRatio))
    //        //NSData *endData = UIImagePNGRepresentation(savedImage);
    //
    //        print(String(format: "Ending Size: %lu", UInt(endData?.count ?? 0)))
    //
    //        return endData
    //    }
    
    class func setImage(_ imageUrl: String!, imageView: UIImageView!) {
        if imageUrl != nil && !(imageUrl == "") {
            imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            //            imageView.sd_setShowActivityIndicatorView(true)
            //            imageView.sd_setIndicatorStyle(.gray)
            imageView!.sd_setImage(with: URL(string: imageUrl! ), placeholderImage: UIImage(named: "place_holder_image.png"))
        }
        else
        {
            imageView?.image = UIImage(named: "post_placeholder.png")
        }
    }
    
    class func silentModeSoundOn(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
        }
    }
    class func setMonth(strMonth: String) -> String
    {
        let strMonth=strMonth.lowercased();
        var strSpanishMonth = "" ;
        if strMonth == ("january") || strMonth == "enero" {
            strSpanishMonth="Enero"
        }
        else if strMonth == "february" || strMonth == "febrero" {
            strSpanishMonth="Febrero"
        }
        else if strMonth == "march" || strMonth == "marzo" {
            strSpanishMonth="Marzo"
        }
        else if strMonth == "april" || strMonth == "abril" {
            strSpanishMonth="Abril"
        }
        else if strMonth == "may" || strMonth == "mayo" {
            strSpanishMonth="Mayo"
        }
        else if strMonth == "june" || strMonth == "junio" {
            strSpanishMonth="Junio"
        }
        else if strMonth == "july" || strMonth == "julio" {
            strSpanishMonth="Junio"
        }
        else if strMonth == "august" || strMonth == "agosto" {
            strSpanishMonth="Agosto"
        }
        else if strMonth == "september" || strMonth == "septiembre" {
            strSpanishMonth="Septiembre"
        }
        else if strMonth == "october" || strMonth == "octubre" {
            strSpanishMonth="Octubre"
        }
        else if strMonth == "november" || strMonth == "noviembre" {
            strSpanishMonth="Noviembre"
        }
        else {
            strSpanishMonth = "Diciembre";
        }
        return strSpanishMonth;
    }
    
    class func setDay(strDay: String) -> String
    {
        let strDay=strDay.lowercased();
        var strEnglishDay = "" ;
        if strDay == "monday" {
            strEnglishDay="Monday"
        }
        else if strDay == "tuesday" {
            strEnglishDay="Tuesday"
        }
        else if strDay == "wednesday" {
            strEnglishDay="Wednesday"
        }
        else if strDay == "thursday" {
            strEnglishDay="Thursday"
        }
        else if strDay == "friday" {
            strEnglishDay="Friday"
        }
        else if strDay == "saturday" {
            strEnglishDay="Saturday"
        }
        else {
            strEnglishDay="Sunday"
        }
        return strEnglishDay;
    }
    
    //    class func formattedDateFromString(dateString: String, withFormat format: String) -> String? {
    //        let inputFormatter = DateFormatter()
    //        inputFormatter.dateFormat = SERVER_DATE_FORMATE
    //        inputFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
    //
    //        if let date = inputFormatter.date(from: dateString) {
    //            let outputFormatter = DateFormatter()
    //            outputFormatter.dateFormat = format
    //            outputFormatter.timeZone = NSTimeZone.local
    //
    //            return outputFormatter.string(from: date)
    //        }
    //        return nil
    //    }
    
    class func addSuperScriptToLabel(label: UILabel, superScriptCount count: Int, fontSize size: CGFloat) {
        let font:UIFont? = UIFont(name: label.font!.fontName, size:size)
        let fontSuper:UIFont? = UIFont(name: label.font!.fontName, size:size/1.5)
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: label.text!, attributes: [.font:font!])
        attString.setAttributes([.font:fontSuper!,.baselineOffset:10], range: NSRange(location:((label.text?.count)!-count),length:count))
        label.attributedText = attString
    }
    
    //    class func getNumberOfItemInCart() -> String? {
    //
    //        if(UserDefaults.standard.object(forKey: CART_PRODUCTS) != nil ){
    //            let cartArray = UserDefaults.standard.object(forKey: CART_PRODUCTS) as! NSArray
    //           return String(cartArray.count)
    //
    //        }
    //        return "0"
    //    }
    //
    class func getCurrentLocalTime(format: String) -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter.string(from: now)
    }
    
    class func makeBlueBorderToTextField(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1)
        border.borderColor = #colorLiteral(red: 0, green: 0.6509803922, blue: 1, alpha: 1)
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width , height: 1)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    class func makeGrayBorderToTextField(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1)
        border.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: 1)
        border.borderWidth = textField.frame.size.width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    class func makeClearBorderToTextField(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1)
        border.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width: textField.frame.size.width, height: 1)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    class func addBorderToView(view: UIView, color: UIColor,value: CGFloat){
        view.layer.borderWidth = value
        view.layer.borderColor = color.cgColor
    }
    
    class func getTimeInterval(fromDate timeImterval: Int) -> String? {
        var timeIntervalString = ""
        var timeDifference: Int = timeImterval / 86400
        timeIntervalString = "\(timeDifference)d"
        print("timeIntervalString \(timeIntervalString)")
        if timeDifference < 1 {
            timeDifference = timeImterval / 3600
            timeIntervalString = "\(timeDifference)h"
            print("timeIntervalString \(timeIntervalString)")
            if timeDifference < 1 {
                timeDifference = timeImterval / 60
                timeIntervalString = "\(timeDifference)m"
                print("timeIntervalString \(timeIntervalString)")
                if timeDifference < 1 {
                    timeIntervalString = "\(timeImterval)s"
                    print("timeIntervalString \(timeIntervalString)")
                }
            }
        }
        print("timeIntervalString \(timeIntervalString)")
        return timeIntervalString
    }
    class func getSameDate(as itemString: String?, havingDateFormatter dateFormatter: DateFormatter?) -> Date? {
        let twentyFour = NSLocale(localeIdentifier: "en_GB")
        dateFormatter?.locale = twentyFour as Locale
        let dateString = getGlobalTimeAsDate(fromDate: itemString, andWithFormat: dateFormatter)
        return dateString
    }
    class func getGlobalTimeAsDate(fromDate date: String?, andWithFormat dateFormatter: DateFormatter?) -> Date? {
        dateFormatter?.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        return dateFormatter?.date(from: date ?? "")
    }
    class func videoSnapshot(url: NSString) -> UIImage? {
        
        //let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let vidURL = NSURL(string: url as String)
        let asset = AVURLAsset(url: vidURL! as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    class func getEncodeString(strig: String) -> String {
        let utf8str = strig.data(using: String.Encoding.utf8)
        let base64Encoded = utf8str?.base64EncodedData()
        
        let base64Decoded = NSString(data: base64Encoded!, encoding: String.Encoding.utf8.rawValue)
        
        return base64Decoded! as String
    }
    
    class func getDecodedString(encodedString: String) -> String {
        if(Data(base64Encoded: encodedString) != nil)
        {
            let decodedData = Data(base64Encoded: encodedString)!
            let decodedString = String(data:decodedData, encoding: .utf8)!
            
            return decodedString
        }
        return encodedString
    }
    
    class func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")
        
        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }
        
        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }
        
        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
            
        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d{4})", with: "($1)$2-$3", options: .regularExpression, range: range)
        }
        
        return number
    }
    class func isValidZipCode(zipCode:String) -> Bool
    {
        //        let zipCodeRegExArray = ["^\\d{5}([\\-]?\\d{4})?$","^(GIR|[A-Z]\\d[A-Z\\d]??|[A-Z]{2}\\d[A-Z\\d]??)[ ]??(\\d[A-Z]{2})$","\\b((?:0[1-46-9]\\d{3})|(?:[1-357-9]\\d{4})|(?:[4][0-24-9]\\d{3})|(?:[6][013-9]\\d{3}))\\b","^([ABCEGHJKLMNPRSTVXY]\\d[ABCEGHJKLMNPRSTVWXYZ])\\{0,1}(\\d[ABCEGHJKLMNPRSTVWXYZ]\\d)$","^(F-)?((2[A|B])|[0-9]{2})[0-9]{3}$","^(V-|I-)?[0-9]{5}$","^(0[289][0-9]{2})|([1345689][0-9]{3})|(2[0-8][0-9]{2})|(290[0-9])|(291[0-4])|(7[0-4][0-9]{2})|(7[8-9][0-9]{2})$","^[1-9][0-9]{3}\\s?([a-zA-Z]{2})?$","^([1-9]{2}|[0-9][1-9]|[1-9][0-9])[0-9]{3}$","^([D|d][K|k]( |-))?[1-9]{1}[0-9]{3}$","^(s-|S-){0,1}[0-9]{3}\\s?[0-9]{2}$","^[1-9]{1}[0-9]{3}$","^\\d{6}$","^2899$"]
        let zipCodeRegExArray = ["^GIR[ ]?0AA|((AB|AL|B|BA|BB|BD|BH|BL|BN|BR|BS|BT|CA|CB|CF|CH|CM|CO|CR|CT|CV|CW|DA|DD|DE|DG|DH|DL|DN|DT|DY|E|EC|EH|EN|EX|FK|FY|G|GL|GY|GU|HA|HD|HG|HP|HR|HS|HU|HX|IG|IM|IP|IV|JE|KA|KT|KW|KY|L|LA|LD|LE|LL|LN|LS|LU|M|ME|MK|ML|N|NE|NG|NN|NP|NR|NW|OL|OX|PA|PE|PH|PL|PO|PR|RG|RH|RM|S|SA|SE|SG|SK|SL|SM|SN|SO|SP|SR|SS|ST|SW|SY|TA|TD|TF|TN|TQ|TR|TS|TW|UB|W|WA|WC|WD|WF|WN|WR|WS|WV|YO|ZE)(\\d[\\dA-Z]?[ ]?\\d[ABD-HJLN-UW-Z]{2}))|BFPO[ ]?\\d{1,4}$","^JE\\d[\\dA-Z]?[ ]?\\d[ABD-HJLN-UW-Z]{2}$","^GY\\d[\\dA-Z]?[ ]?\\d[ABD-HJLN-UW-Z]{2}$","^IM\\d[\\dA-Z]?[ ]?\\d[ABD-HJLN-UW-Z]{2}$","^\\d{5}([ \\-]\\d{4})?$","^[ABCEGHJKLMNPRSTVXY]\\d[ABCEGHJ-NPRSTV-Z][ ]?\\d[ABCEGHJ-NPRSTV-Z]\\d$","^\\d{5}$","^\\d{3}-\\d{4}$","^\\d{2}[ ]?\\d{3}$","^\\d{4}$","^\\d{5}$","^\\d{4}$","^\\d{4}[ ]?[A-Z]{2}$","^\\d{3}[ ]?\\d{2}$","^\\d{5}[\\-]?\\d{3}$","^\\d{4}([\\-]\\d{3})?$","^22\\d{3}$","^\\d{3}[\\-]\\d{3}$","^\\d{6}$","^\\d{3}(\\d{2})?$","^\\d{7}$","^\\d{4,5}|\\d{3}-\\d{4}$","^\\d{3}[ ]?\\d{2}$","^([A-Z]\\d{4}[A-Z]|(?:[A-Z]{2})?\\d{6})?$","^\\d{3}$","^\\d{3}[ ]?\\d{2}$","^39\\d{2}$","^(?:\\d{5})?$","^(\\d{4}([ ]?\\d{4})?)?$","^(948[5-9])|(949[0-7])$","^[A-Z]{3}[ ]?\\d{2,4}$","^(\\d{3}[A-Z]{2}\\d{3})?$","^980\\d{2}$","^((\\d{4}-)?\\d{3}-\\d{3}(-\\d{1})?)?$","^(\\d{6})?$","^(PC )?\\d{3}$","^\\d{2}-\\d{3}$","^00[679]\\d{2}([ \\-]\\d{4})?$","^4789\\d$","^\\d{3}[ ]?\\d{2}$","^00120$","^96799$","^6799$","^8\\d{4}$","^6798$","FIQQ 1ZZ","2899","(9694[1-4])([ \\-]\\d{4})?","9[78]3\\d{2}","9[78][01]\\d{2}","SIQQ 1ZZ","969[123]\\d([ \\-]\\d{4})?","969[67]\\d([ \\-]\\d{4})?","9695[012]([ \\-]\\d{4})?","9[78]2\\d{2}","988\\d{2}","008(([0-4]\\d)|(5[01]))([ \\-]\\d{4})?","987\\d{2}","9[78]5\\d{2}","PCRN 1ZZ","96940","9[78]4\\d{2}","(ASCN|STHL) 1ZZ","[HLMS]\\d{3}","TKCA 1ZZ","986\\d{2}","976\\d{2}"]
        var pinPredicate = NSPredicate()
        var result = Bool()
        for index in 0..<zipCodeRegExArray.count
        {
            pinPredicate = NSPredicate(format: "SELF MATCHES %@", zipCodeRegExArray[index])
            if(pinPredicate.evaluate(with: zipCode) == true)
            {
                result = true
                break
            }
            else
            {
                result = false
            }
        }
        //        result = pinPredicate.evaluate(with: zipCode) as Bool
        return result
        
    }
    
    class func removeUserData(){
        UserDefaults.standard.removeObject(forKey: USER_DATA)
        //        UserDefaults.standard.removeObject(forKey: USER_ROLE)
        //        UserDefaults.standard.removeObject(forKey: USER_PROFILE)
    }
    
    class func saveUserData(data: [String: Any]){
        UserDefaults.standard.setValue(data, forKey: USER_DATA)
        UserDefaults.standard.synchronize()
    }
    
    class func getUserData() -> LoginResponse?{
        if let data = UserDefaults.standard.value(forKey: USER_DATA) as? [String: Any]{
            let dic = LoginResponse(JSON: data)
            return dic
        }
        return nil
    }
    
    class func getAccessToken() -> String?{
        if let token = getUserData()?.auth?.access_token{
            return token
        }
        return nil
    }
    
    //    class func saveUserRole(val: RoleType){
    //        UserDefaults.standard.setValue(val.rawValue, forKey: USER_ROLE)
    //    }
    //
    //    class func getUserRole() -> RoleType{
    //        if let val = UserDefaults.standard.value(forKey: USER_ROLE) as? Int{
    //            return val == 1 ? RoleType.coachMode : RoleType.playerMode
    //        }
    //        return .playerMode
    //    }
    
    //    class func getUserVideoFileURL() -> String?{
    //        if getUserData()?.backgroundMediaThumbnail != nil{
    //            if let videoURL = getUserData()?.saveLocalBackgroundVideo{
    //                return videoURL
    //            }else if let videoURL = getUserData()?.backgroundMedia{
    //                return videoURL
    //            }
    //        }
    //        return nil
    //    }
    
    //    class func saveLocalVideoURL(url: String){
    //        if let user = getUserData(){
    //            user.saveLocalBackgroundVideo = url
    //            Utility.saveUserData(data: user.toJSON())
    //        }
    //    }
    
    //    class func saveUserProfileData(data: [String: Any]){
    //        UserDefaults.standard.setValue(data, forKey: USER_PROFILE)
    //    }
    //
    //    class func getUserProfileData() -> SignUpResponse?{
    //        if let data = UserDefaults.standard.value(forKey: USER_PROFILE) as? [String: Any]{
    //            let dic = SignUpResponse(JSON: data)
    //            return dic
    //        }
    //        return nil
    //    }
    
    //    class func setPlayAudio(isPlay: Bool){
    //        UserDefaults.standard.setValue(isPlay, forKey: AUDIO_PLAY)
    //    }
    //
    //    class func isPlayAudio() -> Bool{
    //        if let isPlay = UserDefaults.standard.value(forKey: AUDIO_PLAY) as? Bool{
    //            return isPlay
    //        }
    //        return true
    //    }
    
    
    //    class func setProfileRoot(){
    //        let vc = STORYBOARD.profile.instantiateViewController(withIdentifier: "ProfileScreen") as! ProfileScreen
    //        let navVC = UINavigationController(rootViewController: vc)
    //        navVC.interactivePopGestureRecognizer?.isEnabled = false
    //        appDelegate.window?.rootViewController = navVC
    //        appDelegate.window?.makeKeyAndVisible()
    //    }
    
    class func setLoginRoot(){
        //        let vc = STORYBOARD.login.instantiateViewController(withIdentifier: "LoginScreen") as! LoginScreen
        //        let navVC = UINavigationController(rootViewController: vc)
        //        navVC.interactivePopGestureRecognizer?.isEnabled = false
        //        appDelegate.window?.rootViewController = navVC
        //        appDelegate.window?.makeKeyAndVisible()
        
        App_Delegate.setupViewController()
    }
    
    class func saveImageAndGetPath(image: UIImage) -> String{
        let fileManager = FileManager.default
        let imageName = self.getImageName(fileExtension: "jpg")
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
        let image = image
        let imageData = image.jpegData(compressionQuality: 0.3)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return paths
    }
    
    class func getImageName(fileExtension : String) -> String{
        let uniqueString: String = ProcessInfo.processInfo.globallyUniqueString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmsss"
        let dateString: String = formatter.string(from: Date())
        let uniqueName: String = "\(uniqueString)_\(dateString)"
        if fileExtension.count > 0 {
            let fileName: String = "\(uniqueName).\(fileExtension)"
            return fileName
        }
        return uniqueName
    }
    
    class func checkMicrophonePermission(){
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            print("Permission granted")
        case AVAudioSession.RecordPermission.denied:
            print("Pemission denied")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
            })
        case AVAudioSession.RecordPermission.undetermined:
            print("Request permission here")
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
            })
        @unknown default:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                // Handle granted
            })
        }
    }
    
    
    class func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) y "//ears ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 y"//ear ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) m"//onths ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 m"//onth ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) w"//eeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 w"//eek ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) d"//ays ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 d"//ay ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) h"//ours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 h"//our ago"
            } else {
                return "An hour "//ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) min"//utes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min"//ute ago"
            } else {
                return "A min"//ute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) sec"//onds ago"
        } else {
            return "Just now"
        }
        
    }
    //    //added by jainee
    //    class func getAddressFromLatLon() -> String{
    //        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    //        var addressString : String = ""
    //        let lat: Double = Double("\(currentLatitude)")!
    //        let lon: Double = Double("\(currentLongitude)")!
    //        if (lat != 0 && lon != 0){
    //            let ceo: CLGeocoder = CLGeocoder()
    //            center.latitude = lat
    //            center.longitude = lon
    //            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    //            ceo.reverseGeocodeLocation(loc, completionHandler:
    //                {(placemarks, error) in
    //                    if (error != nil)
    //                    {
    //                        print("reverse geodcode fail: \(error!.localizedDescription)")
    //                    }
    //                    let pm = placemarks! as [CLPlacemark]
    //                    if pm.count > 0 {
    //                        let pm = placemarks![0]
    //                        //                    print(pm.country!)
    //                        //                    print(pm.locality!)
    //                        //                    print(pm.subLocality!)
    //                        //                    print(pm.thoroughfare!)
    //                        //                    print(pm.postalCode!)
    //                        //                    print(pm.subThoroughfare!)
    //                        //                    if pm.subLocality != nil {
    //                        //                        addressString = addressString + pm.subLocality! + ", "
    //                        //                    }
    //                        //                    if pm.thoroughfare != nil {
    //                        //                        addressString = addressString + pm.thoroughfare! + ", "
    //                        //                    }
    //                        //                    if pm.locality != nil {
    //                        addressString = addressString + pm.locality!
    //                        //                    }
    //                        //                    if pm.country != nil {
    //                        //                        addressString = addressString + pm.country! + ", "
    //                        //                    }
    //                        //                    if pm.postalCode != nil {
    //                        //                        addressString = addressString + pm.postalCode! + " "
    //                        //                    }
    //                        print(addressString)
    //
    //                    }
    //            })
    //        }
    //        return addressString
    //    }
    //    class func setStatusBarBackgroundColor(color: UIColor) {
    //
    //        guard let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView else { return }
    //
    //        statusBar.backgroundColor = color
    //    }
    
    class func isValidPassword(Input:String) -> Bool {
        let RegExpression = "^(?=.*[#$@!%&*?])[A-Za-z[0-9]#$@!%&*?]{9,}+$"
        let result = NSPredicate(format:"SELF MATCHES %@", RegExpression)
        return result.evaluate(with: Input)
    }
    
    class func isSpecialCharacter(str: String) -> Bool{
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if str.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }
        return false
    }
    
    class func labelWidth(height: CGFloat, font: UIFont,text: String) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.text = text
        label.font = font
        label.sizeToFit()
        return label.frame.width
    }
    
    class func addUnderLine(label: UILabel){
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.underlineColor : UIColor.white] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: label.text ?? "", attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
    }
    
    class func removeUnderLine(label: UILabel){
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.underlineColor :UIColor.clear] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: label.text ?? "", attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
    }
    
    class func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    class func lightCompressVideo(videoURL: URL,destinationURL: URL? = nil,compressProgress: @escaping(_ value:Double) -> Void,completion: @escaping(_ url: URL) -> Void){
        var destURL: URL?
        if let url = destinationURL{
            destURL = url
        }else{
            let destinationPath = NSTemporaryDirectory() + UUID().uuidString+".mp4"
            destURL = URL(fileURLWithPath: destinationPath as String)
        }
        print("Berfore size light compress:--",Utility.getVideoSize(url: videoURL))
        LightCompressor().compressVideo(source: videoURL, destination: destURL!, quality: .high, isMinBitRateEnabled: true, keepOriginalResolution: true, progressQueue: .main) { (progress) in
            //            print(progress.fractionCompleted)
            compressProgress(progress.fractionCompleted)
        } completion: { (result) in
            switch result {
            case .onSuccess(let path):
                print(path)
                completion(path)
                print("After size light compress:--",Utility.getVideoSize(url: path))
                break
            case .onStart:
                print("Start")
                break
            case .onFailure(let error):
                print("fail")
                print(error.localizedDescription)
                completion(videoURL)
                break
            case .onCancelled:
                completion(videoURL)
                break
            }
        }
    }
    
    //    class func lightCompressVideo(videoURL: URL,destinationURL: URL? = nil,completion: @escaping(_ url: URL) -> Void){
    //            var destURL: URL?
    //            if let url = destinationURL{
    //                destURL = url
    //            }else{
    //                let destinationPath = NSTemporaryDirectory() + UUID().uuidString+".mp4"
    //                destURL = URL(fileURLWithPath: destinationPath as String)
    //            }
    //            LightCompressor.shared.compressVideo(source: videoURL, destination: destURL!, quality: .medium, isMinBitRateEnabled: true, keepOriginalResolution: true, progressQueue: .global(qos: .background)) { (progress) in
    //                print(progress)
    //            } completion: { (result) in
    //                switch result {
    //                case .onSuccess(let path):
    //                    print(path)
    //                    completion(path)
    //                    break
    //                case .onStart:
    //                    print("Start")
    //                    break
    //                case .onFailure(let error):
    //                    print("fail")
    //                    print(error.localizedDescription)
    //                    completion(videoURL)
    //                    break
    //                case .onCancelled:
    //                    completion(videoURL)
    //                    break
    //                }
    //            }
    //        }
    
    //    Utility.lightCompressVideo(videoURL: url) {  (compressVideoURL) in
    //
    //                }
    
    //    class func downloadAudio(url: URL){
    //
    //        var downloadTask:URLSessionDownloadTask
    //        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URL, response, error) -> Void in
    //            if let url = URL{
    //                Utility.play_recording(url: url)
    //            }
    //        })
    //
    //        downloadTask.resume()
    //
    //    }
    
    //    class func play_recording(url:URL)
    //    {
    //        appDelegate.playAudio(url: url.absoluteString)
    //    }
    
    //MARK:- Create Thumbnail From Video
    class func createThumbnailFromVideoURL(videoURL: String) -> UIImage?{
        let asset = AVAsset(url: URL(string: videoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(0), preferredTimescale: asset.duration.timescale)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch let err{
            print(err.localizedDescription)
        }
        return nil
    }
    
    //MARK:- Return in MB
    class func getVideoSize(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    //    class func displayProgressView(progeesVal: Double,view: UIView){
    //        let HUD = JGProgressHUD()
    //        HUD.vibrancyEnabled = true
    //        HUD.detailTextLabel.text = "\(progeesVal)% Complete"
    //        HUD.textLabel.text = "Downloading"
    //        HUD.indicatorView = JGProgressHUDPieIndicatorView() //Or JGProgressHUDRingIndicatorView
    //        HUD.progress = Float(progeesVal)
    //        HUD.show(in: view)
    //    }
    //
    //    class func hideProgressView(){
    //        JGProgressHUD().dismiss()
    //    }
    
    //    class func getVideoDuration(from path: URL) -> String {
    //        let asset = AVURLAsset(url: path)
    //        let duration: CMTime = asset.duration
    //
    //        let totalSeconds = CMTimeGetSeconds(duration)
    //        let hours = Int(totalSeconds / 3600)
    //        let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
    //        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
    //
    //        if hours > 0 {
    //            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
    //        } else {
    //            return String(format: "%02i:%02i", minutes, seconds)
    //        }
    //    }
    
    class func getVideoDurationFromSecond(seconds: CGFloat) -> String{
        //        let totalSeconds = CMTimeGetSeconds(seconds)
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    class func getSecondFromVideoURL(from path: URL) -> CGFloat{
        let asset = AVURLAsset(url: path)
        let duration: CMTime = asset.duration
        
        return CGFloat(CMTimeGetSeconds(duration))
    }
    
    class func getDateTimeFromTimeInterVel(from dateIntervel: Double) -> Date{
        let date = Date(timeIntervalSince1970: dateIntervel)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return date
    }
    
    class func getDiffHourFromCurrentDate(date: Date) -> (Int,Int){
        let diffComponents = Calendar.current.dateComponents([.hour,.second], from: date, to: Date())
        return (diffComponents.hour ?? 0,diffComponents.second ?? 0)
    }
    
    //    class func checkAndPlayAudio(){
    //        if Utility.isPlayAudio(){
    //            appDelegate.avPlayer?.play()
    //        }else{
    //            appDelegate.avPlayer?.pause()
    //        }
    //    }
    
    class func heightOfLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}


extension UIImage
{
    //    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)! as NSData }
    //    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! as NSData}
    //    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)! as NSData }
    //    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! as NSData}
    //    var lowestQualityJPEGNSData: NSData
    //    {
    //        return UIImageJPEGRepresentation(self, 0.0)! as NSData
    //    }
    var highestQualityJPEGNSData: NSData { return self.jpegData(compressionQuality: 1.0)! as NSData }
    var highQualityJPEGNSData: NSData    { return self.jpegData(compressionQuality: 0.75)! as NSData}
    var mediumQualityJPEGNSData: NSData  { return self.jpegData(compressionQuality: 0.5)! as NSData }
    var lowQualityJPEGNSData: NSData     { return self.jpegData(compressionQuality: 0.5)! as NSData}
    var lowestQualityJPEGNSData: NSData
    {
        return self.jpegData(compressionQuality: 0.0)! as NSData
    }
}
var bundleKey: UInt8 = 0
class AnyLanguageBundle: Bundle {
    
    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
                  
                  return super.localizedString(forKey: key, value: value, table: tableName)
              }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    
    class func setLanguage(_ language: String) {
        
        defer {
            
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey,    Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
extension Optional where Wrapped == String {
    func isEmailValid() -> Bool{
        guard let email = self else { return false }
        let emailPattern = "[A-Za-z-0-9.-_]+@[A-Za-z0-9]+\\.[A-Za-z]{2,3}"
        do{
            let regex = try NSRegularExpression(pattern: emailPattern, options: .caseInsensitive)
            let foundPatters = regex.numberOfMatches(in: email, options: .anchored, range: NSRange(location: 0, length: email.count))
            if foundPatters > 0 {
                return true
            }
        }catch{
            //error
        }
        return false
    }
}


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y ago"   }
        if months(from: date)  > 0 { return "\(months(from: date))mon ago"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w ago"   }
        if days(from: date)    > 0 { return "\(days(from: date))d ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))hrs ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))min ago" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))sec ago" }
        return ""
    }
    
    func offsetHome(from date: Date) -> String {
        //        if hours(from: date)   > 0
        //        {
        //            return "\(hours(from: date))"
        //        }
        //        return ""
        
        let hour = abs(hours(from: date))
        if hour > 0
        {
            return "\(hour)"
        }
        return ""
    }
}
class UnderlinedLabel: UILabel {
    
    //override var text: String? {
    //    didSet {
    //        guard let text = text else { return }
    //        let textRange = NSMakeRange(0, text.count)
    //        let attributedText = NSMutableAttributedString(string: text)
    //        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
    //        // Add other attributes if needed
    //        self.attributedText = attributedText
    //        }
    //    }
}
class CustomSlider : UISlider {
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
}
extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}
