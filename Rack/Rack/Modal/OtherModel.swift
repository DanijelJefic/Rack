//
//  CommnoModel.swift
//  Rack
//
//  Created by hyperlink on 09/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

//MARK: - Facebook Model
class FacebookModel: NSObject {
    var email : String!
    var firstName : String!
    var id : String!
    var lastName : String!
    var name : String!
    var picture : Picture!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    override init() {
        super.init()
    }
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        email = json["email"].stringValue
        firstName = json["first_name"].stringValue
        id = json["id"].stringValue
        lastName = json["last_name"].stringValue
        name = json["name"].stringValue
        let pictureJson = json["picture"]
        if !pictureJson.isEmpty{
            picture = Picture(fromJson: pictureJson)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if email != nil{
            dictionary["email"] = email
        }
        if firstName != nil{
            dictionary["first_name"] = firstName
        }
        if id != nil{
            dictionary["id"] = id
        }
        if lastName != nil{
            dictionary["last_name"] = lastName
        }
        if name != nil{
            dictionary["name"] = name
        }
        if picture != nil{
            dictionary["picture"] = picture.toDictionary()
        }
        return dictionary
    }
}

class Picture : NSObject{
    
    var data : FData!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = FData(fromJson: dataJson)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if data != nil{
            dictionary["data"] = data.toDictionary()
        }
        return dictionary
    }
    
    
}
class FData : NSObject{
    
    var isSilhouette : String!
    var url : String!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        isSilhouette = json["is_silhouette"].stringValue
        url = json["url"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if isSilhouette != nil{
            dictionary["is_silhouette"] = isSilhouette
        }
        if url != nil{
            dictionary["url"] = url
        }
        return dictionary
    }
    
}

//MARK: - WardrobeList
class WardrobesModel : NSObject {
 
    var id : String!
    var image : String!
    
    override init() {
        super.init()
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        image = json["image"].stringValue
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
        if image != nil{
            dictionary["image"] = image
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [WardrobesModel]
    {
        var models:[WardrobesModel] = []
        for item in array
        {
            models.append(WardrobesModel(fromJson: item))
        }
        return models
    }
    
}

//MARK: - SearchText

class SearchText: NSObject, NSCoding {
    
    var id   : String!
    var name : String!
    
    static var currentSearchList : [SearchText] = []
    
    override init() {
        super.init()
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        id = json["id"].stringValue
        name = json["name"].stringValue
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
        if name != nil{
            dictionary["name"] = name
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [SearchText]
    {
        var models:[SearchText] = []
        for item in array
        {
            models.append(SearchText(fromJson: item))
        }
        return models
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        id = aDecoder.decodeObject(forKey: "id") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        
    }
    func saveUserDetailInDefaults(key : String)  {
        
        SearchText.currentSearchList = getUserDetailFromDefaults(key: key)
        
        let isAvailable = SearchText.currentSearchList.contains { (obj : SearchText) -> Bool in
            
            if obj.id == self.id {
                return true
            } else {
                return false
            }
        }
        
        if !isAvailable {
            SearchText.currentSearchList.insert(self, at: 0)
            
            let userDefault = UserDefaults.standard
            
            let encodeData = NSKeyedArchiver.archivedData(withRootObject: SearchText.currentSearchList)
            userDefault.set(encodeData, forKey: key)
            userDefault.synchronize()
        }
    }
    
    func getUserDetailFromDefaults(key : String) -> [SearchText] {
        let userDefault = UserDefaults.standard
        guard let decodeData = userDefault.value(forKey: key) else {
            return []
        }
        return NSKeyedUnarchiver.unarchiveObject(with: decodeData as! Data) as! [SearchText]
    }

}

