//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import Foundation
import ObjectMapper

class Response: Mappable{
    var success: String?
    var message: String?
    var loginResponse: LoginResponse?
    var stateResponse: [StateResponse]?
    var companiesResponse: [CompaniesResponse]?
    var maxBlockingResponse: [MaxBlockingResponse]?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        success <- map["success"]
        message <- map["message"]
        loginResponse <- map["data"]
        stateResponse <- map["data"]
        companiesResponse <- map["data"]
        maxBlockingResponse <- map["data"]
        
    }
}