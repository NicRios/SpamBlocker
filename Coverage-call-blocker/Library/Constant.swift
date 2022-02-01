//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import Foundation
import UIKit

struct STORYBOARD {
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    static let login = UIStoryboard(name: "Login", bundle: Bundle.main)
    static let Survey = UIStoryboard(name: "Survey", bundle: Bundle.main)
    static let home = UIStoryboard(name: "Home", bundle: Bundle.main)
    static let menu = UIStoryboard(name: "Menu", bundle: Bundle.main)
    static let inAppPurchase = UIStoryboard(name: "InAppPurchase", bundle: Bundle.main)
}

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let isiPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

let APPLICATION_NAME     = "Coverage-call-blocker"
let store_url            = ""
let android_url          = ""
let AppID                = ""
let video_lenth          = 60
let leftMenuWidth = (screenWidth/10) * 7
var isBlockingNumberInProgress = false
var CountryCode = "+91"

//MARK: - App color
let appBackgroundColor = UIColor.init(hex: "F0F0F0")

//MARK: - API URL
let server_url = "https://demo.iroidsolutions.com/spam-blocker-backend/public/api/v1/"

//MARK: - Login
let refreshTokenURL = server_url+"refresh-token"
let signupURL = server_url+"signup"
let checkmailURL = server_url+"checkmail"
let loginURL = server_url+"login"
let sendotpURL = server_url+"send-otp"
let verifyotpURL = server_url+"verify-otp"

//MARK: - Survey
let getStatesURL = server_url+"get/states"
let getCompaniesURL = server_url+"get/companies"
let serveyPostURL = server_url+"servey/post"
let getMaxBlockingURL = server_url+"get/max_blocking"
let getSpamsURL = server_url+"get/spams"

//MARK: - Session Key
let USER_DATA = "user_data"
let SURVEYARRAY = "SurveyArray"
let KEYWhiteListArray = "whiteListNumberArray"
let KEYBlackListArray = "blackListNumberArray"
let KEYSelectedOptionOnHomeScreen = "selectedOptionOnHomeScreen"
let KEYBlockNumberCount = "BlockNumberCount"
let KEYJSonFileCount = "JSonFileCount"

//MARK: - Common message
let SimNotAvailableMessage = "Sim not available."

func getFileName() -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMddHHmmss"//+UUID().uuidString//NSTimeIntervalSince1970.description
    return dateFormatter.string(from: Date())
}

class Screen: NSObject {
    
    class func WIDTHFORPER (per: CGFloat) -> CGFloat{
        return UIScreen.main.bounds.size.width * per / 100.0
    }
    
    class func HEIGHTFORPER (per: CGFloat) -> CGFloat{
        return UIScreen.main.bounds.size.height * per / 100.0
    }
}
