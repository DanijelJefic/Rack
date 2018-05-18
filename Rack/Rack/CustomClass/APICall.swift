//
//  APICall.swift
//  APIDemo
//
//  Created by hyperlink on 8/31/16.
//  Copyright © 2016 hyperlink. All rights reserved.
//

import UIKit
import AFNetworking

let AFAppDotNetAPIBaseURLString : String = kBaseURL

class APICall: AFHTTPSessionManager {

    struct Singleton {
        static var shared = APICall(baseURL: NSURL(string: AFAppDotNetAPIBaseURLString) as URL?)
    }
    
    class var shared: APICall {
        
        //Define status code which we have to accept other then this status code will give directly error message
        let indexs = NSMutableIndexSet()
        indexs.add(200)
        indexs.add(201)
        
        
        Singleton.shared.responseSerializer.acceptableStatusCodes = NSIndexSet(indexSet: indexs as IndexSet) as IndexSet
        Singleton.shared.requestSerializer.setValue(kHeaderAPIKeyValue, forHTTPHeaderField: kHeaderAPIKey)
        Singleton.shared.securityPolicy  = AFSecurityPolicy(pinningMode: .none)
//        Singleton.shared.requestSerializer.cachePolicy = .returnCacheDataElseLoad
        
            //add user token if user is login
        print("Token : ",UserModel.getUserSessionToken())
        Singleton.shared.requestSerializer.setValue(UserModel.getUserSessionToken(), forHTTPHeaderField: kHeaderToken)
        
        return Singleton.shared
    }
    
    //------------------------------------------------------
    
    //MARK: - GET
    
    //GET Method
    //Parameter
    //url :- method name of API like user/login
    //parameter : - parameter which is required to pass in API
    //errorAlert : - pass Bool value to decide if any error occcued then display alert or not
    //isLoader : - to decide if Add loader or not
    //isDebug : - to print request and response in Console
    //completion :- completion block for pass response in class
    
    func GET(strURL url : String
        ,parameter : Dictionary<String,Any>?
        ,withErrorAlert errorAlert : Bool = true
        ,withLoader isLoader : Bool = false
        ,debugLog isDebug : Bool = true
        , withBlock completion :@escaping (Dictionary<String, Any>?,Int,Error?) -> Void) {

      print("*****************URL***********************\n")
      print("URL:- \(url)\n")
      print("Parameter:-\(String(describing: parameter))\n")
      print("MethodType:- GET\n")
      print("*****************End***********************\n")
      
        let urlWithQuerystring = String(url)
        
        var param = Dictionary<String,Any>()
        if parameter != nil {
            param = parameter!
        }
        //This will use to build queryStrign work on AFNetworking
        //TODO: Check for other Framework
        param["format"] = "json"
        
        // add loader if isLoader is true
        if isLoader {
            GFunction.shared.addLoader(nil)
        }
       
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if isDebug {
            //diaplay url scheme in console
            print("*****************URL***********************\n")
            print("\(url) \n ")
            print("****************************************\n")
        }
       
        APICall.shared.get(urlWithQuerystring!
            , parameters: parameter
            , progress: { (progres : Progress) in
                
        }, success: { (task : URLSessionDataTask, response : Any?) in
            
            // remove loader if isLoader is true
            if isLoader {
                GFunction.shared.removeLoader()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            var statusCode = 0
            if let headerResponse = task.response as? HTTPURLResponse {
                statusCode = headerResponse.statusCode
            }
            
            if isDebug {
                print("******************Response**********************\n")
                print(response as! NSDictionary)
                print("****************************************\n")
            }
            
            completion(response as! Dictionary<String, Any>?,statusCode,task.error as Error?)
          
            //Failer Block
        }) { (task : URLSessionDataTask?, error : Error) in
            
            if isLoader {
                GFunction.shared.removeLoader()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            var statusCode = 0

            //Logout User
            if let headerResponse = task!.response as? HTTPURLResponse {

                statusCode = headerResponse.statusCode
                
                if (headerResponse.statusCode == 401) {
                    
                    //TODO: - Add your logout code here
                    GFunction.shared.userLogOut(AppDelegate.shared.window)
                }
            }

            //Display error Alert if errorAlert is true
            if(errorAlert) {
                let err = error as NSError
                if statusCode != 401
                    && err.code != NSURLErrorTimedOut
                    && err.code != NSURLErrorNetworkConnectionLost
                    && err.code != NSURLErrorNotConnectedToInternet{
                
                } else {
                    GFunction.shared.showPopUpAlert(error.localizedDescription)
                }
            }
            completion(nil,statusCode,error)
        }
    }
    
    //------------------------------------------------------

    //MARK: - POST
    
    //POST Method
    //Parameter
    //url :- method name of API like user/login
    //parameter : - parameter which is required to pass in API
    //errorAlert : - pass Bool value to decide if any error occcued then display alert or not
    //isLoader : - to decide if Add loader or not
    //isDebug : - to print request and response in Console
    //blockFormData : - Pass image or array of image if you have to pass in API
    //completion :- completion block for pass response in class

    
    func POST(strURL url : String
        , parameter :  Dictionary<String, Any>?
        ,withErrorAlert errorAlert : Bool = true
        ,withLoader isLoader : Bool = false
        ,debugLog isDebug : Bool = true
        ,constructingBodyWithBlock blockFormData: ((AFMultipartFormData?) -> Void)? = nil
        , withBlock completion : @escaping ( Dictionary<String, Any>?,Int?,Error?) -> Void) {
      
      print("*****************URL***********************\n")
      print("URL:- \(url)\n")
      print("Parameter:-\(parameter)\n")
      print("MethodType:- POST\n")
      print("*****************End***********************\n")

        // add loader if isLoader is true
        if isLoader {
            GFunction.shared.addLoader(nil)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if isDebug {
            //diaplay url scheme in console
            print("*****************URL***********************\n")
            print("\(url) \n ")
            print("****************************************\n")
        }
        
        APICall.shared.post(url,
                                    parameters: parameter
            , constructingBodyWith: { (formData : AFMultipartFormData) in
                if let _ = blockFormData {
                    blockFormData!(formData)
                }

        }, progress: { (progress : Progress) in
            
        }, success: { (task : URLSessionDataTask, response : Any?) in
            
            // remove loader if isLoader is true
            if isLoader {
                GFunction.shared.removeLoader()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            var statusCode = 0
            if let headerResponse = task.response as? HTTPURLResponse {
                statusCode = headerResponse.statusCode
            }
            
            if isDebug {
                print("******************Response**********************\n")
                print(response as! NSDictionary)
                print("****************************************\n")
            }
           
            completion(response as?  Dictionary<String, Any>,statusCode,task.error as NSError?)
            
            //Failer Block
        }) { (task : URLSessionDataTask?, error : Error) in
            
            // remove loader if isLoader is true
            if isLoader {
                GFunction.shared.removeLoader()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            var statusCode = 0

            //Logout User
            if let headerResponse = task!.response as? HTTPURLResponse {
                
                statusCode = headerResponse.statusCode

                if (headerResponse.statusCode == 401) {
                    //TODO: - Add your logout code here
                    GFunction.shared.userLogOut(AppDelegate.shared.window)
                }
            }
            
            //Display error alert if errorAlert is true
            if(errorAlert) {
                let err = error as NSError
                
                self.handleResponseWhenError(error: err)
                
                if statusCode != 401
                    && err.code != NSURLErrorTimedOut
                    && err.code != NSURLErrorNetworkConnectionLost
                    && err.code != NSURLErrorNotConnectedToInternet
                    && err.code != NSURLErrorCancelled {
                    
                } else {
                    GFunction.shared.showPopUpAlert(error.localizedDescription)
                }
            }
            
            completion(nil,statusCode,error)
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - PUT
    
    //POST Method
    //Parameter
    //url :- method name of API like user/login
    //parameter : - parameter which is required to pass in API
    //errorAlert : - pass Bool value to decide if any error occcued then display alert or not
    //isLoader : - to decide if Add loader or not
    //isDebug : - to print request and response in Console
    //completion :- completion block for pass response in class
    
    func PUT(strURL url : String
        , parameter :  Dictionary<String, Any>?
        ,withErrorAlert errorAlert : Bool = true
        ,withLoader isLoader : Bool = false
        ,debugLog isDebug : Bool = true
        , withBlock completion : @escaping ( Dictionary<String, Any>?,Int?,Error?) -> Void) {
      
      print("*****************URL***********************\n")
      print("URL:- \(url)\n")
      print("Parameter:-\(parameter)\n")
      print("MethodType:- PUT\n")
      print("*****************End***********************\n")
      
        APICall.shared.requestSerializer.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        // add loader if isLoader is true
        if isLoader {
            GFunction.shared.addLoader(nil)
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if isDebug {
            //diaplay url scheme in console
            print("*****************URL***********************\n")
            print("\(url) \n ")
            print("****************************************\n")
        }
        
        APICall.shared.put(url,
                                    parameters: parameter
           , success: { (task : URLSessionDataTask, response : Any?) in
            
            // remove loader if isLoader is true
            if isLoader {
                GFunction.shared.removeLoader()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            var statusCode = 0
            if let headerResponse = task.response as? HTTPURLResponse {
                statusCode = headerResponse.statusCode
            }
            
            if isDebug {
                print("******************Response**********************\n")
//                print(response as! NSDictionary)
                print("****************************************\n")
            }
            
            completion(response as?  Dictionary<String, Any>,statusCode,task.error as NSError?)
            
            //Failer Block
        }) { (task : URLSessionDataTask?, error : Error) in
            
            // remove loader if isLoader is true
            if isLoader {
                GFunction.shared.removeLoader()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false            
            
            var statusCode = 0
            
            //Logout User
            if let headerResponse = task!.response as? HTTPURLResponse {
                
                statusCode = headerResponse.statusCode
                
                if (headerResponse.statusCode == 401) {
                    
                    //TODO: - Add your logout code here
                    GFunction.shared.userLogOut(AppDelegate.shared.window)
                }
            }
            
            //Display error alert if errorAlert is true
            if(errorAlert) {
                let err = error as NSError
                if statusCode != 401
                    && err.code != NSURLErrorTimedOut
                    && err.code != NSURLErrorNetworkConnectionLost
                    && err.code != NSURLErrorNotConnectedToInternet{
                    

                } else {
                    GFunction.shared.showPopUpAlert(error.localizedDescription)
                }
            }
            
            completion(nil,statusCode,error)
        }
    }
    
    /*//Cancel multiple request
    func CancelTask(url : [String])  {
        
        let task = APICall.shared.tasks.filter{ url.contains($0.currentRequest!.url!.absoluteString)}
        
        _ =  task.map ({(taskToCancel : URLSessionTask) in
            
            taskToCancel.cancel()
            
        })
    }*/
    
    //Cancel single request
    func CancelTask(url : String)  {
        
//        DispatchQueue.main.async {
            let task = APICall.shared.tasks.filter{ $0.currentRequest!.url!.absoluteString == kBaseURL + url}
            
            _ =  task.map ({(taskToCancel : URLSessionTask) in
                taskToCancel.cancel()
            })
//        }
        
    }
    
    
    func handleResponseWhenError( error : NSError)
    {
        
        debugPrint("--------------------------------------------------------------------------------------")
        debugPrint("\nerror occured : \(error.localizedDescription)")
        
        if error.userInfo.count > 0 {
            
            let dictError = error.userInfo as NSDictionary
            
            if dictError.object(forKey: NSUnderlyingErrorKey) != nil {
                
                if (dictError.object(forKey: NSUnderlyingErrorKey) as! NSError).userInfo.count > 0 {
                    
                    let dictError1 = (dictError.object(forKey: NSUnderlyingErrorKey) as! NSError).userInfo as NSDictionary
                    
                    if dictError1.object(forKey: AFNetworkingOperationFailingURLResponseDataErrorKey) != nil {
                        
                        let dataError = dictError1.object(forKey: AFNetworkingOperationFailingURLResponseDataErrorKey) as! Data
                        
                        debugPrint( try! NSAttributedString(data: dataError , options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil).string as NSString  )
                        
                    }
                }
            }
        }
        
        debugPrint("--------------------------------------------------------------------------------------")
        
        //GF.sharedInstance().showAlert( kerrorMessage as NSString ,view : view)
    }

}
