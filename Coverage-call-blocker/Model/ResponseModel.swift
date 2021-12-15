//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import Foundation
import ObjectMapper


class LoginResponse: Mappable{
    var id: Int?
    var email: String?
    var password: String?
    var isPremium: Int?
    var auth: Auth?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        password <- map["password"]
        isPremium <- map["isPremium"]
        auth <- map["access_token"]
    }
}

class Auth: Mappable{
    var token_type: String?
    var access_token: String?
    var refresh_token: String?
    var expires_in: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        token_type <- map["token_type"]
        access_token <- map["access_token"]
        refresh_token <- map["refresh_token"]
        expires_in <- map["expires_in"]
    }
}

class StateResponse: Mappable{
   
    var state_id: Int?
    var state_name: String?
//    var isSelected: Bool = false
    
    required init?(map: Map) {
        
    }
    
    init(state_id: Int?, state_name: String?) {
        self.state_id = state_id
        self.state_name = state_name
//        self.isSelected = false
    }
    
    func mapping(map: Map) {
        
        state_id <- map["state_id"]
        state_name <- map["state_name"]
    }
}

class CompaniesResponse: Mappable{
   
    var company_id: Int?
    var company_name: String?
//    var isSelected: Bool = false
    
    required init?(map: Map) {
        
    }
    
    init(company_id: Int?, company_name: String?) {
        self.company_id = company_id
        self.company_name = company_name
//        self.isSelected = false
    }
    
    func mapping(map: Map) {
        
        company_id <- map["company_id"]
        company_name <- map["company_name"]
    }
}

class MaxBlockingResponse: Mappable{
   
    var user_id: Int?
    var phone: String?
    var context: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        user_id <- map["user_id"]
        phone <- map["phone"]
        context <- map["context"]
    }
}

class ContactResponse: Mappable{
    
    var name:String?
    var number:Int64?
    var isWhiteList: Bool?
    var isBlackList: Bool?
    
    init(name:String?, number: Int64?, isWhiteList: Bool?, isBlackList: Bool?) {
        self.name = name
        self.number = number
        self.isWhiteList = isWhiteList
        self.isBlackList = isBlackList
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        number <- map["number"]
        isWhiteList <- map["isWhiteList"]
        isBlackList <- map["isBlackList"]
    }
}

class Meta: Mappable{
    var total: Int?
    var perPage: Int?
    var currentPage: Int?
    var lastPage: Int?
    var from: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        total <- map["total"]
        perPage <- map["per_page"]
        currentPage <- map["current_page"]
        lastPage <- map["last_page"]
        from <- map["from"]
    }
}

