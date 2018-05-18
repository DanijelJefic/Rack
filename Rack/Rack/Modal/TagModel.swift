//
//  TagModel.swift
//  Rack
//
//  Created by hyperlink on 22/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

//MARK: - TagDetail
class TagDetail : NSObject {
    
    var brandTag : [SimpleTagModel]!
    var hashTag : [HashTag]!
    var itemTag : [SimpleTagModel]!
    var linkTag : [LinkTagModel]!
    var userTag : [PeopleTagModel]!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        brandTag = [SimpleTagModel]()
        let brandTagArray = json["brand_tag"].arrayValue
        for brandTagJson in brandTagArray{
            let value = SimpleTagModel(fromJson: brandTagJson)
            brandTag.append(value)
        }
        hashTag = [HashTag]()
        let hashTagArray = json["hash_tag"].arrayValue
        for hashTagJson in hashTagArray{
            let value = HashTag(fromJson: hashTagJson)
            hashTag.append(value)
        }
        itemTag = [SimpleTagModel]()
        /*
        let itemTagArray = json["item_tag"].arrayValue
        for itemTagJson in itemTagArray{
            let value = SimpleTagModel(fromJson: itemTagJson)
            itemTag.append(value)
        }
        */
        linkTag = [LinkTagModel]()
        let linkTagArray = json["link_tag"].arrayValue
        for linkTagJson in linkTagArray{
            let value = LinkTagModel(fromJson: linkTagJson)
            linkTag.append(value)
        }
        userTag = [PeopleTagModel]()
        let userTagArray = json["user_tag"].arrayValue
        for userTagJson in userTagArray{
            let value = PeopleTagModel(fromJson: userTagJson)
            userTag.append(value)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if brandTag != nil{
            var dictionaryElements = [[String:Any]]()
            for brandTagElement in brandTag {
                dictionaryElements.append(brandTagElement.toDictionary())
            }
            dictionary["brand_tag"] = dictionaryElements
        }
        if hashTag != nil{
            var dictionaryElements = [[String:Any]]()
            for hashTagElement in hashTag {
                dictionaryElements.append(hashTagElement.toDictionary())
            }
            dictionary["hash_tag"] = dictionaryElements
        }
        if itemTag != nil{
            var dictionaryElements = [[String:Any]]()
            for itemTagElement in itemTag {
                dictionaryElements.append(itemTagElement.toDictionary())
            }
            dictionary["item_tag"] = dictionaryElements
        }
        if linkTag != nil{
            var dictionaryElements = [[String:Any]]()
            for linkTagElement in linkTag {
                dictionaryElements.append(linkTagElement.toDictionary())
            }
            dictionary["link_tag"] = dictionaryElements
        }
        if userTag != nil{
            var dictionaryElements = [[String:Any]]()
            for userTagElement in userTag {
                dictionaryElements.append(userTagElement.toDictionary())
            }
            dictionary["user_tag"] = dictionaryElements
        }
        return dictionary
    }
}


//MARK: - SimpleTagModel
class SimpleTagModel: NSObject {

    var id    : String!
    var name  : String!
    var xAxis : String!
    var yAxis : String!
    
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
        xAxis = json["x_axis"].stringValue
        yAxis = json["y_axis"].stringValue
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
        if xAxis != nil{
            dictionary["x_axis"] = xAxis
        }
        if yAxis != nil{
            dictionary["y_axis"] = yAxis
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [SimpleTagModel]
    {
        var models:[SimpleTagModel] = []
        for item in array
        {
            models.append(SimpleTagModel(fromJson: item))
        }
        return models
    }

    internal class func dictArrayFromModelArray(array:[SimpleTagModel]) -> [Dictionary<String,Any>]
    {
        var arrayData : [Dictionary<String,Any>] = []
        for item in array
        {
            arrayData.append(item.toDictionary())
        }
        return arrayData
    }
    
    //MARK: - Helper Method
    
    internal class func changeTagCondinateTomOrignalImageScaleFactor(_ array : [SimpleTagModel], scaleFactor : Float, imgPost : UIImage) -> [SimpleTagModel] {
        
        var models:[SimpleTagModel] = []
        for item in array
        {
            let newXAxis = String(Float(item.xAxis)! * scaleFactor)
            let newYAxis = String(Float(item.yAxis)! * scaleFactor)
           
            item.xAxis = newXAxis
            item.yAxis = newYAxis
            
            models.append(item)
        }
        return models
    }
    
    internal class func changeTagCondinateTomDeviceImageScaleFactor(_ array : [SimpleTagModel], scaleFactor : Float) -> [SimpleTagModel] {
        
        var models:[SimpleTagModel] = []
        for item in array
        {
            let newXAxis = String(Float(item.xAxis)! / scaleFactor)
            let newYAxis = String(Float(item.yAxis)! / scaleFactor)
            
            item.xAxis = newXAxis
            item.yAxis = newYAxis
            models.append(item)
        }
        return models
    }
    

}

//MARK: - LinkTagModel
class LinkTagModel: NSObject {
    
    var name  : String!
    var xAxis : String!
    var yAxis : String!
    
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

        name = json["name"].stringValue
        xAxis = json["x_axis"].stringValue
        yAxis = json["y_axis"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()

        if name != nil{
            dictionary["name"] = name
        }
        if xAxis != nil{
            dictionary["x_axis"] = xAxis
        }
        if yAxis != nil{
            dictionary["y_axis"] = yAxis
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [LinkTagModel]
    {
        var models:[LinkTagModel] = []
        for item in array
        {
            models.append(LinkTagModel(fromJson: item))
        }
        return models
    }
    
    internal class func dictArrayFromModelArray(array:[LinkTagModel]) -> [Dictionary<String,Any>]
    {
        var arrayData : [Dictionary<String,Any>] = []
        for item in array
        {
            arrayData.append(item.toDictionary())
        }
        return arrayData
    }
    
    //MARK: Helper Method 
    
    internal class func changeTagCondinateTomOrignalImageScaleFactor(_ array : [LinkTagModel], scaleFactor : Float, imgPost : UIImage) -> [LinkTagModel] {
        
        var models:[LinkTagModel] = []
        for item in array
        {
            let newXAxis = String(Float(item.xAxis)! * scaleFactor)
            let newYAxis = String(Float(item.yAxis)! * scaleFactor)
            
            item.xAxis = newXAxis
            item.yAxis = newYAxis
            
            models.append(item)
        }
        return models
    }
    
    internal class func changeTagCondinateTomDeviceImageScaleFactor(_ array : [LinkTagModel], scaleFactor : Float) -> [LinkTagModel] {
        
        var models:[LinkTagModel] = []
        for item in array
        {
            let newXAxis = String(Float(item.xAxis)! / scaleFactor)
            let newYAxis = String(Float(item.yAxis)! / scaleFactor)
            
            item.xAxis = newXAxis
            item.yAxis = newYAxis
            models.append(item)
        }
        return models
    }
    
}

//MARK: - PeopleTagModel

class PeopleTagModel: NSObject {
    
    var userId  : String!
    var xAxis : String!
    var yAxis : String!
    var name  : String!
    
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
        userId = json["user_id"].stringValue
        xAxis = json["x_axis"].stringValue
        yAxis = json["y_axis"].stringValue
        name = json["name"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if name != nil{
            dictionary["name"] = name
        }
        if xAxis != nil{
            dictionary["x_axis"] = xAxis
        }
        if yAxis != nil{
            dictionary["y_axis"] = yAxis
        }


        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [PeopleTagModel]
    {
        var models:[PeopleTagModel] = []
        for item in array
        {
            models.append(PeopleTagModel(fromJson: item))
        }
        return models
    }
    
    internal class func dictArrayFromModelArray(array:[PeopleTagModel]) -> [Dictionary<String,Any>]
    {
        var arrayData : [Dictionary<String,Any>] = []
        for item in array
        {
            arrayData.append(item.toDictionary())
        }
        return arrayData
    }
    
    //MARK: Helper Method
    
    internal class func changeTagCondinateTomOrignalImageScaleFactor(_ array : [PeopleTagModel], scaleFactor : Float, imgPost : UIImage) -> [PeopleTagModel] {
        
        var models:[PeopleTagModel] = []
        for item in array
        {
            let newXAxis = String(Float(item.xAxis)! * scaleFactor)
            let newYAxis = String(Float(item.yAxis)! * scaleFactor)
            
            item.xAxis = newXAxis
            item.yAxis = newYAxis
            
            models.append(item)
        }
        return models
    }
    
    internal class func changeTagCondinateTomDeviceImageScaleFactor(_ array : [PeopleTagModel], scaleFactor : Float) -> [PeopleTagModel] {
        
        var models:[PeopleTagModel] = []
        for item in array
        {
            let newXAxis = String(Float(item.xAxis)! / scaleFactor)
            let newYAxis = String(Float(item.yAxis)! / scaleFactor)
            
            item.xAxis = newXAxis
            item.yAxis = newYAxis
            models.append(item)
        }
        return models
    }

}

//MARK: - HashTag
class HashTag : NSObject{
    
    var hashtagId : String!
    var id : String!
    var name : String!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        hashtagId = json["hashtag_id"].stringValue
        id = json["id"].stringValue
        name = json["name"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if hashtagId != nil{
            dictionary["hashtag_id"] = hashtagId
        }
        if id != nil{
            dictionary["id"] = id
        }
        if name != nil{
            dictionary["name"] = name
        }
        return dictionary
    }
}
