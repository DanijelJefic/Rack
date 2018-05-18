//
//  APIManager.swift
//
//
//  Created by GP on 15/05/17.
//  Copyright © 2017 . All rights reserved.
//

import UIKit

class APIManager: NSObject {

   static let  sharedInstance = APIManager()
    
    func withURL(_ urlString:String, post:Bool, attributes:NSDictionary!, completion:((Bool, Any?, NSError?) -> Void)!){
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let url:NSURL = NSURL.init(string: encodedString!)!
        var request:URLRequest = URLRequest.init(url: url as URL)
        
        if post {
            let params:NSMutableString  = NSMutableString()
            
            for key in attributes.allKeys {
                params.appendFormat("%@=%@&",key as! CVarArg, attributes.object(forKey: key) as! CVarArg)
            }
            
            var finalParamStrings:String = params as String
            if params.length>0 {
                finalParamStrings = params.substring(to: params.length-1)
            }
            
            let body:Data = finalParamStrings.data(using: String.Encoding.utf8)!
            
            request.httpMethod = "POST"
            request.httpBody = body
            request.setValue(String(format:"%lu",body.count), forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            DispatchQueue.main.async {
            if error  != nil{
                if completion != nil {
                    completion(false, nil,error! as NSError)
                }
            }else {
                
                if data == nil {
                    let error:NSError = NSError.init(domain: "Error", code: 400, userInfo: [NSLocalizedDescriptionKey:"Server Issue"])
                    if completion != nil {
                        completion(false, nil,error)
                    }
                    return
                }
                
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    if completion != nil {
                        
            
                        
                        completion(true, parsedData,nil)
                    }

                } catch _ as NSError {
                    let error:NSError = NSError.init(domain: "Error", code: 400, userInfo: [NSLocalizedDescriptionKey:"Server Issue"])
                    if completion != nil {
                        completion(false, nil,error)
                    }
                }
                }
            }
        }
        
        task.resume()
    }
    
    func multipartWithURL(_ urlString:String, post:Bool, attributes:NSDictionary!, completion:((Bool, Any?, NSError?) -> Void)!){
        
        let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url:NSURL = NSURL.init(string: encodedString!)!
        var request:URLRequest = URLRequest.init(url: url as URL)
        
        if post {
            request.httpMethod = "POST"
            let boundary = "----------V2ymHFg03ehbqgZCaKO6jy"
            request.setValue(String(format:"multipart/form-data; boundary=%@",boundary), forHTTPHeaderField: "Content-Type")
            
            let body = NSMutableData()
            
            for (key, value) in attributes {
                if value is Data {
                    let imageName:String = "image.png"
                     body.append(String(format:"--%@\r\n",boundary).data(using: String.Encoding.utf8)!)
                     body.append(String(format:"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",key as! CVarArg, imageName).data(using: String.Encoding.utf8)!)
                    body.append(String(format:"Content-Type: image/jpeg\r\n\r\n").data(using: String.Encoding.utf8)!)
                    body.append(value as! Data)
                    body.append(String(format:"\r\n").data(using: String.Encoding.utf8)!)
                }
                else {
                    body.append(String(format:"--%@\r\n",boundary).data(using: String.Encoding.utf8)!)
                    body.append(String(format:"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key as! CVarArg).data(using: String.Encoding.utf8)!)
                     body.append(String(format:"%@\r\n",value as! CVarArg).data(using: String.Encoding.utf8)!)
                }
            }
            
             body.append(String(format:"--%@--\r\n",boundary).data(using: String.Encoding.utf8)!)
             request.httpBody = body as Data
             request.setValue(String(format:"%lu",body.length), forHTTPHeaderField: "Content-Length")
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) in
            if error != nil {
                if completion != nil {
                    completion(false, nil,error! as NSError)
                }
            }else {
                if data == nil {
                    let error:NSError = NSError.init(domain: "Error", code: 400, userInfo: [NSLocalizedDescriptionKey:"Server Issue"])
                    if completion != nil {
                        completion(false, nil,error)
                    }
                    return
                }
                
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
     
                    
                    if completion != nil {
                        completion(true, parsedData,nil)
                    }
                    
                } catch _ as NSError {
                    let error:NSError = NSError.init(domain: "Error", code: 400, userInfo: [NSLocalizedDescriptionKey:"Server Response Issue"])
                    if completion != nil {
                        completion(false, nil,error)
                    }
                }
            }
        }
    }
    
    
    func imageAtURL(_ urlString:String, completion:((UIImage?, NSError?)-> Void)!){
    
        if urlString.trimmingCharacters(in: .whitespaces).characters.count==0 {
            if completion != nil {
                let error:NSError = NSError.init(domain: "Error", code: 400, userInfo: [NSLocalizedDescriptionKey:"Invalid URL"])
                completion (nil,error)
            }
            return
        }
        
        
        var imagePath = urlString.replacingOccurrences(of: "/", with: "")
        imagePath = imagePath.replacingOccurrences(of: ":", with: "")
        imagePath = imagePath.replacingOccurrences(of: ".", with: "")
        imagePath = imagePath.replacingOccurrences(of: "png", with: "")
        imagePath = imagePath.replacingOccurrences(of: "jpg", with: "")
        imagePath = imagePath.replacingOccurrences(of: "jpeg", with: "")
        imagePath = imagePath.replacingOccurrences(of: "PNG", with: "")
        imagePath = imagePath.replacingOccurrences(of: "JPG", with: "")
        imagePath = imagePath.replacingOccurrences(of: "JPEG", with: "")
        
        imagePath = String(format:"%@.png",imagePath)
        
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imagePath)
        
        
        let documentsPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let imageURL = URL(fileURLWithPath: documentsPath).appendingPathComponent(imagePath)
        let image    = UIImage(contentsOfFile: imageURL.path)
        
        if image != nil {
            if completion != nil {
                completion (image,nil)
            }
        }else {
            URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    if completion != nil {
                        completion (nil, error! as NSError)
                    }
                }
                DispatchQueue.main.async {
                    let image = UIImage(data: data!)
                    
                    if image != nil {
                        fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
                        if completion != nil {
                            completion (image,nil)
                        }
                    }
                    else{
                        let error:NSError = NSError.init(domain: "Error", code: 400, userInfo: [NSLocalizedDescriptionKey:"Fail to Load Image"])
                        completion (nil,error)
                    }
                }
                
            }).resume()
        }
    }
}

func apiManager() -> APIManager {
    return APIManager.sharedInstance
}




