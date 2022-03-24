//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import Foundation
import UIKit
import AVFoundation
import SDWebImage
import SVProgressHUD

extension String
{
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidateUrl() -> Bool {
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        //        var urlTest = NSPredicate.withSubstitutionVariables(predicate)
        return predicate.evaluate(with: self)
    }
    
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        return label.frame.height
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var nowDateToString: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMM_ddhhmmsss"
        let date = dateFormatter.string(from: Date())
        return date
    }
    
    var nowDateYYYYMMDDToString: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_hh_mm_ss_a"
        let date = dateFormatter.string(from: Date())
        return date
    }
    
    var stringToDate: Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = dateFormatter.date(from: self)
        return (date == nil) ? Date() : date!
    }
    
    var fileName:String {
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    var fileExtension:String {
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }
    
    var toURL:URL
    {
        let urlString = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        return URL.init(string: urlString!)!
    }
    
    var videoDuration: String {
        let totalSeconds = CMTimeGetSeconds(AVAsset(url: URL(fileURLWithPath: self)).duration)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    func replaceFirstOccurrence(of: String, with newString: String) -> String {
        var temp: String = self
        if let range = self.range(of:of) {
            temp.replaceSubrange(range, with: newString)
        }
        return temp
    }
    
    func base64ToString() -> String {
        if self == "" {
            return ""
        }
        return String(data: Data(base64Encoded: self)!, encoding: .utf8)!
    }
    
    func stringDateChangeFormat(format: String , new_format: String) -> String {
        let dateFormat =  DateFormatter()
        dateFormat.dateFormat = format;
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        if let dt =  dateFormat.date(from: self) {
            dateFormat.dateFormat = new_format
            dateFormat.timeZone = NSTimeZone.local as TimeZone
            return dateFormat.string(from: dt)
        }else{
            return ""
        }
    }
    
    func stringDateToNSDate(format: String) -> Date? {
        let dateFormat =  DateFormatter()
        dateFormat.dateFormat = format;
        dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormat.date(from: self)
    }
    
    func nSDateToStringDate (date: Date , format: String) -> String {
        let dateFormat =  DateFormatter()
        dateFormat.dateFormat = format;
        return dateFormat.string(from: date)
    }
    
    func serverDateTimeToStringDate(format: String) -> String {
        return self.stringDateChangeFormat(format: "yyyy-MM-dd HH:mm:ss", new_format: format)
    }
    
    func serverDateTimeToDate(date: String) -> Date? {
        return self.stringDateToNSDate(format: "yyyy-MM-dd HH:mm:ss")
    }
    
    func serverDateTimeToTodayFormat( isShort: Bool = true ) -> String {
        if let serverDate = self.serverDateTimeToDate(date: self) {
            if Calendar.current.isDateInToday(serverDate) {
                return self.nSDateToStringDate(date: serverDate, format: "hh:mm a")
            }else if Calendar.current.isDateInYesterday(serverDate ) {
                return  isShort ? "Yesterday" : self.nSDateToStringDate(date: serverDate, format: "'Yesterday' hh:mm a")
            }else if Calendar.current.dateComponents([.day], from: serverDate, to: Date()).day ?? 0 < 7{
                return self.nSDateToStringDate(date: serverDate, format: isShort ? "EEEE" : "EEEE hh:mm a")
            }else{
                return self.nSDateToStringDate(date: serverDate, format: isShort ? "MM/dd/yyyy" : "MM/dd/yyyy 'at' hh:mm a")
            }
        }else{
            return "-"
        }
    }
    
    func timeAgoStringFromDate() -> String {
        
        let date =  self.stringDateToNSDate(format: "yyyy-MM-dd HH:mm:ss") as Date? ?? Date()
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        
        let now = Date()
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute,.second], from: date, to: now)
        //        let components = calendar.components(,
        //                                             fromDate: date,
        //                                             toDate: now,
        //                                             options:NSCalendar.Options(rawValue: 0))
        
        if components.year ?? 0 > 0 {
            formatter.allowedUnits = .year
        } else if components.month ?? 0 > 0 {
            formatter.allowedUnits = .month
        } else if components.weekOfMonth ?? 0 > 0 {
            formatter.allowedUnits = .weekOfMonth
        } else if components.day ?? 0 > 0 {
            formatter.allowedUnits = .day
        } else if components.hour ?? 0 > 0 {
            formatter.allowedUnits = .hour
        } else if components.minute ?? 0 > 0 {
            formatter.allowedUnits = .minute
        } else {
            formatter.allowedUnits = .second
        }
        
        let formatString = NSLocalizedString("%@", comment: "Used to say how much time has passed. e.g. '2 hours ago'")
        
        guard let timeString = formatter.string(from: components) else {
            return ""
        }
        return String(format: formatString, timeString)
    }
    
    func getPhoneNumber() -> String {
        
        var text = self
        text = text.replacingOccurrences(of: "(", with: "")
        text = text.replacingOccurrences(of: ")", with: "")
        text = text.replacingOccurrences(of: " ", with: "")
        text = text.replacingOccurrences(of: "-", with: "")
        return text
    }
    
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
}

extension Float64 {
    
    var duration: String {
        
        let hours:Int = Int(self / 3600)
        let minutes:Int = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(self.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

extension Date
{
    // Convert local time to UTC (or GMT)
    public func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    public func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    var dateFormatterString: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm:ss a"
        let date = dateFormatter.string(from: self)
        return date
    }
    
    var timeFormatterString: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date = dateFormatter.string(from: self)
        return date
    }
    
    var dateYearString: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let date = dateFormatter.string(from: self)
        return date
    }
    
    var timestampString: String?
    {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone.current
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.calendar = calendar
        
        guard let timeString = formatter.string(from: self, to: Date()) else {
            return nil
        }
        
        let formatString = NSLocalizedString("%@", comment: "")
        return String(format: formatString, timeString)
    }
    
    func timestamp() -> Int64 {
        
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    static func date(timestamp: Int64) -> Date {
        
        let interval = TimeInterval(TimeInterval(timestamp) / 1000)
        return Date(timeIntervalSince1970: interval)
    }
    
    func serverDateTimeToTodayFormat( isShort: Bool = true ) -> String {
        
        if Calendar.current.isDateInToday(self) {
            return self.nSDateToStringDate( format: "hh:mm a")
        }else if Calendar.current.isDateInYesterday(self ) {
            return  isShort ? "Yesterday" : self.nSDateToStringDate( format: "'Yesterday' hh:mm a")
        }else if Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0 < 7{
            return self.nSDateToStringDate( format: isShort ? "EEEE" : "EEEE hh:mm a")
        }else{
            return self.nSDateToStringDate( format: isShort ? "MM/dd/yyyy" : "MM/dd/yyyy 'at' hh:mm a")
        }
    }
    
    func nSDateToStringDate ( format: String) -> String {
        let dateFormat =  DateFormatter()
        dateFormat.dateFormat = format;
        return dateFormat.string(from: self)
    }
    
    func years(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.year], from: sinceDate, to: self).year
    }
    
    func months(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.month], from: sinceDate, to: self).month
    }
    
    func days(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.day], from: sinceDate, to: self).day
    }
    
    func hours(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.hour], from: sinceDate, to: self).hour
    }
    
    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }
    
    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }
}

extension UIImageView
{
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func loadImage(urlString: String?, placeHolder: String? , isTempColor: Bool = false) {
        let url = String.init(format: "%@", urlString ?? "" )
        
        if placeHolder != nil && placeHolder != "" {
            
            if url.hasPrefix("http") {
                self.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: placeHolder ?? ""), options: .scaleDownLargeImages) { (image, error, cacheType, imgURL) in
                    if error != nil {
                        self.image = UIImage(named: placeHolder ?? "")
                    }
                    else {
                        if isTempColor {
                            self.image = image?.withRenderingMode(.alwaysTemplate)
                        }else{
                            self.image = image
                        }
                    }
                }
            }else{
                self.image = UIImage(named: placeHolder ?? "")
            }
            
        }else{
            self.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .scaleDownLargeImages) { (image, error, cacheType, imgURL) in
                if error != nil {
                    self.image = nil
                }
                else {
                    
                    if isTempColor {
                        self.image = image?.withRenderingMode(.alwaysTemplate)
                    }else{
                        self.image = image
                    }
                }
            }
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}

extension UIImage {
    
    func imageThumbNail() -> UIImage {
        return UIImage.square(image: self, size: 500)
    }
    
    class func square(image: UIImage, size: CGFloat) -> UIImage {
        
        var cropped: UIImage!
        
        if (image.size.width == image.size.height) {
            cropped = image
        } else if (image.size.width > image.size.height) {
            let xpos: CGFloat = (image.size.width - image.size.height) / 2
            cropped = crop(image: image, x: xpos, y: 0, width: image.size.height, height: image.size.height)
        } else if (image.size.height > image.size.width) {
            let ypos: CGFloat = (image.size.height - image.size.width) / 2
            cropped = crop(image: image, x: 0, y: ypos, width: image.size.width, height: image.size.width)
        }
        
        return resize(image: cropped, width: size, height: size, scale: 1)
    }
    
    class func resize(image: UIImage, width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {
        
        let size = CGSize(width: width, height: height)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: rect)
        let resized = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resized
    }
    
    class func crop(image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        let cgImage = image.cgImage?.cropping(to: rect)
        let cropped = UIImage(cgImage: cgImage!)
        
        return cropped
    }
}

extension UIView
{
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    var App_Delegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func addGradientWithColor() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.init(hex: "36A9EA").cgColor, UIColor.init(hex: "015787").cgColor]
        self.layer.insertSublayer(gradient, at: UInt32(0.5))
    }
}

@objc enum ButtonAnimationType: UInt {
    case none = 0, self_press, super_press
}

extension URL {
    var videoThumbNail: UIImage? {
        do {
            let generate1 = AVAssetImageGenerator.init(asset: AVURLAsset.init(url: self))
            generate1.appliesPreferredTrackTransform = true
            let oneRef = try generate1.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 2), actualTime: nil)
            return UIImage(cgImage: oneRef)
        }
        catch {
            print(" videoThumbNail Error: %@", error.localizedDescription)
            return nil
        }
    }
    
    var videoDuration: String {
        let totalSeconds = CMTimeGetSeconds(AVAsset(url: self).duration)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}


extension UIViewController
{
    var App_Delegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func configureChildViewController(childController: UIViewController, onView: UIView?) {
        var holderView = self.view
        if let onView = onView {
            holderView = onView
        }
        addChild(childController)
        holderView?.addSubview(childController.view)
        constrainViewEqual(holderView: holderView!, view: childController.view)
        childController.didMove(toParent: self)
        childController.willMove(toParent: self)
    }
    
    func constrainViewEqual(holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        //pin 100 points from the top of the super
        let pinTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal,
                                        toItem: holderView, attribute: .top, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal,
                                           toItem: holderView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let pinLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal,
                                         toItem: holderView, attribute: .left, multiplier: 1.0, constant: 0)
        let pinRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal,
                                          toItem: holderView, attribute: .right, multiplier: 1.0, constant: 0)
        
        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
    
    func Show_HUD()
    {
        DispatchQueue.main.async {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.setForegroundColor(UIColor.white)
            //            SVProgressHUD.setBackgroundColor(UIColor.select_color())
            SVProgressHUD.show()
        }
    }
    
    func HideHUD()
    {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    public func heightForWidth(_ width: CGFloat, imageSize: CGSize) -> CGFloat
    {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: imageSize,
            insideRect: boundingRect
        )
        return rect.size.height
    }
    
    func showAlert(title: String ,message: String, linkHandler: ((UIAlertAction) -> Void)? ){
        let alertController = UIAlertController.init(title: title.localized, message: message.localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Ok".localized, style: .default, handler:linkHandler))
        self.present(alertController, animated: true, completion: nil);
    }
    
    func showLinkAlert(title: String ,message: String, linkTitle:String, linkHandler: ((UIAlertAction) -> Void)? ){
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction.init(title: linkTitle, style: .default, handler:linkHandler))
        self.present(alertController, animated: true, completion: nil);
    }
    
    func createFolder(dirName: String) -> Bool {
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = path.appendingPathComponent(path: dirName)
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: false, attributes: nil)
                return true
            }
            catch {
                print("createFolder error: %@", error.localizedDescription)
                return false
            }
        }else{
            let alertController = UIAlertController.init(title: "Error".localized, message: "directory already created.".localized, preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title: "OK".localized, style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil);
            return false
        }
    }
    
    //    @IBAction func clk_NavBack(){
    @IBAction func onBackClicked(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clk_NavRootBack(){
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //    @IBAction func clk_NotificationView(){
    //        self.App_Delegate.navVC?.pushViewController(NotificationViewController(), animated: true)
    //    }
    
    @IBAction func clk_Dismiss(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func Toast(message: String? ){
        let alertVC = UIAlertController.init(title: "", message: message?.localized, preferredStyle: .alert);
        alertVC.addAction(UIAlertAction.init(title: "Ok".localized, style: .default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func ToastRoot(message: String? ){
        if let vc = self.App_Delegate.window?.rootViewController {
            let alertVC = UIAlertController.init(title: "", message: message?.localized, preferredStyle: .alert);
            alertVC.addAction(UIAlertAction.init(title: "Ok".localized, style: .default, handler: nil))
            vc.present(alertVC, animated: true, completion: nil)
        }
    }
    
    var appUUidString: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

enum UserDefaultsKeys : String {
    case isLoggedIn
    case userID
}

extension NSDictionary
{
    func prettyPrint()
    {
        for (key,value) in self {
            print("\(key) = \(value)")
        }
    }
}

extension UITableView
{
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableHeaderView = header
    }
    
    func scrollToBottom()
    {
        DispatchQueue.main.async {
            
            if self.numberOfSections > 0,
               self.numberOfRows(inSection:  self.numberOfSections - 1) > 0 {
                let indexPath = IndexPath(
                    row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                    section: self.numberOfSections - 1)
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


public extension UIImage
{
    func heightForWidth(width: CGFloat) -> CGFloat
    {
        let boundingRect = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat(MAXFLOAT)
        )
        let rect = AVMakeRect(
            aspectRatio: size,
            insideRect: boundingRect
        )
        return rect.size.height
    }
    
    func imageWithImage(newSize: CGSize) -> UIImage {
        let scaleFactor = newSize.width / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newWidth = self.size.width * scaleFactor;
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage!
    }
}

extension UILabel
{
    func retrieveTextHeight() -> CGFloat
    {
        let attributedText = NSAttributedString(string: self.text!, attributes: [CoreText.kCTFontAttributeName as NSAttributedString.Key:self.font as Any])
        let rect = attributedText.boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        return ceil(rect.size.height)
    }
}

extension UIResponder {
    
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}


extension URLSession
{
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

enum FileType: Int {
    case  photo = 0, video, audio, note, document, other
}

extension String {
    func appendingPathComponent(path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    
    func appendingPathExtension(ext: String) -> String? {
        return (self as NSString).appendingPathExtension(ext)
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    var isValidFile: Bool {
        do {
            // png|jpg|jpeg|mp4|mov|avi|flv|3gp|h264|mpeg|mpg|mp3|m4a|aac|wav|wma|txt|text|rtf|pdf|doc|docx|xls
            let regex = try NSRegularExpression(pattern: "^.+\\.(png|jpg|jpeg|mp4|mov|avi|flv|3gp|h264|mpeg|mpg|mp3|m4a|aac|wav|wma|txt|text)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var  isValidFilePhotoVideo: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^.+\\.(png|jpg|jpeg)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var  isValidFilePhoto: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^.+\\.(png|jpg|jpeg)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var  isValidFileVideo: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^.+\\.(mp4|mov|avi|flv|3gp|h264|mpeg|mpg)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var isValidFileAudio: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^.+\\.(mp3|m4a|aac|ogg|wav|wma)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var isValidFileNote: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^.+\\.(txt|text)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var isValidFileDocument: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^.+\\.(pdf|doc|docx|rtf|xls)$", options: [])
            return regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count)).count > 0
        } catch {
            print("isValidFile : %@", error.localizedDescription)
            return false
        }
    }
    
    var file_type: FileType {
        if self.isValidFilePhoto {
            return .photo
        }else if  self.isValidFileVideo {
            return .video
        }else if  self.isValidFileAudio {
            return .audio
        }else if  self.isValidFileNote {
            return .note
        }else if  self.isValidFileDocument {
            return .document
        }else{
            return .other
        }
    }
    
    func getDateTime(formate: String = "EEEE, MMM dd")-> String {
        
        if(self == "") {
            return ""
        }
        let dt = DateFormatter()
        dt.dateFormat = formate
        return dt.string(from: Date(timeIntervalSince1970: (Double(self) ?? 0.0) as TimeInterval))
    }
    
    func UTCToLocal(formate: String = "EEEE, MMM dd") -> String {
        
        if(self == "") {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy H:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = formate
        return dateFormatter.string(from: dt!)
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    public static func localize(key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
}

extension FileManager {
    func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
}

struct AssociatedKeys {
    //    static var languageInput: UInt8 = 0
    static var tempPath:  UInt8 = 1
    static var videoID:  UInt8 = 2
    
    static var objectDic: UInt8 = 5
}


extension NSError {
    
    class func description(_ description: String, code: Int) -> Error? {
        
        let domain = Bundle.main.bundleIdentifier ?? ""
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}

extension Array where Element: Hashable {
    
    mutating func removeDuplicates() {
        
        var array: [Element] = []
        
        for element in self {
            if !array.contains(element) {
                array.append(element)
            }
        }
        
        self = array
    }
    
    mutating func removeObject(_ element: Element) {
        
        var array = self
        
        while let index = array.firstIndex(of: element) {
            array.remove(at: index)
        }
        self = array
    }
}

extension NotificationCenter {
    
    class func addObserver(target: Any, selector: Selector, name: String) {
        NotificationCenter.default.addObserver(target, selector: selector, name: NSNotification.Name(name), object: nil)
    }
    
    class func removeObserver(target: Any) {
        NotificationCenter.default.removeObserver(target)
    }
    
    class func post(notification: String) {
        NotificationCenter.default.post(name: NSNotification.Name(notification), object: nil)
    }
}

extension NSDictionary {
    @objc func name() -> String? {
        return self["name"] as? String
    }
}

extension Error {
    func code() -> Int {
        return (self as NSError).code
    }
}

extension UserDefaults {
    
    class func setObject(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func string(key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    class func bool(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
}

extension NSObject {
    static var App_Delegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func AppLogin(){
        //        FBDBStore.shared.addListener()
    }
    
    class func AppLogout(){
        
    }
}

extension UIColor {
    
    //    class func backgroud_color() -> UIColor {return UIColor.init(hex: "0e0f19")}
    //    class func up_backgroud_color() -> UIColor { return UIColor.init(hex: "151823") }
    //
    //
    //    class func fill_box_border_color() -> UIColor { return UIColor.init(hex:"6cb8bd") }
    //    class func unfill_box_border_color() -> UIColor { return UIColor.init(hex: "eace4a") }
    //
    //    class func text_color() -> UIColor { return UIColor.init(hex: "262525")}
    //    class func text_l_color() -> UIColor { return UIColor.init(hex: "7C7C7C")}
    //    class func g_bg_color() -> UIColor { return UIColor.init(hex: "eff1f5")}
    //    class func select_color() -> UIColor { return UIColor.init(hex: "262F56")}
    //    class func selectDrak_color() -> UIColor { return UIColor.init(hex: "55B895")}//088669
    //    class func unselect_color() -> UIColor { return UIColor.init(hex: "7C7C7C")}
    //
    //    class func FixTextColor()-> UIColor { return UIColor.init(hex: "FFFFFF")}
    //    class func FixBGColor()-> UIColor {return UIColor.init(hex: "FFFFFF")}
    //    class func BoxBoardColor()-> UIColor { return UIColor.init(hex: "ffffff")}
    //
    //    class func PadButtonBGColor()-> UIColor { return UIColor.init(hex: "9248E8") }
    
    //    class func getThemColor(_ day: ThemName) -> ThemColorSet {
    //        switch day {
    //        case .Main:
    //            return ThemColorSet(main_color: UIColor.init(hex: "b045fb" ),
    //                                top_color: UIColor.init(hex: "6269f5"),
    //                                btn_color: ButtonThemColorSet(main_color: UIColor.init(hex: "8a26c4" ),
    //                                                              top_color: UIColor.init(hex: "401f99")),
    //                                msg_color: ButtonThemColorSet(main_color: UIColor.init(hex: "8758f8" ),
    //                                                              top_color: UIColor.init(hex: "6f63f6")))
    //        default:
    //            return ThemColorSet(main_color: UIColor.init(hex: "000000" ),
    //                                top_color: UIColor.init(hex: "444444"),
    //                                btn_color: ButtonThemColorSet(main_color: UIColor.init(hex: "000000" ),
    //                                                              top_color: UIColor.init(hex: "444444")),
    //                                msg_color: ButtonThemColorSet(main_color: UIColor.init(hex: "000000" ),
    //                                                              top_color: UIColor.init(hex: "444444")) )
    //        }
    //    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        var hexString = ""
        
        if hex.hasPrefix("#") {
            let nsHex = hex as NSString
            hexString = nsHex.substring(from: 1)
        } else {
            hexString = hex
        }
        
        let scanner = Scanner(string: hexString)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hexString.count) {
            case 3:
                red = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue = CGFloat(hexValue & 0x00F)              / 15.0
            case 6:
                red = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue = CGFloat(hexValue & 0x0000FF)           / 255.0
            default:
                print("Invalid HEX string, number of characters after '#' should be either 3, 6")
            }
        } else {
            //MQALogger.log("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

typealias Dispatch = DispatchQueue

extension Dispatch {
    
    static func background(_ task: @escaping () -> ()) {
        Dispatch.global(qos: .background).async {
            task()
        }
    }
    
    static func main(_ task: @escaping () -> ()) {
        Dispatch.main.async {
            task()
        }
    }
}
