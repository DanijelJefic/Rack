//
//  FriendModel.swift
//  Rack
//
//  Created by hyperlink on 08/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class FriendModel: NSObject, NSCoding {

    var id : String!
    var displayName : String!
    var profile : String!
    
    var userName : String!
    var verify : String! = ""
    
    static var currentFriendList : [FriendModel] = []
    
    override init() {
        
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        displayName = json["display_name"].stringValue
        profile = json["profile"].stringValue
        
        userName = json["user_name"].stringValue
        verify = json["verify"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()

        if id != nil{
            dictionary["id"] = id
        }
        if displayName != nil{
            dictionary["display_name"] = displayName
        }

        if profile != nil{
            dictionary["profile"] = profile
        }
        
        if userName != nil{
            dictionary["user_name"] = userName
        }
        if verify != nil{
            dictionary["verify"] = verify
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        displayName = aDecoder.decodeObject(forKey: "display_name") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        profile = aDecoder.decodeObject(forKey: "profile") as? String
        
        userName = aDecoder.decodeObject(forKey: "user_name") as? String
        verify = aDecoder.decodeObject(forKey: "verify") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if displayName != nil{
            aCoder.encode(displayName, forKey: "display_name")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if profile != nil{
            aCoder.encode(profile, forKey: "profile")
        }
        
        if userName != nil{
            aCoder.encode(userName, forKey: "user_name")
        }
        if verify != nil{
            aCoder.encode(verify, forKey: "verify")
        }
        
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [FriendModel]
    {
        var models:[FriendModel] = []
        for item in array
        {
            models.append(FriendModel(fromJson: item))
        }
        return models
    }
    
    func getUserName() -> String {
        var uName : String = ""
        
        if id == UserModel.currentUser.userId {
            uName = UserModel.currentUser.userName
        } else {
            uName = userName
        }
        
        return uName.replacingOccurrences(of: "@", with: "")
    }
    
    
    
    func getUserProfile() -> String {
        var img : String = ""
        if id == UserModel.currentUser.userId {
            img = UserModel.currentUser.profile
        } else {
            img = profile
        }
        return img
    }
    
    func isUserVerify() -> Bool {
        if self.verify == "not verify" {
            return false
        } else {
            return true
        }
    }
    
    func saveUserDetailInDefaults()  {
        
        FriendModel.currentFriendList = getUserDetailFromDefaults()
        
        let isAvailable = FriendModel.currentFriendList.contains { (obj : FriendModel) -> Bool in
            
            if obj.id == self.id {
                return true
            } else {
                return false
            }
        }
        
        if !isAvailable {
            FriendModel.currentFriendList.insert(self, at: 0)
            
            let userDefault = UserDefaults.standard
            
            let encodeData = NSKeyedArchiver.archivedData(withRootObject: FriendModel.currentFriendList)
            userDefault.set(encodeData, forKey: kUserSearchData)
            userDefault.synchronize()
        }
    }
    
    func getUserDetailFromDefaults() -> [FriendModel] {
        let userDefault = UserDefaults.standard
        guard let decodeData = userDefault.value(forKey: kUserSearchData) else {
            return []
        }
        return NSKeyedUnarchiver.unarchiveObject(with: decodeData as! Data) as! [FriendModel]
    }
    
}
