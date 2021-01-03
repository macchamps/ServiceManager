//
//  BTServiceManager.swift
//  uClinic
//
//  Created by Viral Shah on 26/04/18.
//  Copyright © 2018 Viral Shah. All rights reserved.s
//

import Foundation
import Alamofire

let Webservice = ServiceManager.shared

class ServiceManager: NSObject {
    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    var isLoderRequire: Bool = true
    var viewController : UIViewController = UIViewController()
    
    // MARK: - SHARED MANAGER
    static let shared = ServiceManager()
    func callGETApi(_ url: String, isLoaderRequired: Bool, headers : [String:String]?, andCompletion completion: @escaping (_ isSuccess: Bool, _ statusCode: Int, _ message: String, _ data: NSDictionary) -> Void) {
        callApi(.get, url: url, paramters: nil, headers: headers, isLoaderRequired: isLoaderRequired, andCompletion: completion)
    }
    
    func callPostAPI(_ url: String, isLoaderRequired: Bool, paramters: [String: Any]?, headers : [String:String]?, andCompletion completion: @escaping (_ isSuccess: Bool, _ statusCode: Int, _ message: String, _ data: NSDictionary) -> Void) {
        callApi(.post, url: url, paramters: paramters, headers: headers, isLoaderRequired: isLoaderRequired, andCompletion: completion)
    }
    
    func callPostAPIWithRowData(_ url: String, isLoaderRequired: Bool, paramters: [String: Any]?, headers : [String:String]?, andCompletion completion: @escaping (_ isSuccess: Bool, _ statusCode: Int, _ message: String, _ data: NSDictionary) -> Void) {
        callApiWithRowData(.post, url: url, paramters: paramters, headers: headers, isLoaderRequired: isLoaderRequired, andCompletion: completion)
    }
    

    fileprivate func callApi(_ method: HTTPMethod, url: String, paramters: [String: Any]?, headers : [String:String]?, isLoaderRequired: Bool, andCompletion completion: @escaping (_ isSuccess: Bool, _ statusCode: Int, _ message: String, _ data: NSDictionary) -> Void) {
        
        if !IS_INTERNET_AVAILABLE() {
            SHOW_INTERNET_ALERT()
            return
        }
        
        //        let headers:[String:String] = headers!
        
        if isLoaderRequired {
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewController)
        }
        
        print("*************** URL : \(url) ***************** \n ************** PARAMTERS **************** \n \(String(describing: paramters)) \n **************** HEADERS *************** \n \(String(describing: headers))")
        
        Alamofire.request(url, method: method, parameters: paramters, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let JSON):
                let dictJSON = JSON as! NSDictionary
                print("RESPONSE: ", dictJSON)
                let status = dictJSON.object_forKeyWithValidationForClass_Int(aKey: "status")
                let Message = dictJSON.object_forKeyWithValidationForClass_String(aKey: "message")
                if status == 200 {
                    completion(true, status, Message, dictJSON)
                } else {
                    completion(false, status, dictJSON.object_forKeyWithValidationForClass_String(aKey: "message"), dictJSON)
                }
            case .failure( _):
                completion(false, 0, "Something went wrong.Please try again later.", NSDictionary())
            }
        }
    }
    
    fileprivate func callApiWithRowData(_ method: HTTPMethod, url: String, paramters: [String: Any]?, headers : [String:String]?, isLoaderRequired: Bool, andCompletion completion: @escaping (_ isSuccess: Bool, _ statusCode: Int, _ message: String, _ data: NSDictionary) -> Void) {
        
        if !IS_INTERNET_AVAILABLE() {
            SHOW_INTERNET_ALERT()
            return
        }
        
        //        let headers:[String:String] = headers!
        
        if isLoaderRequired {
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewController)
        }
        
        print("*************** URL : \(url) ***************** \n ************** PARAMTERS **************** \n \(String(describing: paramters)) \n **************** HEADERS *************** \n \(String(describing: headers))")
        Alamofire.request(url, method: method, parameters: paramters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
//        Alamofire.request(url, method: method, parameters: paramters, headers: headers).responseJSON { (response) in
            
            switch response.result {
            case .success(let JSON):
                let dictJSON = JSON as! NSDictionary
                print("RESPONSE: ", dictJSON)
                let status = dictJSON.object_forKeyWithValidationForClass_Int(aKey: "status")
                if status == 200 {
                    completion(true, status, "Success", dictJSON)
                } else {
                    let message = dictJSON.object_forKeyWithValidationForClass_String(aKey: "message")
                    completion(false, status, message, NSDictionary())
                }
            case .failure( _):
                print("RESPONSE: ", "Something went wrong.Please try again later.")
                completion(false, 0, "Something went wrong.Please try again later.", NSDictionary())
            }
        }
    }
    
    func callUPLOADApi(url : String, imagesData: [String : Any], isLoaderRequired: Bool , params : [String : Any]?, headers : [String:String]?, onSuccess : @escaping ( _ isSuccess: Bool,  _ statusCode: Int,  _ message: String,  _ data: NSDictionary) -> Void) {
        
        print("\n\n\n\n\nURL : \(url) \nPARAM : \(params!) \nHEADERS : \(headers!) \nImages : \(imagesData)")
        
        if isLoaderRequired {
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewController)
        }
        
        Alamofire.upload(multipartFormData:{
            multipartFormData in
            if let params = params {
                for eachKey in params.keys {
                    if let value = params[eachKey] as? String {
                        print("Values:\(value) & Key:\(eachKey)")
                        multipartFormData.append(value.data(using: .utf8)!, withName: eachKey)
                        print(multipartFormData.contentLength)
                    }else if let value = params[eachKey] as? Int{
                        print("Values:\(value) & Key:\(eachKey)")
                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: eachKey)
                        print(multipartFormData.contentLength)
                    }else if let value = params[eachKey] as? UIImage {
                        if let imageData = value.jpeg(.medium) {
                            multipartFormData.append(imageData, withName: eachKey, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                            print(multipartFormData.contentLength)
                        }
                    }
                }
            }
            

                for eachKey in imagesData.keys {
                    if let value = imagesData[eachKey] as? UIImage {
                        if let imageData = value.jpeg(.medium) {
                            multipartFormData.append(imageData, withName: eachKey, fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                            print(multipartFormData.contentLength)
                        }
                        }else if let value = imagesData[eachKey] as? String {
                            print("Values:\(value) & Key:\(eachKey)")
                            multipartFormData.append(value.data(using: .utf8)!, withName: eachKey)
                            print(multipartFormData.contentLength)
                        }
                    }
            },
                         usingThreshold:UInt64.init(),
                         to:url,
                         method:.post,
                         headers:headers,
                         encodingCompletion: { encodingResult in
                            
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    if let result = response.result.value {
                                        let dictJSON = result as! NSDictionary
                                        print("RESPONSE: ", dictJSON)
                                        let status = dictJSON.value(forKey: "status") as? Int
                                        if status == 200 {
                                            onSuccess(true, status!, dictJSON.value(forKey: "message") as? String ?? "Success", dictJSON)
                                        } else {
                                            onSuccess(false, status!, dictJSON.value(forKey: "message") as? String ?? "", NSDictionary())
                                        }
                                    } else {
                                        onSuccess(false, 0, "Something went wrong.Please try again later.", NSDictionary())
                                    }
                                }
                            case .failure(let encodingError):
                                print("ERR: UPLOAD: \(encodingError.localizedDescription)")
                                onSuccess(false, 0, "Something went wrong.Please try again later.", NSDictionary())
                            }
        })
    }
    
    func callUPLOADFileApi(url : String, filedata: [[String : Any]], isLoaderRequired: Bool , params : [String : Any]?, headers : [String:String]?, onSuccess : @escaping ( _ isSuccess: Bool,  _ statusCode: Int,  _ message: String,  _ data: NSDictionary) -> Void) {
             
     //        print("\n\n\n\n\nURL : \(url) \nPARAM : \(params!) \nHEADERS : \(headers!) \nFileArray : \(filedata)")
             let manager = Alamofire.SessionManager.default
             manager.session.configuration.timeoutIntervalForRequest = 1200
             if isLoaderRequired {
                 ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewController)
             }
             
             manager.upload(multipartFormData:{
                 multipartFormData in
                 
                 if let params = params {
                     print("PARAM:\(params)")
                     for eachKey in params.keys {
                         if let value = params[eachKey] as? String {
                             print("Value:\(value) Key:\(eachKey)")
                             multipartFormData.append(value.data(using: .utf8)!, withName: eachKey)
                         }else if let value = params[eachKey] as? Int {
                             print("Value:\(value) Key:\(eachKey)")
                             multipartFormData.append("\(value)".data(using: .utf8)!, withName: eachKey)
                         }
                         else if let value1 = params[eachKey] as? [[String:Any]]{
                              print("Value:\(value1) Key:\(eachKey)")
                                 if let jsonData = try? JSONSerialization.data(withJSONObject: value1, options:[]) {
                                     multipartFormData.append(jsonData, withName: eachKey as String)
                                 }
                             }
                         }
                     }
                 
                 for dict in filedata{
                  
                         multipartFormData.append(dict["data"] as! Data , withName: dict["name_param"] as! String, fileName: dict["file_name"] as! String, mimeType: dict["file_type"] as! String)
                 
                 }
             },
                              usingThreshold:UInt64.init(),
                              to:url,
                              method:.post,
                              headers:headers,
                              encodingCompletion: { encodingResult in
                                 
                                 print("\n\n\n\n\nURL : \(url) \nPARAM : \(params!) \nHEADERS : \(headers!) \nFileArray : \(MultipartFormData.self)")
                                 switch encodingResult {
                                 case .success(let upload, _, _):
                                     upload.responseJSON { response in
                                         if let result = response.result.value {
                                             let dictJSON = result as! NSDictionary
                                             print("RESPONSE: ", dictJSON)
                                             // let status = dictJSON.object_forKeyWithValidationForClass_Int(aKey: "status")
                                             let status = dictJSON.value(forKey: "status") as? Int
                                             if status == 200 {
                                                 onSuccess(true, status!,dictJSON.value(forKey: "message") as? String ?? "Success", dictJSON)
                                             } else {
                                                 onSuccess(false, status!, dictJSON.value(forKey: "message") as? String ?? "Fail", NSDictionary())
                                             }
                                         } else {
                                             onSuccess(false, 0, "Response Fail", NSDictionary())
                                         }
                                     }
                                 case .failure(let encodingError):
                                     print("ERR: UPLOAD: \(encodingError.localizedDescription)")
                                     onSuccess(false, 0, "Response Fail", NSDictionary())
                                 }
             })
         }
}
//MARK: MetaDataAPIModel
extension ServiceManager{
//    MARK:- Get School Data
    func apiCWMetaGetSchool(_ param:[String: Any], andCompletion completion: @escaping (_ isSuccess: Bool,_ Schools:[CWMetaData]) -> Void){
        Webservice.callGETApi(urlSchoolMetaData, isLoaderRequired: false, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
             {
                 if let dict = data["data"] as? [[String:Any]]{
                            let Schools:[CWMetaData] = MetaDataObj.initMetaArray(with: dict)
                        if let dictIntro = data["intro"] as? [[String:Any]]{
                            Intro = IntroObj.initIntroArray(with: dictIntro)
                        }
                           completion(true,Schools)
                 }else{
                     if let message = data["message"] as? String{
                         print(message)
                       showBannner(title: message, type: .error)
                     }
                     completion(false,[])
                 }
             }else{
                 Utilities.showPopup(title: message, type: .error)
                 completion(false,[])
             }
        }
    }
//MARK:- Get Program Data
    func apiCWMetaGetProgram(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ Program:[CWMetaData]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlprogramMetaData, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     if let dict = data["data"] as? [[String:Any]]{
                                let Program:[CWMetaData] = MetaDataObj.initMetaArray(with: dict)
                               completion(true,Program)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
                           showBannner(title: message, type: .error)
                         }
                         completion(false,[])
                     }
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                          completion(false,[])
                 }
     }
    }
//MARK:- Get Program Data
    func apiCWMetaGetTerm(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ Term:[CWMetaData]) -> Void){
    ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
 Webservice.callPostAPI(urlTermMetaData, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
        if statusCode == 200
             {
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                 if let dict = data["data"] as? [[String:Any]]{
                            let Term:[CWMetaData] = MetaDataObj.initMetaArray(with: dict)
                           completion(true,Term)
                 }else{
                     if let message = data["message"] as? String{
                         print(message)
                       showBannner(title: message, type: .error)
                     }
                     completion(false,[])
                 }
             }
             else{
                 Utilities.showPopup(title: message, type: .error)
                 ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                         completion(false,[])
             }
 }
}
//MARK:- Get Program Data
    func apiCWMetaGetGroup(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ Group:[CWMetaData]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlGroupMetaData, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     if let dict = data["data"] as? [[String:Any]]{
                                let group:[CWMetaData] = MetaDataObj.initMetaArray(with: dict)
                               completion(true,group)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
                           showBannner(title: message, type: .error)
                         }
                         completion(false,[])
                     }
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                         completion(false,[])
                 }
     }
    }
    
}
//MARK: SignupAPIModel
extension ServiceManager{
  //    MARK:User SingupAPI
    func apiCWSingupApi(_ viewcontroller:UIViewController,_ param:[String:Any],_ profiImg:UIImage, andCompletion completion: @escaping (_ isSuccess: Bool,_ message:String) -> Void){
      ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
       let imgData = [kImage:profiImg]
    Webservice.callUPLOADApi(url:urlsignUp, imagesData: imgData, isLoaderRequired: true, params: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderContentType:ContentType])
       { (isSuccess, statusCode, message, data) in
          if statusCode == 200
          {
            if (data["data"] as? [String:Any]) != nil{
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(true, message)
              }else{
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                  if let message = data["message"] as? String{
                      print(message)
                        completion(true,message)
                  }else{
                    completion(true,message)
                }
              }
          }else{
//             Utilities.showPopup(title: message, type: .error)
              ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
              completion(false,message)
          }
      }
  }
   //MARK:- Email Login
    func apiCWLoginPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ message:String) -> Void){
     ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
  
    Webservice.callPostAPI(urlLogin, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken()]) { (isSuccess, statusCode, message, data) in
         if statusCode == 200
              {
                  if let dict = data["data"] as? [String:Any]{
                      print("\(dict)")
                        let Email:String = param[kEmail] as! String
                        let Password:String = param[kPassword] as! String
                        User.setUserDetails(dictUserDetails: dict)
                        User.saveUser()
                        setUserDefaultsValue(Email, TLEmail)
                        setUserDefaultsValue(Password, TLPassword)
                        setUserDefaultsValue(0, TLSocialLogin)
                        setUserDefaultsValue(User.getRoleID(), TLUserType)
                        
                        user_type = "\(getUserDefaultsValue(TLUserType) as! Int)"
                        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    completion(true, message)
                  }else{
                      ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                      if let message = data["message"] as? String{
                          print(message)
                        
                        completion(false, message)
                      }else{
                        completion(false, message)
                    }
                  }
              }
              else{
//                  Utilities.showPopup(title: message, type: .error)
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false, message)
              }
  }
 }
    //MARK:- ForgetPassword API
    func apiCWForgetPassword(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlForgetPwd, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- ResetPassword API
    func apiCWResetPassword(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlResetPassword, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- OTPVerify API
    func apiCWOTPVerify(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlOTPVerify, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
}
//MARK: Document Student API
extension ServiceManager{
    func apiCWMandotaryDocument(_ param:[String: Any], andCompletion completion: @escaping (_ isSuccess: Bool, _ FolderList:[CWCategoryMandotary],_ progress:Float,_ covid:Int,_ CovidStatus:Int) -> Void){
        Webservice.callPostAPI(urlMandatoryDocuments, isLoaderRequired: true, paramters: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                if let dict = data["data"] as? [[String:Any]]{
                   let MetaData:[CWCategoryMandotary] = ManFolderObj.initCategoryArray(with: dict)
                   let progress = data["progress"] as? String ?? "0"
                   let covid = data["is_active_covid_assesment"] as? Int ?? 0
                    let status = data["covid_status"] as? Int ?? 0
                    let intPro:Float = progress.floatValue
                    completion(true, MetaData,intPro,covid,status)
                }else{
                    if let message = data["message"] as? String{
                        print(message)
                      showBannner(title: message, type: .error)
                    }
                   completion(true, [],0,0,3)
                }
            }else{
                Utilities.showPopup(title: message, type: .error)
                completion(false,[],0,0,3)
            }
        }
    }
    //MARK:- Document List API
    func apiCWDocumentListPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ documentList:[CWDocument],_ parentFolderID:Int,_ Allowed:Int,_ Uploaded:Int) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
     Webservice.callPostAPI(urlDocumentList, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let dict = data["data"] as? [[String:Any]]{
                        let parentID:Int = data["previous_folder_id"] as? Int ?? 0
                        let Uploaded:Int = data["total_document_uploaded"] as? Int ?? 0
                        let Allowed:Int = data["total_documents_allowed"] as? Int ?? 0
                        let listDocument:[CWDocument] = documentObj.initDocumentArray(with: dict)
                           ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                           completion(true,listDocument,parentID,Allowed,Uploaded)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
//                           showBannner(title: message, type: .success)
                         }
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,[], 9999,0,0)
                     }
                 }
                 else{
//                     Utilities.showPopup(title: message, type: .error)
                let Uploaded:Int = data["total_document_uploaded"] as? Int ?? 0
                let Allowed:Int = data["total_documents_allowed"] as? Int ?? 0
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    completion(false,[], 9999,Allowed,Uploaded)
                 }
     }
    }
    //MARK:- Craete Folder API
    func apiCWDocumentCreateFolder(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlCreateFolder, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- Craete File API
    func apiCWDocumentCreateFile(_ param:[String: Any],fileData:[[String:Any]],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        Webservice.callUPLOADFileApi(url: urlCreateFile, filedata: fileData, isLoaderRequired: true, params: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                if let message = data["message"] as? String{
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                  showBannner(title: message, type: .success)
                }
                completion(true)
            }
            else{
                Utilities.showPopup(title: message, type: .error)
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false)
            }
        }
    }
    func apiCWDocumentCreateS3File(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        Webservice.callPostAPI(urlCreateS3File, isLoaderRequired: true, paramters: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                if let message = data["message"] as? String{
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                  showBannner(title: message, type: .success)
                }
                completion(true)
            }
            else{
                Utilities.showPopup(title: message, type: .error)
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false)
            }
        }
    }
    //MARK:- Move File API
    func apiCWDocumentMoveFile(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlMoveFile, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }else{
                        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        showBannner(title: message, type: .success)
                    }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- Rename Dir API
    func apiCWDocumentRenameDir(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlRenameFolder, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }else{
                        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        showBannner(title: message, type: .success)
                    }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- Document List API
    func apiCWDocumentDeletePost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlDeleteDocuments, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                        if (data["data"] as? [String:Any]) != nil{
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                               completion(true)
                         }else{
                             if let message = data["message"] as? String{
                                 print(message)
                               showBannner(title: message, type: .success)
                             }else{
                               showBannner(title: message, type: .success)
                            }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true)
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false)
                     }
         }
        }
    //MARK:- Profile Get API
    func apiCWStudentProfileTabGetPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ UserDetails:CWStudentProfileTab) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlStudentProfileTab, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         if let dataList = data["data"] as? [[String:Any]]{
                            let User:CWStudentProfileTab = ProfileTabObj.initStudent(with: dataList[0])
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true, User)
                         }else{
                             if let message = data["message"] as? String{
                                 print(message)
                               showBannner(title: message, type: .success)
                             }else{
                               showBannner(title: message, type: .success)
                            }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(false,CWStudentProfileTab())
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false,CWStudentProfileTab())
                     }
         }
        }
    //MARK:- Document List API
    func apiCWProfileGetPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ UserDetails:CWUserProfile) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlUserProfile, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         if let dataList = data["data"] as? [[String:Any]]{
                            let User:CWUserProfile = ProfileObj.initUserProfile(with: dataList[0])
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true, User)
                         }else{
                             if let message = data["message"] as? String{
                                 print(message)
                               showBannner(title: message, type: .success)
                             }else{
                               showBannner(title: message, type: .success)
                            }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(false,CWUserProfile())
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false,CWUserProfile())
                     }
         }
        }
    //MARK:- Profile Upload API
     func apiCWProfileUpdate(_ viewcontroller:UIViewController,_ param:[String:Any],_ profiImg:UIImage, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
         ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
          let imgData = [kImage:profiImg]
       Webservice.callUPLOADApi(url:urlProfileUpdate, imagesData: imgData, isLoaderRequired: true, params: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()])
          { (isSuccess, statusCode, message, data) in
             if statusCode == 200
             {
                 if let dict = data["data"] as? [String:Any]{
                     print("\(dict)")
                        User.setUserDetails(dictUserDetails: dict)
                        User.saveUser()
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(true)
                 }else{
                     if let message = data["message"] as? String{
                         print(message)
                        //Utilities.showPopup(title: message, type: .success)
                     }
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(true)
                 }
             }
             else{
                Utilities.showPopup(title: message, type: .error)
                 ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                 completion(false)
             }
         }
     }
    //MARK:- ContactUS API
    func apiCWContactus(_ viewcontroller:UIViewController,_ param:[String:Any],_ profiImg:UIImage, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        var imgData:[String:Any] = [:]
        if profiImg.size.height != 0{
         imgData = [kImage:profiImg]
        }else{
            imgData = [:]
        }
      Webservice.callUPLOADApi(url:urlContactUS, imagesData: imgData, isLoaderRequired: true, params: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:urlContactUS,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()])
         { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                    if let message = data["message"] as? String{
                        print(message)
                        Utilities.showPopup(title: message, type: .success)
                    }else{
                        Utilities.showPopup(title: message, type: .success)
                    }
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    completion(true)
            }
            else{
               Utilities.showPopup(title: message, type: .error)
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false)
            }
        }
    }
    func apiCWContactus(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlContactUS, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- Change Password API
    func apiCWChangePassword(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlChangePassword, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
    //MARK:- Document List API
    func apiCWMandotoryDocumentListPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ folder:CWDocumentMandotary,_ commentList:[CWDocumentComment],_ allowed:Int,_ Upload:Int) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
         Webservice.callPostAPI(urlMandatoryDocumentsList, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         if let dataList = data["data"] as? [[String:Any]]{
                            let dict = data["document"] as? [String:Any] ?? [:]
                            let Allowed:Int = data["total_document_allowed"] as? Int ?? 0
                            let Uploaded:Int = data["count_document_uploaded"] as? Int ?? 0
                            let listComment:[CWDocumentComment] = commentObj.initDocumentArray(with: dataList)
                            let folder:CWDocumentMandotary = CWDocumentMandotary.shared.initDocCategory(with: dict)
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                               completion(true,folder,listComment,Allowed,Uploaded)
                         }else{
                            let Allowed:Int = data["total_document_allowed"] as? Int ?? 0
                            let Uploaded:Int = data["count_document_uploaded"] as? Int ?? 0
                             if let message = data["message"] as? String{
                                 print(message)
    //                           showBannner(title: message, type: .success)
                             }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true,CWDocumentMandotary(),[],Allowed,Uploaded)
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                        let Allowed:Int = data["total_document_allowed"] as? Int ?? 0
                        let Uploaded:Int = data["count_document_uploaded"] as? Int ?? 0
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false,CWDocumentMandotary(), [],Allowed,Uploaded)
                     }
         }
        }
    //MARK:- Delete Mandotory Document API
    func apiCWMandotoryDocumentDeletePost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlDeleteMandatoryDocuments, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                        if (data["data"] as? [String:Any]) != nil{
                                
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                               completion(true)
                         }else{
                             if let message = data["message"] as? String{
                                 print(message)
                               showBannner(title: message, type: .success)
                             }else{
                               showBannner(title: message, type: .success)
                            }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true)
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false)
                     }
         }
        }

}
//MARK: Document Intructor API
extension ServiceManager{
//MARK:- Craete File API
    func apiCWManDocumentUpload(_ param:[String: Any],fileData:[[String:Any]],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ documentID:Int) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        Webservice.callUPLOADFileApi(url: urlMandatoryDocumentsUpload, filedata: fileData, isLoaderRequired: true, params: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                let documentID:Int = data["id"] as? Int ?? 0
                if let message = data["message"] as? String{
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                  showBannner(title: message, type: .success)
                }
                completion(true,documentID)
            }
            else{
                Utilities.showPopup(title: message, type: .error)
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false, 0)
            }
        }
    }
    func apiCWManDocumentS3Upload(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ documentID:Int) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        Webservice.callPostAPI(urlMandatoryS3DocumentsUpload, isLoaderRequired: true, paramters: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()])
        { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                let documentID:Int = data["id"] as? Int ?? 0
                if let message = data["message"] as? String{
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                  showBannner(title: message, type: .success)
                }
                completion(true,documentID)
            }
            else{
                Utilities.showPopup(title: message, type: .error)
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false, 0)
            }
        }
    }
//MARK:- Craete Folder API
    func apiCWINDocumentCreateFolder(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlINCreateFolder, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let message = data["message"] as? String{
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       showBannner(title: message, type: .success)
                     }
                     completion(true)
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     completion(false)
                 }
     }
    }
//MARK:- Craete File API
    func apiCWINDocumentCreateFile(_ param:[String: Any],fileData:[[String:Any]],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        Webservice.callUPLOADFileApi(url: urlINCreateFile, filedata: fileData, isLoaderRequired: true, params: param, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
            {
                if let message = data["message"] as? String{
                  ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                  showBannner(title: message, type: .success)
                }
                completion(true)
            }
            else{
                Utilities.showPopup(title: message, type: .error)
                ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false)
            }
        }
    }
//MARK:- StudentList API
    func apiCWStudentsListPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ studentList:[CWStudent]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
     Webservice.callPostAPI(urlStudentsList, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let dict = data["data"] as? [[String:Any]]{
                        let listStudent:[CWStudent] = StudentObj.initStudentArray(with: dict)
                           ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,listStudent)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
//                           showBannner(title: message, type: .success)
                         }
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,[])
                     }
                 }
                 else{
//                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false,[])
                 }
     }
    }
//    MARK:-Student Profile Api
    func apiCWStudentsProfilePost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ studentProfile:CWStudentWithDocuments) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlStuentProfile, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         if let dict = data["data"] as? [[String:Any]]{
                            let studentInfo:CWStudentWithDocuments = StudentInfoObj.initStudent(with: dict[0])
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true,studentInfo)
                         }else{
                             if let message = data["message"] as? String{
                                 print(message)
    //                           showBannner(title: message, type: .success)
                             }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true,CWStudentWithDocuments())
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    completion(false,CWStudentWithDocuments())
                     }
         }
        }
//MARK:- Document List API
    func apiCWStudentDocumentListPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ folder:CWDocumentMandotary,_ commentList:[CWDocumentComment]) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlStudentCommentList, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         if let dataList = data["data"] as? [[String:Any]]{
                            let dict = data["document"] as? [String:Any] ?? [:]
                            let listComment:[CWDocumentComment] = commentObj.initDocumentArray(with: dataList)
                            let folder:CWDocumentMandotary = CWDocumentMandotary.shared.initDocCategory(with: dict)
                               ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                               completion(true,folder,listComment)
                         }else{
                             if let message = data["message"] as? String{
                                 print(message)
    //                           showBannner(title: message, type: .success)
                             }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true,CWDocumentMandotary(),[])
                         }
                     }
                     else{
    //                     Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false,CWDocumentMandotary(), [])
                     }
         }
        }
//MARK:- Document List API
    func apiCWDocumentReivew(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlDocumentReview, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         
                             if let message = data["message"] as? String{
                                 print(message)
                               showBannner(title: message, type: .success)
                             }else{
                               showBannner(title: message, type: .success)
                            }
                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true)
                     }
                     else{
                         Utilities.showPopup(title: message, type: .error)
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false)
                     }
         }
        }
//MARK:- Document Link Status API
    func apiCWDocumentLinkStatus(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
//            ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlDocumentLinkStatus, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         
                             if let message = data["message"] as? String{
                                 print(message)
//                               showBannner(title: message, type: .success)
                             }else{
//                               showBannner(title: message, type: .success)
                            }
//                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true)
                     }
                     else{
//                         Utilities.showPopup(title: message, type: .error)
//                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false)
                     }
         }
        }
//MARK:- MandotoryDocument Link Status API
    func apiCWMandotoryDocumentLinkStatus(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
//            ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
         Webservice.callPostAPI(urlMandotoryDocumentLinkStatus, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         
                             if let message = data["message"] as? String{
                                 print(message)
//                               showBannner(title: message, type: .success)
                             }else{
//                               showBannner(title: message, type: .success)
                            }
//                             ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true)
                     }
                     else{
//                         Utilities.showPopup(title: message, type: .error)
//                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false)
                     }
         }
        }
//MARK:- Logout API
    func apiCWLogout(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
         Webservice.callPostAPI(urlLogout, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                            completion(true)
                     }
                     else{
                        completion(false)
                     }
         }
        }
//MARK:- PromoCode API
    func apiCWPromoCode(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
         Webservice.callPostAPI(urlApplyPromoCode, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
                if statusCode == 200
                     {
                         if let message = data["message"] as? String{
                             print(message)
//                           showBannner(title: message, type: .success)
                         }else{
//                           showBannner(title: message, type: .success)
                        }
                        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                            completion(true)
                     }
                     else{
                    Utilities.showPopup(title: message, type: .error)
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(false)
                     }
         }
        }
//MARK:- SearchStudentList API
    func apiCWSearchStudentsListPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ studentList:[CWStudent]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
     Webservice.callPostAPI(urlSearchStudent, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let dict = data["data"] as? [[String:Any]]{
                        let listStudent:[CWStudent] = StudentObj.initStudentArray(with: dict)
                           ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,listStudent)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
//                           showBannner(title: message, type: .success)
                         }
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,[])
                     }
                 }
                 else{
//                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false,[])
                 }
     }
    }
//MARK:- FilterGroupList API
    func apiCWFilterGroupListPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ groupFilterList:[CWFilter]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
     Webservice.callPostAPI(urlFilterGroupList, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let dict = data["data"] as? [[String:Any]]{
                        let list:[CWFilter] = filterObj.initFilterArray(with: dict)
                           ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,list)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)

                         }
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,[])
                     }
                 }
                 else{

                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false,[])
                 }
     }
    }
//MARK:- FilterGroupResult API
    func apiCWFilterGroupResultPost(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ groupFilterResult:[CWStudent]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlFilterGroupResult, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                     if let dict = data["data"] as? [[String:Any]]{
                        let list:[CWStudent] = StudentObj.initStudentArray(with: dict)
                           ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,list)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
//                           showBannner(title: message, type: .success)
                         }
                         ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                        completion(true,[])
                     }
                 }
                 else{
//                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                completion(false,[])
                 }
     }
    }
//MARK:- Get Settings ProgressBar
    func apiCWGetSettingsProgressBar(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ allowed:Int,_ uploaded:Int) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
        Webservice.callGETApi(urlSettingsProgress, isLoaderRequired: true, headers: [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
               if statusCode == 200
                    {
                       ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                               let Allowed = data["total_documents_allowed"] as? Int ?? 0
                               let Uploaded = data["total_document_uploaded"] as? Int ?? 0
                              completion(true,Allowed,Uploaded)
                    }
                    else{
                        Utilities.showPopup(title: message, type: .error)
                        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                       completion(false,0,0)
                    }
        }
    }
}
//MARK:- Covid19
extension ServiceManager{
    //MARK:- Get Questions Data
    func apiCWMetaCovidQuestions(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ Question:[CWQuestions]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlQuestions, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     if let dict = data["data"] as? [[String:Any]]{
                               let Questions:[CWQuestions] = QuestionsObj.initQuestionsArray(with: dict)
                               completion(true,Questions)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
                           showBannner(title: message, type: .error)
                         }
                         completion(false,[])
                     }
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                         completion(false,[])
                 }
     }
    }
    //MARK:- Get Answers Data
    func apiCWMetaCovidAnswers(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlCovidAnswer, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    if (data["data"] as? [[String:Any]]) != nil{
                               showBannner(title: "Your form is submitted", type: .success)
                               completion(true)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
                           showBannner(title: message, type: .success)
                         }
                         completion(true)
                     }
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                         completion(false)
                 }
     }
    }
    //MARK:- Get StudentAnswers Data
    func apiCWCovidAnswersData(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ Answers:[CWAnswers]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlCovidAnswerData, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     if let dict = data["data"] as? [[[String:Any]]]{
                               let Answers:[CWAnswers] = AnswersObj.initAnswersArray(with: dict)
                               
                               completion(true,Answers)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
                           showBannner(title: message, type: .error)
                         }
                        completion(false,[])
                     }
                 }
                 else{
                     Utilities.showPopup(title: message, type: .error)
                     ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    completion(false,[])
                 }
     }
    }
    //MARK:- Get StudentAnswers Data
    func apiCWCovidAnswersInstructorData(_ param:[String: Any],viewcontroller:UIViewController, andCompletion completion: @escaping (_ isSuccess: Bool,_ Answers:[CWAnswers]) -> Void){
        ActivityIndicator.sharedInstance.showHUD(show: true, VC: viewcontroller)
     Webservice.callPostAPI(urlCovidInstructorAnswer, isLoaderRequired: true, paramters: param, headers:  [HeaderXApiKey : XAPIKey,HeaderDeviceType:DeviceType,HeaderDeviceToken:self.getDeviceToken(),HeaderIDKey:User.getUserID(),HeaderUserToken:User.getUserToken()]) { (isSuccess, statusCode, message, data) in
            if statusCode == 200
                 {
                    ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                     if let dict = data["data"] as? [[[String:Any]]]{
                                let Answers:[CWAnswers] = AnswersObj.initAnswersArray(with: dict)
                                let status = data["covid_status"] as? Int ?? 0
                            completion(true,Answers)
                     }else{
                         if let message = data["message"] as? String{
                             print(message)
                           showBannner(title: message, type: .error)
                         }
                        completion(false,[])
                     }
                 }
                 else{
                        Utilities.showPopup(title: message, type: .error)
                        ActivityIndicator.sharedInstance.showHUD(show: false, VC: viewcontroller)
                    completion(false,[])
                 }
     }
    }
}

//MARK:Images Data Setup
extension ServiceManager{
    func imagesEventSetup(imgs:[[String:Any]])->[String:Any]{
         var arrayImg = [String:Any]()
         for index in 0..<imgs.count {
             if let img = imgs[index]["image"] as? UIImage {
                 arrayImg["obstacles_image[\(index)]"] = img
             }
            if let name = imgs[index]["name"] as? String {
                arrayImg["obstacles_name[\(index)]"] = name
            }
         }
         print(arrayImg)
         return arrayImg
     }
    func imageItemSetup(_ image:[UIImage]) ->[String:Any] {
         var arrayImg = [String:Any]()
        for index in 0..<image.count {
            if let img = image[index] as? UIImage {
                arrayImg["item_image[\(index)]"] = img
            }
        }
        print(arrayImg)
        return arrayImg
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: quality.rawValue)
    }
}
extension Dictionary {
    mutating func merge(_ dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
//MARK:- GetDeviceToken
extension ServiceManager{
    func getDeviceToken()->String{
        if getUserDefaultsValue(NotificationToken) != nil{
            return "\(getUserDefaultsValue(NotificationToken)!)"
        }else{
            return "123456789"
        }
    }
}
