//
//  ServeyServices.swift
//  Coverage-call-blocker
//
//  Created by iroid on 09/10/21.
//

import Foundation
class ServeyServices {
    static let shared = { ServeyServices() }()
    
    //MARK: - conflicts count
    func getStates(success: @escaping (Int, Response?) -> (), failure: @escaping (String) -> ()){
        APIManager.shared.requestAPIWithGetMethod(method: .get, urlString: getStatesURL) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
    //MARK: - conflicts count
    func getCompanies(success: @escaping (Int, Response?) -> (), failure: @escaping (String) -> ()){
        APIManager.shared.requestAPIWithGetMethod(method: .get, urlString: getCompaniesURL) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
    //MARK: - ServeyPost
    func SurveyPost(parameters: [String: Any] = [:],success: @escaping (Int, Response) -> (), failure: @escaping (String) -> ()){
        APIManager.shared.requestAPIWithParameters(method: .post, urlString: serveyPostURL, parameters: parameters) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
    //MARK: - Max_Blocking
    func max_blocking(success: @escaping (Int, Response?) -> (), failure: @escaping (String) -> ()){
        APIManager.shared.requestAPIWithGetMethod(method: .get, urlString: getMaxBlocking) { (statusCode, response) in
            success(statusCode,response)
        } failure: { (error) in
            failure(error)
        }
    }
    
}
