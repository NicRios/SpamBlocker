//
//  Coverage-call-blocker
//
//  Created by iroid on 01/10/21.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import SVProgressHUD

class APIManager {
    static let shared = {
        APIManager(baseURL: server_url)
    }()
    
    var baseURL: URL?
    
    required init(baseURL: String) {
        self.baseURL = URL(string: baseURL)
    }
    
    func getHeader() -> HTTPHeaders {
        var headerDic: HTTPHeaders = [:]
        if Utility.getUserData() == nil{
            headerDic = [
                "Accept": "application/json"
            ]
        }else{
            if let accessToken = Utility.getAccessToken(){
                headerDic = [
                    "Authorization":"Bearer "+accessToken,
                    "Accept": "application/json",
                ]
            }else{
                headerDic = [
                    "Accept": "application/json"
                ]
            }
        }
        return headerDic
    }
    
    func isConnectedToNetwork()->Bool{
        return NetworkReachabilityManager()!.isReachable
    }
    
    func requestAPIWithParameters(method: HTTPMethod,urlString: String,parameters: [String:Any],success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
        
        if isConnectedToNetwork() == false {
            failure("No internet available.")
            return
        }
        print("url ----> ", urlString)
        print("parameters ----> ", parameters)
        print("headers ----> ", getHeader())
        
        Alamofire.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseObject { (response: DataResponse<Response>) in
            switch response.result{
            case .success(let value):
                guard let statusCode = response.response?.statusCode else {
                    failure(value.message ?? "")
                    return
                }
                
                print("response ----> ", response.result.value?.toJSON() as Any)
                
                if (200..<300).contains(statusCode){
                    success(statusCode,value)
                }else if statusCode == 401{
                    Utility.hideIndicator()
                    Utility.removeUserData()
                    Utility.setLoginRoot()
                    //                    failure(value.message ?? "")
                }else{
                    failure(value.message ?? "")
                }
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }
    
    func requestAPIWithGetMethod(method: HTTPMethod,urlString: String,success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
        
        if isConnectedToNetwork() == false {
            failure("No internet available.")
            return
        }
        print("url ----> ", urlString)
        print("headers ----> ", getHeader())
        
        Alamofire.request(urlString, method: method, parameters: nil, encoding: JSONEncoding.default, headers: getHeader()).responseObject { (response: DataResponse<Response>) in
            switch response.result{
            case .success(let value):
                guard let statusCode = response.response?.statusCode else {
                    failure(value.message ?? "")
                    return
                }
                
                print("response ----> ", response.result.value?.toJSON() as Any)
                
                if (200..<300).contains(statusCode){
                    success(statusCode,value)
                }else if statusCode == 401{
                    //                    failure(value.message ?? "")
                    Utility.hideIndicator()
                    Utility.removeUserData()
                    Utility.setLoginRoot()
                }else{
                    failure(value.message ?? "")
                }
                break
            case .failure(let error):
                failure(error.localizedDescription)
                break
            }
        }
    }
    
    func requestWithImage(urlString: String,imageParameterName: String,images: Data?,videoParameterName: String,videoData: Data?,audioParameterName: String,audioData: Data?,bgThumbnailParameter: String,bgThumbImage: Data?,parameters: [String:Any],success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
        
        if isConnectedToNetwork() == false {
            failure("No internet available.")
            return
        }
        print("url ----> ", urlString)
        print("parameters ----> ", parameters)
        print("headers ----> ", getHeader())
        
        Alamofire.upload(multipartFormData:{(multipartFormData) in
            if let image = images{
                multipartFormData.append(image, withName: imageParameterName,fileName: getFileName()+".jpg", mimeType: "image/jpg")
            }
            if let video = videoData{
                //                do {
                //                    let data = try Data(contentsOf: video, options: .mappedIfSafe)
                //                    print(data)
                multipartFormData.append(video, withName: videoParameterName, fileName: getFileName()+".mp4", mimeType: "video/mp4")
                //                } catch  {
                //                }
                if let thumbImage = bgThumbImage{
                    multipartFormData.append(thumbImage, withName: bgThumbnailParameter,fileName: getFileName()+".jpg", mimeType: "image/jpg")
                }
            }
            if let audio = audioData{
                //                do {
                //                    let data = try Data(contentsOf: audio)
                //                    print(data)
                multipartFormData.append(audio, withName: audioParameterName, fileName: getFileName()+".mp3", mimeType: "audio/m4a")
                //                } catch  {
                //                }
            }
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to:urlString,headers:getHeader()){ (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    SVProgressHUD.showProgress(Float(progress.fractionCompleted), status: "Uploading...")
                })
                
                upload.responseObject { (response: DataResponse<Response>) in
                    switch response.result{
                    case .success(let value):
                        guard let statusCode = response.response?.statusCode else {
                            failure(value.message ?? "")
                            return
                        }
                        
                        print("response ----> ", response.result.value?.toJSON() as Any)
                        if (200..<300).contains(statusCode){
                            success(statusCode,value)
                        }else if statusCode == 401{
                            //                            failure(value.message ?? "")
                            Utility.hideIndicator()
                            Utility.removeUserData()
                            Utility.setLoginRoot()
                        }else{
                            failure(value.message ?? "")
                        }
                        break
                    case .failure(let error):
                        failure(error.localizedDescription)
                        break
                    }
                    
                }
            case .failure(let error):
                failure(error.localizedDescription)
            }
        }
    }
    
    /*
     func requestWithUploadVideo(urlString: String,imageParameterName: String,images: Data?,videoParameterName: String,videoURL: URL?,parameters: [String:Any],uploadProgress: @escaping (_ val : Double) -> (),success: @escaping(Int,Response) -> (),failure : @escaping(String) -> ()){
     
     if isConnectedToNetwork() == false {
     failure("No internet available.")
     return
     }
     print("url ----> ", urlString)
     print("parameters ----> ", parameters)
     print("headers ----> ", getHeader())
     
     Alamofire.upload(multipartFormData:{(multipartFormData) in
     if let image = images{
     multipartFormData.append(image, withName: imageParameterName,fileName: getFileName()+".jpg", mimeType: "image/jpg")
     }
     if let video = videoURL{
     do {
     let data = try Data(contentsOf: video, options: .mappedIfSafe)
     print(data)
     multipartFormData.append(data, withName: videoParameterName, fileName: getFileName()+".mp4", mimeType: "video/mp4")
     } catch  {
     }
     }
     for (key, value) in parameters {
     multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
     }
     }, to:urlString,headers:getHeader()){ (result) in
     switch result {
     case .success(let upload, _, _):
     
     upload.uploadProgress(closure: { (progress) in
     print("Upload Progress: \(progress.fractionCompleted)")
     uploadProgress(progress.fractionCompleted)
     })
     
     upload.responseObject { (response: DataResponse<Response>) in
     switch response.result{
     case .success(let value):
     guard let statusCode = response.response?.statusCode else {
     failure(value.message ?? "")
     return
     }
     
     print("response ----> ", response.result.value?.toJSON() as Any)
     
     if (200..<300).contains(statusCode){
     success(statusCode,value)
     }else if statusCode == 401{
     //                            failure(value.message ?? "")
     Utility.hideIndicator()
     Utility.removeUserData()
     Utility.setLoginRoot()
     }else{
     failure(value.message ?? "")
     }
     break
     case .failure(let error):
     failure(error.localizedDescription)
     break
     }
     
     }
     case .failure(let error):
     failure(error.localizedDescription)
     }
     }
     }
     */
}
