//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import Foundation
import ObjectMapper


class RefreshTokenRequest: Mappable{
    var refresh_token: String?
    
    init(refresh_token: String?) {
        self.refresh_token = refresh_token
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        refresh_token <- map["refresh_token"]
    }
}

class SignupRequest: Mappable{
    var email: String?
    var password: String?
    var password_confirmation: String?
    var phone: String?
    
    init(email: String?, password: String?, password_confirmation: String, phone: String?) {
        self.email = email
        self.password = password
        self.password_confirmation = password_confirmation
        self.phone = phone
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        password <- map["password"]
        password_confirmation <- map["password_confirmation"]
        phone <- map["phone"]
    }
}

class SendOTPRequest: Mappable{
    var phone_number: String?
    
    init(phone_number: String?) {
        self.phone_number = phone_number
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        phone_number <- map["phone_number"]
    }
}

class LoginRequest: Mappable{
    var email: String?
    var password: String?
    
    init(email: String?, password: String?) {
        self.email = email
        self.password = password
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        password <- map["password"]
    }
}

class verifyotpRequest: Mappable{
    var code: String?
    
    init(code: String?) {
        self.code = code
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        code <- map["code"]
    }
}

class ServeyRequest: Mappable{
    var questions: String?
    
    init(questions: String?) {
        self.questions = questions
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        questions <- map["questions"]
    }
}

class CheckEmailRequest: Mappable{
    var email: String?
    
    init(email: String?) {
        self.email = email
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        email <- map["email"]
    }
}

class SubscribeRequest: Mappable{
    var receipt: String?
    var transactId: String?
    
    init(receipt: String?, transactId: String?) {
        self.receipt = receipt
        self.transactId = transactId
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        receipt <- map["receipt"]
        transactId <- map["transactId"]
    }
}

