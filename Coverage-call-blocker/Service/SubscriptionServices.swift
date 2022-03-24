//
//  SubscriptionServices.swift
//  Coverage-call-blocker
//
//  Created by iroid-Miraj on 17/03/22.
//

import Foundation
class SubscriptionServices {
    static let shared = { SubscriptionServices() }()
    
    //MARK: - Subscription
    func subscriptionAPI(parameters: [String: Any] = [:],success: @escaping (Int, Response) -> (), failure: @escaping (String) -> ()){
        APIManager.shared.requestAPIWithParameters(method: .post, urlString: subscribeURL, parameters: parameters) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
    //MARK: - Check Subscription
    func checkSubscriptionAPI(parameters: [String: Any] = [:],success: @escaping (Int, Response) -> (), failure: @escaping (String) -> ()){
        APIManager.shared.requestAPIWithParameters(method: .post, urlString: checkSubscriptionURL, parameters: parameters) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
}
